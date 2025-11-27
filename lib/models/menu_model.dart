
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
}

class RecipeStep {
  final String description;
  final String? imageUrl;

  RecipeStep({required this.description, this.imageUrl});
}
