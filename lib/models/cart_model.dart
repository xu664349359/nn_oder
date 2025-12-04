import 'menu_model.dart';

class CartItem {
  final String id;
  final String userId;
  final String menuItemId;
  final MenuItem menuItem;
  final int quantity;
  final bool washDishes;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.userId,
    required this.menuItemId,
    required this.menuItem,
    required this.quantity,
    this.washDishes = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculated fields
  int get basePrice => menuItem.intimacyPrice * quantity;
  int get discount => washDishes ? (basePrice * 0.2).round() : 0;
  int get finalPrice => basePrice - discount;

  factory CartItem.fromJson(Map<String, dynamic> json, MenuItem menuItem) {
    return CartItem(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      menuItemId: json['menu_item_id'] ?? '',
      menuItem: menuItem,
      quantity: json['quantity'] ?? 1,
      washDishes: json['wash_dishes'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  CartItem copyWith({
    int? quantity,
    bool? washDishes,
  }) {
    return CartItem(
      id: id,
      userId: userId,
      menuItemId: menuItemId,
      menuItem: menuItem,
      quantity: quantity ?? this.quantity,
      washDishes: washDishes ?? this.washDishes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class Cart {
  final List<CartItem> items;

  Cart({this.items = const []});

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  int get totalBasePrice => items.fold(0, (sum, item) => sum + item.basePrice);
  int get totalDiscount => items.fold(0, (sum, item) => sum + item.discount);
  int get totalFinalPrice => items.fold(0, (sum, item) => sum + item.finalPrice);
}
