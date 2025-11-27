
enum OrderStatus { pending, cooking, completed }

class Order {
  final String id;
  final String foodieId;
  final String chefId;
  final String menuItemId;
  final String menuItemName; // Denormalized for easier display
  final String menuItemImage; // Denormalized
  final OrderStatus status;
  final DateTime createdAt;
  final int? rating;
  final String? reviewComment;

  Order({
    required this.id,
    required this.foodieId,
    required this.chefId,
    required this.menuItemId,
    required this.menuItemName,
    required this.menuItemImage,
    required this.status,
    required this.createdAt,
    this.rating,
    this.reviewComment,
  });
  
  Order copyWith({
    String? id,
    String? foodieId,
    String? chefId,
    String? menuItemId,
    String? menuItemName,
    String? menuItemImage,
    OrderStatus? status,
    DateTime? createdAt,
    int? rating,
    String? reviewComment,
  }) {
    return Order(
      id: id ?? this.id,
      foodieId: foodieId ?? this.foodieId,
      chefId: chefId ?? this.chefId,
      menuItemId: menuItemId ?? this.menuItemId,
      menuItemName: menuItemName ?? this.menuItemName,
      menuItemImage: menuItemImage ?? this.menuItemImage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      reviewComment: reviewComment ?? this.reviewComment,
    );
  }
}
