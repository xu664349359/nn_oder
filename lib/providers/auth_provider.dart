import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _currentUser;
  User? _partnerUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  User? get partnerUser => _partnerUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _supabaseService.authStateChanges.listen((state) {
      if (state.event == supabase.AuthChangeEvent.signedIn) {
        _loadUserProfile();
        _subscribeToProfileChanges();
      } else if (state.event == supabase.AuthChangeEvent.signedOut) {
        _currentUser = null;
        _partnerUser = null;
        _unsubscribeFromProfileChanges();
        notifyListeners();
      }
    });
  }

  // ... (existing methods)

  Future<void> _loadUserProfile() async {
    final authUser = _supabaseService.currentUser;
    if (authUser == null) return;

    try {
      final profileData = await _supabaseService.getProfile(authUser.id);
      if (profileData != null) {
        debugPrint('Loading user profile: ${profileData['nickname']}, partner_id: ${profileData['partner_id']}');
        
        _currentUser = User(
          id: authUser.id,
          phoneNumber: authUser.email ?? '', // Use email as phone/identifier
          password: '', // Don't store password
          nickname: profileData['nickname'] ?? '',
          role: _parseRole(profileData['role']),
          avatarUrl: profileData['avatar_url'],
          partnerId: profileData['partner_id'],
          invitationCode: profileData['invitation_code'], // Use 6-digit code from DB
          backgroundImageUrl: profileData['background_image_url'],
        );
        
        // Load Partner Profile if bound
        if (_currentUser?.partnerId != null) {
          await _loadPartnerProfile(_currentUser!.partnerId!);
        } else {
          _partnerUser = null;
        }
        
        debugPrint('User loaded - partnerId: ${_currentUser?.partnerId}');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> _loadPartnerProfile(String partnerId) async {
    try {
      final profileData = await _supabaseService.getProfile(partnerId);
      if (profileData != null) {
        _partnerUser = User(
          id: partnerId,
          phoneNumber: '', // Not needed for partner view
          password: '',
          nickname: profileData['nickname'] ?? 'Partner',
          role: _parseRole(profileData['role']),
          avatarUrl: profileData['avatar_url'],
          partnerId: _currentUser?.id,
          invitationCode: profileData['invitation_code'],
        );
        debugPrint('Partner loaded: ${_partnerUser?.nickname}');
      }
    } catch (e) {
      debugPrint('Error loading partner profile: $e');
    }
  }

  void _subscribeToProfileChanges() {
    final userId = _supabaseService.currentUser?.id;
    if (userId == null) return;

    // Subscribe to real-time updates for this user's profile
    _supabaseService.subscribeToProfileChanges(userId, (payload) {
      // When profile is updated (e.g., partner_id changed), reload user data
      debugPrint('Profile updated, reloading user data...');
      _loadUserProfile();
    });
  }

  void _unsubscribeFromProfileChanges() {
    _supabaseService.unsubscribeFromProfileChanges();
  }

  Future<void> loadUser() async {
    if (_supabaseService.currentUser != null) {
      await _loadUserProfile();
    }
  }


  UserRole _parseRole(String? role) {
    if (role == 'chef') return UserRole.chef;
    if (role == 'foodie') return UserRole.foodie;
    return UserRole.chef; // Default
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _supabaseService.signIn(email: email, password: password);
      if (response.user != null) {
        // Wait for profile to load
        await _loadUserProfile();
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> register(String email, String password, String nickname, UserRole role) async {
    _setLoading(true);
    try {
      final response = await _supabaseService.signUp(email: email, password: password);
      if (response.user != null) {
        // Create profile
        await _supabaseService.createProfile(
          id: response.user!.id,
          nickname: nickname,
          role: role == UserRole.chef ? 'chef' : 'foodie',
        );
        
        // Load the user profile immediately
        // The auth state listener will also trigger, but we ensure it's loaded now
        await _loadUserProfile();
      }
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
    _setLoading(false);
  }

  Future<void> updateProfileBackground(String filePath) async {
    if (_currentUser == null) return;
    
    try {
      // 1. Upload image
      final imageUrl = await _supabaseService.uploadProfileBackground(filePath, _currentUser!.id);
      
      // 2. Update profile
      await _supabaseService.updateProfile(_currentUser!.id, {
        'background_image_url': imageUrl,
      });
      
      // 3. Reload user
      await _loadUserProfile();
    } catch (e) {
      debugPrint('Error updating profile background: $e');
      rethrow;
    }
  }

  Future<bool> bindPartner(String invitationCode) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    
    try {
      // 1. Find partner by invitation code
      final partnerProfile = await _supabaseService.getProfileByInvitationCode(invitationCode);
      if (partnerProfile == null) {
        _setLoading(false);
        return false;
      }
      
      final partnerId = partnerProfile['id'];

      // 2. Create couple
      // Determine who is chef and who is foodie
      String chefId = _currentUser!.role == UserRole.chef ? _currentUser!.id : partnerId;
      String foodieId = _currentUser!.role == UserRole.foodie ? _currentUser!.id : partnerId;

      await _supabaseService.createCouple(chefId: chefId, foodieId: foodieId);

      // 3. Update profiles with partner_id
      debugPrint('Updating partner_id for user ${_currentUser!.id} -> $partnerId');
      await _supabaseService.updateProfile(_currentUser!.id, {'partner_id': partnerId});
      
      debugPrint('Updating partner_id for partner $partnerId -> ${_currentUser!.id}');
      await _supabaseService.updateProfile(partnerId, {'partner_id': _currentUser!.id});

      // 4. Reload user
      await _loadUserProfile();
      
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Binding error: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> skipBinding() async {
    // Dev only
  }

  Future<void> logout() async {
    await _supabaseService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> refreshBalance() async {
    if (_currentUser == null) return;
    try {
      final balance = await _supabaseService.getIntimacyBalance(_currentUser!.id);
      _currentUser = _currentUser!.copyWith(intimacyBalance: balance);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing balance: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
