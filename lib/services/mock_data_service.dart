import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/menu_model.dart';
import '../models/order_model.dart';
import '../models/intimacy_model.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final Uuid _uuid = const Uuid();

  // In-memory storage
  List<User> _users = [];
  List<MenuItem> _menuItems = [];
  List<Order> _orders = [];
  Intimacy _intimacy = Intimacy(score: 0, level: 1, history: []);

  // Simulate delay
  Future<void> _delay() async => await Future.delayed(const Duration(milliseconds: 500));

  // --- Auth & User ---
  Future<User> register(String phoneNumber, String password, String nickname, UserRole role) async {
    await _delay();
    // Check if phone already exists
    if (_users.any((u) => u.phoneNumber == phoneNumber)) {
      throw Exception('Phone number already registered');
    }
    final user = User(
      id: _uuid.v4(),
      nickname: nickname,
      role: role,
      invitationCode: role == UserRole.chef ? _generateInvitationCode() : null,
      phoneNumber: phoneNumber,
      password: password,
    );
    _users.add(user);
    return user;
  }

  Future<User?> login(String phoneNumber, String password) async {
    await _delay();
    try {
      return _users.firstWhere((u) => u.phoneNumber == phoneNumber && u.password == password);
    } catch (e) {
      return null;
    }
  }

  Future<bool> bindCouple(String foodieId, String invitationCode) async {
    await _delay();
    try {
      final chef = _users.firstWhere((u) => u.role == UserRole.chef && u.invitationCode == invitationCode);
      final foodieIndex = _users.indexWhere((u) => u.id == foodieId);
      
      if (foodieIndex != -1) {
        _users[foodieIndex] = _users[foodieIndex].copyWith(partnerId: chef.id);
        // Also update chef
        final chefIndex = _users.indexOf(chef);
        _users[chefIndex] = _users[chefIndex].copyWith(partnerId: foodieId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  String _generateInvitationCode() {
    return (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
  }

  // --- Menu ---
  Future<List<MenuItem>> getMenu() async {
    await _delay();
    return _menuItems;
  }

  Future<void> addMenuItem(MenuItem item) async {
    await _delay();
    _menuItems.add(item);
  }

  // --- Orders ---
  Future<List<Order>> getOrders() async {
    await _delay();
    return _orders;
  }

  Future<void> createOrder(Order order) async {
    await _delay();
    _orders.add(order);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _delay();
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
    }
  }
  
  Future<void> rateOrder(String orderId, int rating, String comment) async {
    await _delay();
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(rating: rating, reviewComment: comment);
    }
  }

  // --- Intimacy ---
  Future<Intimacy> getIntimacy() async {
    await _delay();
    return _intimacy;
  }

  Future<void> updateIntimacy(int change, String reason) async {
    await _delay();
    final newHistory = List<IntimacyRecord>.from(_intimacy.history)
      ..insert(0, IntimacyRecord(
        id: _uuid.v4(),
        change: change,
        reason: reason,
        timestamp: DateTime.now(),
      ));
    
    _intimacy = _intimacy.copyWith(
      score: _intimacy.score + change,
      history: newHistory,
    );
  }
  
  // Initialize with some dummy data
  void initDummyData() {
    _menuItems = [
      MenuItem(
        id: '1',
        name: 'Love Pasta',
        description: 'Creamy tomato pasta made with love.',
        imageUrl: 'assets/images/pasta.jpg', // Placeholder
        intimacyPrice: 50,
        ingredients: ['Pasta', 'Tomato', 'Cream', 'Love'],
        steps: [RecipeStep(stepNumber: 1, description: 'Boil pasta'), RecipeStep(stepNumber: 2, description: 'Mix sauce')],
      ),
      MenuItem(
        id: '2',
        name: 'Sweet Pancakes',
        description: 'Fluffy pancakes with honey.',
        imageUrl: 'assets/images/pancakes.jpg', // Placeholder
        intimacyPrice: 30,
        ingredients: ['Flour', 'Milk', 'Eggs', 'Honey'],
        steps: [RecipeStep(stepNumber: 1, description: 'Mix batter'), RecipeStep(stepNumber: 2, description: 'Cook on pan')],
      ),
    ];
  }
}
