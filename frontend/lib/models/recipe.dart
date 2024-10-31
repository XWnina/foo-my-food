class Recipe {
  final int id;
  final String name;
  final List<String> ingredients;
  final int calories;
  final String? description;
  final String? videoLink;
  final String? imageUrl;
  final List<String>? labels;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.calories,
    this.labels,
    this.description,
    this.videoLink,
    this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['dishName'] ?? 'Unknown',
      ingredients: List<String>.from(json['ingredientsAsList'] ?? []),
      labels: List<String>.from(json['labels'] ?? []),
      calories: json['calories'] ?? 0,
      description: json['description'] ?? '',
      videoLink: json['videoLink'] ?? '',
      imageUrl: json['imageURL'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
