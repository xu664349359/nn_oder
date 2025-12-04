import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';
import '../models/menu_model.dart';
import '../services/supabase_service.dart';

class CartProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  Cart _cart = Cart(items: []);
  bool _isLoading = false;
  
  Cart get cart => _cart;
  bool get isLoading => _isLoading;
  int get itemCount => _cart.totalItems;
  
  Future<void> loadCart(String userId) async {
    _setLoading(true);
    try {
      final data = await _supabaseService.getCartItems(userId);
      final items = data.map((json) {
        // Parse the nested menu item
        final menuJson = json['menu'] as Map<String, dynamic>;
        // Ensure menu item ID is set correctly if not present in joined data
        if (menuJson['id'] == null) menuJson['id'] = json['menu_item_id'];
        
        debugPrint('CartProvider: menuJson type: ${menuJson.runtimeType}');
        final menuItem = MenuItem.fromJson(menuJson);
        debugPrint('CartProvider: menuItem type: ${menuItem.runtimeType}');
        
        return CartItem.fromJson(json, menuItem);
      }).toList();
      
      _cart = Cart(items: items);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> addItem(String userId, String menuItemId, {int quantity = 1, bool washDishes = false}) async {
    try {
      await _supabaseService.addToCart(userId, menuItemId, quantity: quantity, washDishes: washDishes);
      await loadCart(userId);
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
      rethrow;
    }
  }
  
  Future<void> updateItem(String userId, String cartItemId, {int? quantity, bool? washDishes}) async {
    try {
      await _supabaseService.updateCartItem(cartItemId, quantity: quantity, washDishes: washDishes);
      await loadCart(userId);
    } catch (e) {
      debugPrint('Error updating cart item: $e');
      rethrow;
    }
  }
  
  Future<void> removeItem(String userId, String cartItemId) async {
    try {
      await _supabaseService.removeFromCart(cartItemId);
      await loadCart(userId);
    } catch (e) {
      debugPrint('Error removing cart item: $e');
      rethrow;
    }
  }
  
  Future<void> clearCart(String userId) async {
    try {
      await _supabaseService.clearCart(userId);
      _cart = Cart(items: []);
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }

  Future<void> checkout(String userId, String coupleId) async {
    _setLoading(true);
    try {
      // Prepare items for checkout
      final cartItemsData = _cart.items.map((item) => {
        'menu_item_id': item.menuItemId,
        'quantity': item.quantity,
        'wash_dishes': item.washDishes,
        'menu': item.menuItem.toJson(), // Pass menu item data for price calculation
      }).toList();

      await _supabaseService.checkout(userId, cartItemsData, _cart.totalFinalPrice, coupleId);
      
      // Clear local cart after successful checkout
      _cart = Cart(items: []);
      notifyListeners();
    } catch (e) {
      debugPrint('Error during checkout: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
