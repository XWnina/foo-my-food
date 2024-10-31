class Recipe {
  final int id; // Handles long values in Dart
  final String name;
  final List<String> ingredients;
  final int calories;
  final String? description; // Make nullable
  final String? videoLink;   // Make nullable
  final String? imageUrl;    // Make nullable

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.calories,
    this.description,  // Nullable field
    this.videoLink,    // Nullable field
    this.imageUrl,     // Nullable field
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
  return Recipe(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()), // Ensure it's handled as int
    name: json['dishName'] ?? 'Unknown',  // Provide default value if null
    ingredients: List<String>.from(json['ingredientsAsList'] ?? []),
    calories: json['calories'] ?? 0,
    description: json['description'] ?? '',  // Default to empty string if null
    videoLink: json['videoLink'] ?? '',  // Default to empty string if null
    imageUrl: json['imageURL'] ?? '',  // Default to empty string if null
  );
}


  // Method to convert a Recipe instance into a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'calories': calories,
      'description': description,
      'videoLink': videoLink,
      'imageURL': imageUrl,
    };
  }
}