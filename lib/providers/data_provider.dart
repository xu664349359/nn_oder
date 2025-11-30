import 'package:flutter/foundation.dart';
import '../models/menu_model.dart';
import '../models/order_model.dart';
import '../models/intimacy_model.dart';
import '../services/supabase_service.dart';

class DataProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<MenuItem> _menuItems = [];
  List<Order> _orders = [];
  Intimacy? _intimacy;
  bool _isLoading = false;
  String? _currentCoupleId;
  String? _currentUserId;

  List<MenuItem> get menuItems => _menuItems;
  List<Order> get orders => _orders;
  Intimacy? get intimacy => _intimacy;
  bool get isLoading => _isLoading;

  Future<void> setUserId(String? userId) async {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    
    if (userId != null) {
      // Fetch couple ID
      debugPrint('DataProvider: setUserId called with userId: $userId');
      final coupleData = await _supabaseService.getCouple(userId);
      if (coupleData != null) {
        _currentCoupleId = coupleData['id'];
        debugPrint('DataProvider: Found couple_id: $_currentCoupleId');
        await loadCoupleData();
        await fetchMenu(); // Load menu when couple is set
      } else {
        debugPrint('DataProvider: No couple found for userId: $userId');
        _currentCoupleId = null;
        _orders = [];
        _intimacy = null;
        _menuItems = [];
        notifyListeners();
      }
    } else {
      _currentCoupleId = null;
      _orders = [];
      _intimacy = null;
      _menuItems = [];
      notifyListeners();
    }
  }

  Future<void> loadInitialData() async {
    _setLoading(true);
    await fetchMenu();
    _setLoading(false);
  }

  Future<void> loadCoupleData() async {
    if (_currentCoupleId == null) return;
    _setLoading(true);
    await Future.wait([
      fetchOrders(),
      fetchIntimacy(),
    ]);
    _setLoading(false);
  }

  Future<void> fetchMenu() async {
    debugPrint('DataProvider: Fetching menu for couple_id: $_currentCoupleId');
    final data = await _supabaseService.getMenu(_currentCoupleId);
    debugPrint('DataProvider: Fetched ${data.length} menu items');
    _menuItems = data.map((e) => MenuItem.fromJson(e)).toList();
    debugPrint('DataProvider: Parsed ${_menuItems.length} menu items');
    notifyListeners();
  }

  Future<void> addMenuItem(MenuItem item) async {
    if (_currentCoupleId == null) {
      debugPrint('Cannot add menu item: No couple ID');
      return;
    }
    
    final itemData = item.toJson();
    itemData['couple_id'] = _currentCoupleId;
    
    await _supabaseService.addMenuItem(itemData);
    await fetchMenu();
  }

  Future<void> fetchOrders() async {
    if (_currentCoupleId == null) return;
    final data = await _supabaseService.getOrders(_currentCoupleId!);
    _orders = data.map((e) => Order.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> createOrder(Order order) async {
    if (_currentCoupleId == null) return;
    // Ensure order has coupleId
    final orderJson = order.toJson();
    orderJson['couple_id'] = _currentCoupleId;
    
    await _supabaseService.createOrder(orderJson);
    await fetchOrders();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    debugPrint('DataProvider: updateOrderStatus called - orderId: $orderId, status: ${status.name}');
    try {
      await _supabaseService.updateOrderStatus(orderId, status.name);
      debugPrint('DataProvider: Order status updated successfully');
      await fetchOrders();
    } catch (e) {
      debugPrint('DataProvider: Error updating order status: $e');
      rethrow;
    }
  }
  
  Future<void> rateOrder(String orderId, int rating, String comment) async {
    await _supabaseService.rateOrder(orderId, rating, comment);
    await fetchOrders();
  }

  Future<void> fetchIntimacy() async {
    if (_currentCoupleId == null) return;
    debugPrint('DataProvider: Fetching intimacy for couple_id: $_currentCoupleId');
    
    try {
      final score = await _supabaseService.getIntimacyScore(_currentCoupleId!);
      debugPrint('DataProvider: Fetched intimacy score: $score');
      _intimacy = Intimacy(score: score, level: _calculateLevel(score));
    } catch (e) {
      debugPrint('DataProvider: Error fetching intimacy: $e');
      // Handle error or no intimacy record
      _intimacy = Intimacy(score: 0, level: 1);
    }
    debugPrint('DataProvider: Intimacy set to: score=${_intimacy?.score}, level=${_intimacy?.level}');
    notifyListeners();
  }

  Future<void> updateIntimacy(int change, String reason) async {
    debugPrint('DataProvider: updateIntimacy called - couple_id: $_currentCoupleId, current intimacy: ${_intimacy?.score}, change: $change');
    
    if (_currentCoupleId == null || _intimacy == null) {
      debugPrint('DataProvider: Cannot update intimacy - couple_id or intimacy is null');
      return;
    }
    
    final newScore = _intimacy!.score + change;
    debugPrint('DataProvider: Updating intimacy score to $newScore');
    
    await _supabaseService.updateIntimacyScore(_currentCoupleId!, newScore);
    await fetchIntimacy();
    
    debugPrint('DataProvider: Intimacy updated successfully');
  }
  
  int _calculateLevel(int score) {
    return (score / 100).floor() + 1;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
