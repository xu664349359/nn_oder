import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/intimacy_task_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _profileChannel;

  // --- Auth ---

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({required String email, required String password}) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // --- Profiles ---

  Future<void> createProfile({
    required String id,
    required String nickname,
    required String role,
    String? avatarUrl,
  }) async {
    // Generate unique 6-digit invitation code
    String invitationCode = _generateInvitationCode();
    
    // Keep trying until we get a unique code
    bool isUnique = false;
    int attempts = 0;
    while (!isUnique && attempts < 10) {
      try {
        await _client.from('profiles').insert({
          'id': id,
          'nickname': nickname,
          'role': role,
          'avatar_url': avatarUrl,
          'invitation_code': invitationCode,
        });
        isUnique = true;
      } catch (e) {
        // If duplicate, generate new code
        invitationCode = _generateInvitationCode();
        attempts++;
        if (attempts >= 10) rethrow;
      }
    }
  }

  String _generateInvitationCode() {
    // Generate random 6-digit number
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = (100000 + (random % 900000)).toString();
    return code;
  }

  Future<Map<String, dynamic>?> getProfileByInvitationCode(String code) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('invitation_code', code)
          .maybeSingle();
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final data = await _client.from('profiles').select().eq('id', userId).single();
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    print('SupabaseService: Updating profile $userId with $updates');
    final result = await _client.from('profiles').update(updates).eq('id', userId).select();
    print('SupabaseService: Update result: $result');
  }

  // --- Couples ---

  Future<Map<String, dynamic>?> getCouple(String userId) async {
    // Find couple where user is either chef or foodie
    try {
      final data = await _client.from('couples')
          .select()
          .or('chef_id.eq.$userId,foodie_id.eq.$userId')
          .maybeSingle();
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<void> createCouple({required String chefId, required String foodieId}) async {
    await _client.from('couples').insert({
      'chef_id': chefId,
      'foodie_id': foodieId,
      'intimacy_score': 0,
    });
  }

  // --- Menu ---
  // For simplicity, we'll keep menu in a separate table or just use a static list if table not exists.
  // Let's assume we have a 'menu' table.
  
  Future<List<Map<String, dynamic>>> getMenu(String? coupleId) async {
    if (coupleId == null) return [];
    
    try {  
      final data = await _client
          .from('menu')
          .select()
          .eq('couple_id', coupleId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error fetching menu: $e');
      return [];
    }
  }

  Future<void> addMenuItem(Map<String, dynamic> item) async {
    await _client.from('menu').insert(item);
  }

  // --- Orders ---

  Future<List<Map<String, dynamic>>> getOrders(String coupleId) async {
    final data = await _client
        .from('orders')
        .select()
        .eq('couple_id', coupleId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    await _client.from('orders').insert(orderData);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      debugPrint('SupabaseService: Updating order $orderId to status: $status');
      final result = await _client
          .from('orders')
          .update({'status': status})
          .eq('id', orderId)
          .select();
      debugPrint('SupabaseService: Order update result: $result');
    } catch (e) {
      debugPrint('SupabaseService: Error updating order status: $e');
      rethrow;
    }
  }

  Future<void> rateOrder(String orderId, int rating, String comment) async {
    // Assuming we have rating fields in orders table, or a separate reviews table.
    // Let's add rating/comment to orders table in schema update.
    await _client.from('orders').update({
      'rating': rating,
      'comment': comment,
      'status': 'completed' // Auto complete on rate?
    }).eq('id', orderId);
  }

  // --- Intimacy ---

  Future<int> getIntimacyScore(String coupleId) async {
    final data = await _client
        .from('couples')
        .select('intimacy_score')
        .eq('id', coupleId)
        .single();
    return data['intimacy_score'] as int;
  }

  Future<void> updateIntimacyScore(String coupleId, int newScore) async {
    try {
      debugPrint('SupabaseService: Updating intimacy score for couple $coupleId to $newScore');
      final result = await _client
          .from('couples')
          .update({'intimacy_score': newScore})
          .eq('id', coupleId)
          .select();
      debugPrint('SupabaseService: Update result: $result');
    } catch (e) {
      debugPrint('SupabaseService: Error updating intimacy score: $e');
      rethrow;
    }
  }

  // --- Realtime Subscriptions ---

  void subscribeToProfileChanges(String userId, Function(Map<String, dynamic>) onUpdate) {
    // Unsubscribe existing channel if any
    unsubscribeFromProfileChanges();

    // Create new channel for this user's profile
    _profileChannel = _client
        .channel('profile_changes_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) {
            onUpdate(payload.newRecord);
          },
        )
        .subscribe();
  }

  void unsubscribeFromProfileChanges() {
    if (_profileChannel != null) {
      _client.removeChannel(_profileChannel!);
      _profileChannel = null;
    }
  }

  // --- File Upload ---

  Future<String> uploadMenuImage(String filePath, String menuItemId) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    
    await _client.storage.from('menu-images').uploadBinary(
      'menu_$menuItemId.jpg',
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    
    return _client.storage.from('menu-images').getPublicUrl('menu_$menuItemId.jpg');
  }

  Future<String> uploadRecipeMedia(String filePath, String stepId, {required bool isVideo}) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    
    final extension = isVideo ? 'mp4' : 'jpg';
    final prefix = isVideo ? 'video' : 'image';
    final bucketPath = '${prefix}_$stepId.$extension';
    
    await _client.storage.from('recipe-media').uploadBinary(
      bucketPath,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    
    return _client.storage.from('recipe-media').getPublicUrl(bucketPath);
  }

  Future<void> deleteFile(String bucketName, String path) async {
    await _client.storage.from(bucketName).remove([path]);
  }

  Future<String> uploadProfileBackground(String filePath, String userId) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final fileExt = filePath.split('.').last;
    final fileName = 'bg_$userId.$fileExt';
    
    await _client.storage.from('profile-backgrounds').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    
    return _client.storage.from('profile-backgrounds').getPublicUrl(fileName);
  }

  // --- Recipe Steps ---

  Future<List<Map<String, dynamic>>> getRecipeSteps(String menuItemId) async {
    final data = await _client
        .from('recipe_steps')
        .select()
        .eq('menu_item_id', menuItemId)
        .order('step_number', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> saveRecipeStep(Map<String, dynamic> stepData) async {
    try {
      debugPrint('SupabaseService: Saving recipe step: $stepData');
      
      if (stepData['id'] != null) {
        // Update existing step
        final result = await _client
            .from('recipe_steps')
            .update(stepData)
            .eq('id', stepData['id'])
            .select();
        debugPrint('SupabaseService: Recipe step updated: $result');
      } else {
        // Insert new step
        final result = await _client
            .from('recipe_steps')
            .insert(stepData)
            .select();
        debugPrint('SupabaseService: Recipe step inserted: $result');
      }
    } catch (e) {
      debugPrint('SupabaseService: Error saving recipe step: $e');
      rethrow;
    }
  }

  Future<void> deleteRecipeStep(String stepId) async {
    await _client.from('recipe_steps').delete().eq('id', stepId);
  }

  Future<void> reorderRecipeSteps(String menuItemId, List<String> stepIds) async {
    // Update step numbers based on order in list
    for (int i = 0; i < stepIds.length; i++) {
      await _client.from('recipe_steps').update({
        'step_number': i + 1,
      }).eq('id', stepIds[i]);
    }
  }
  // --- Cart & Balance ---

  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    try {
      final data = await _client
          .from('shopping_cart')
          .select('*, menu(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('SupabaseService: Error fetching cart items: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addToCart(String userId, String menuItemId, {int quantity = 1, bool washDishes = false}) async {
    try {
      // Check if item already exists in cart
      final existing = await _client
          .from('shopping_cart')
          .select()
          .eq('user_id', userId)
          .eq('menu_item_id', menuItemId)
          .maybeSingle();

      if (existing != null) {
        // Update quantity
        final newQuantity = (existing['quantity'] as int) + quantity;
        final result = await _client
            .from('shopping_cart')
            .update({'quantity': newQuantity, 'updated_at': DateTime.now().toIso8601String()})
            .eq('id', existing['id'])
            .select('*, menu(*)')
            .single();
        return result;
      } else {
        // Insert new item
        final result = await _client
            .from('shopping_cart')
            .insert({
              'user_id': userId,
              'menu_item_id': menuItemId,
              'quantity': quantity,
              'wash_dishes': washDishes,
            })
            .select('*, menu(*)')
            .single();
        return result;
      }
    } catch (e) {
      debugPrint('SupabaseService: Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> updateCartItem(String cartItemId, {int? quantity, bool? washDishes}) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (quantity != null) updates['quantity'] = quantity;
      if (washDishes != null) updates['wash_dishes'] = washDishes;

      await _client
          .from('shopping_cart')
          .update(updates)
          .eq('id', cartItemId);
    } catch (e) {
      debugPrint('SupabaseService: Error updating cart item: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    await _client.from('shopping_cart').delete().eq('id', cartItemId);
  }

  Future<void> clearCart(String userId) async {
    await _client.from('shopping_cart').delete().eq('user_id', userId);
  }

  Future<int> getIntimacyBalance(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select('intimacy_balance')
          .eq('id', userId)
          .single();
      return data['intimacy_balance'] as int;
    } catch (e) {
      debugPrint('SupabaseService: Error fetching balance: $e');
      return 0;
    }
  }

  Future<void> updateIntimacyBalance(String userId, int newBalance) async {
    await _client
        .from('profiles')
        .update({'intimacy_balance': newBalance})
        .eq('id', userId);
  }

  Future<void> checkout(String userId, List<Map<String, dynamic>> cartItems, int totalCost, String coupleId) async {
    // Transaction-like logic (Supabase doesn't support multi-table transactions in client directly easily without RPC, 
    // but we'll do sequential operations with error handling)
    
    try {
      // 1. Check balance again
      final currentBalance = await getIntimacyBalance(userId);
      if (currentBalance < totalCost) {
        throw Exception('Insufficient balance');
      }

      // 2. Deduct balance
      await updateIntimacyBalance(userId, currentBalance - totalCost);

      // 3. Create orders
      for (final item in cartItems) {
        final menuItem = item['menu'];
        final quantity = item['quantity'] as int;
        final washDishes = item['wash_dishes'] as bool;
        final basePrice = (menuItem['intimacy_price'] as int) * quantity;
        final discount = washDishes ? (basePrice * 0.2).round() : 0;
        final finalPrice = basePrice - discount;

        await createOrder({
          'couple_id': coupleId,
          'user_id': userId, // Who placed the order
          'menu_item_id': item['menu_item_id'],
          'quantity': quantity,
          'status': 'pending',
          'wash_dishes': washDishes,
          'original_intimacy_cost': basePrice,
          'actual_intimacy_cost': finalPrice,
          'discount_amount': discount,
        });
      }

      // 4. Clear cart
      await clearCart(userId);
      
    } catch (e) {
      debugPrint('SupabaseService: Checkout failed: $e');
      rethrow;
    }
  }
  // --- Intimacy Tasks ---

  Future<void> createIntimacyTask(IntimacyTask task) async {
    await _client.from('intimacy_tasks').insert(task.toJson());
  }

  Future<List<IntimacyTask>> getIntimacyTasks({String? coupleId, TaskType? type}) async {
    var query = _client.from('intimacy_tasks').select();
    
    if (coupleId != null) {
      query = query.eq('couple_id', coupleId);
    }
    
    if (type != null) {
      query = query.eq('type', type.name);
    }
    
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => IntimacyTask.fromJson(e)).toList();
  }

  Future<void> claimTask(String taskId, String userId) async {
    await _client.from('task_executions').insert({
      'task_id': taskId,
      'user_id': userId,
      'status': 'claimed',
    });
  }

  Future<List<TaskExecution>> getTaskExecutions(String userId) async {
    final data = await _client
        .from('task_executions')
        .select('*, intimacy_tasks(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => TaskExecution.fromJson(e)).toList();
  }

  Future<String> uploadTaskProof(String filePath, String executionId) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final fileExt = filePath.split('.').last;
    final fileName = 'proof_$executionId.$fileExt';
    
    await _client.storage.from('task-proofs').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    
    return _client.storage.from('task-proofs').getPublicUrl(fileName);
  }

  Future<void> submitTaskProof(String executionId, String proofUrl) async {
    await _client.from('task_executions').update({
      'status': 'submitted',
      'proof_image_url': proofUrl,
    }).eq('id', executionId);
  }

  Future<void> approveTask(String executionId, String userId, int rewardPoints) async {
    // 1. Update execution status
    await _client.from('task_executions').update({
      'status': 'approved',
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', executionId);

    // 2. Add points to user
    final currentBalance = await getIntimacyBalance(userId);
    await updateIntimacyBalance(userId, currentBalance + rewardPoints);
  }
}
