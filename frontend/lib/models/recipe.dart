import 'dart:ffi';
class Recipe {
  final Long id;
  final String name;
  final List<String> ingredients; // 确保这是 List<String>
  final int calories;
  final String description;
  final String videoLink;
  final String imageUrl;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.calories,
    required this.description,
    required this.videoLink,
    required this.imageUrl,
  });

  // Factory method to create a Recipe from a JSON object
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
      calories: json['calories'],
      description: json['description'] ?? '',
      videoLink: json['videoLink'] ?? '',
      imageUrl: json['imageURL'] ?? '',
    );
  }

  // Method to convert a Recipe instance into a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients, // 确保是数组形式
      'calories': calories,
      'description': description,
      'videoLink': videoLink,
      'imageURL': imageUrl,
    };
  }
}
