
class MenuItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int intimacyPrice;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final bool isPublished;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.intimacyPrice,
    required this.ingredients,
    required this.steps,
    this.isPublished = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      intimacyPrice: json['intimacy_price'] ?? 0,
      ingredients: json['ingredients'] is List 
          ? List<String>.from(json['ingredients']) 
          : [],
      steps: [], // Steps loaded separately from recipe_steps table
      isPublished: json['is_published'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'intimacy_price': intimacyPrice,
      'ingredients': ingredients, // Store as JSONB array
      'is_published': isPublished,
      // Note: steps are stored in separate recipe_steps table, not in menu table
    };
  }
}

class RecipeStep {
  final String? id;
  final int stepNumber;
  final String description;
  final String? imageUrl;
  final String? videoUrl;

  RecipeStep({
    this.id,
    required this.stepNumber,
    required this.description,
    this.imageUrl,
    this.videoUrl,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id'],
      stepNumber: json['stepNumber'] ?? json['step_number'] ?? 0,
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      videoUrl: json['videoUrl'] ?? json['video_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'step_number': stepNumber,
      'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (videoUrl != null) 'video_url': videoUrl,
    };
  }

  RecipeStep copyWith({
    String? id,
    int? stepNumber,
    String? description,
    String? imageUrl,
    String? videoUrl,
  }) {
    return RecipeStep(
      id: id ?? this.id,
      stepNumber: stepNumber ?? this.stepNumber,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
