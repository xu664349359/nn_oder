import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';

class AuthProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
      notifyListeners();
    }
  }

  Future<bool> login(String phoneNumber, String password) async {
    _setLoading(true);
    final user = await _dataService.login(phoneNumber, password);
    if (user != null) {
      await _saveUser(user);
    }
    _setLoading(false);
    return user != null;
  }

  Future<void> register(String phoneNumber, String password, String nickname, UserRole role) async {
    _setLoading(true);
    try {
      final user = await _dataService.register(phoneNumber, password, nickname, role);
      await _saveUser(user);
    } catch (e) {
      // Phone already registered, rethrow
      _setLoading(false);
      rethrow;
    }
    _setLoading(false);
  }

  Future<bool> bindPartner(String invitationCode) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    final success = await _dataService.bindCouple(_currentUser!.id, invitationCode);
    if (success) {
      // Refresh user data to get partnerId
      // In a real app, we'd fetch the user again. Here we just mock update.
      // For simplicity in this mock, we assume the service updated the in-memory user,
      // but we need to reflect that locally if we want to persist it.
      // Let's just re-login or update the local user object.
      // Since MockDataService updates the object reference in memory if we fetched it from there,
      // but here we have a local copy.
      // Let's just manually update the local user for now as the service returns boolean.
      // Ideally MockDataService should return the updated user.
      
      // Re-fetch user from service simulation
      final updatedUser = await _dataService.login(_currentUser!.phoneNumber, _currentUser!.password);
      if (updatedUser != null) {
        await _saveUser(updatedUser);
      }
    }
    _setLoading(false);
    return success;
  }

  Future<void> skipBinding() async {
    if (_currentUser == null) return;
    // Create a dummy partner ID for dev skipping
    final updatedUser = _currentUser!.copyWith(partnerId: 'DEV_SKIP_PARTNER');
    await _saveUser(updatedUser);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _saveUser(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
