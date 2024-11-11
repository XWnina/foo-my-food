class Recipe {
  final int id; // Handles long values in Dart
  final String name;
  final int cookCount;
  final List<String> ingredients;
  final int calories;
  final String? labels; // Default value
  final String? description; // Make nullable
  final String? videoLink; // Make nullable
  final String? imageUrl; // Make nullable

  Recipe({
    required this.id,
    required this.cookCount,
    required this.name,
    required this.ingredients,
    required this.calories,
    this.labels, // Default value
    this.description, // Nullable field
    this.videoLink, // Nullable field
    this.imageUrl, // Nullable field
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] is int
          ? json['id']
          : int.parse(json['id'].toString()), // Ensure it's handled as int
      cookCount: json['cookCount'] ?? 0, // 设置默认值为0
      name: json['dishName'] ?? 'Unknown', // Provide default value if null
      ingredients: List<String>.from(json['ingredientsAsList'] ?? []),
      labels: json['labels'] ?? '', // Default to empty string if null
      calories: json['calories'] ?? 0,
      description: json['description'] ?? '', // Default to empty string if null
      videoLink: json['videoLink'] ?? '', // Default to empty string if null
      imageUrl: json['imageURL'] ?? '', // Default to empty string if null
    );
  }

  // Method to convert a Recipe instance into a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cookCount': cookCount, // 确保字段名与后端一致
      'name': name,
      'ingredients': ingredients,
      'labels': labels,
      'calories': calories,
      'description': description,
      'videoLink': videoLink,
      'imageURL': imageUrl,
    };
  }
}
