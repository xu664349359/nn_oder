import 'package:flutter/foundation.dart';
import '../models/menu_model.dart';
import '../models/order_model.dart';
import '../models/intimacy_model.dart';
import '../services/mock_data_service.dart';

class DataProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService();
  
  List<MenuItem> _menuItems = [];
  List<Order> _orders = [];
  Intimacy? _intimacy;
  bool _isLoading = false;

  List<MenuItem> get menuItems => _menuItems;
  List<Order> get orders => _orders;
  Intimacy? get intimacy => _intimacy;
  bool get isLoading => _isLoading;

  Future<void> loadInitialData() async {
    _setLoading(true);
    // Initialize dummy data if empty
    if (_menuItems.isEmpty) {
      _dataService.initDummyData();
    }
    
    await Future.wait([
      fetchMenu(),
      fetchOrders(),
      fetchIntimacy(),
    ]);
    _setLoading(false);
  }

  Future<void> fetchMenu() async {
    _menuItems = await _dataService.getMenu();
    notifyListeners();
  }

  Future<void> addMenuItem(MenuItem item) async {
    await _dataService.addMenuItem(item);
    await fetchMenu();
  }

  Future<void> fetchOrders() async {
    _orders = await _dataService.getOrders();
    notifyListeners();
  }

  Future<void> createOrder(Order order) async {
    await _dataService.createOrder(order);
    await fetchOrders();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _dataService.updateOrderStatus(orderId, status);
    await fetchOrders();
  }
  
  Future<void> rateOrder(String orderId, int rating, String comment) async {
    await _dataService.rateOrder(orderId, rating, comment);
    await fetchOrders();
  }

  Future<void> fetchIntimacy() async {
    _intimacy = await _dataService.getIntimacy();
    notifyListeners();
  }

  Future<void> updateIntimacy(int change, String reason) async {
    await _dataService.updateIntimacy(change, reason);
    await fetchIntimacy();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
