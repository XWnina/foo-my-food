class Recipe {
  final int id;
  final String name;
  final int cookCount;
  final List<String> ingredients;
  final int calories;
  final String? labels;
  final String? description;
  final String? videoLink;
  final String? imageUrl;

  Recipe({
    required this.id,
    required this.cookCount,
    required this.name,
    required this.ingredients,
    required this.calories,
    this.labels,
    this.description,
    this.videoLink,
    this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Highlight: Added helper function to handle different ingredient formats
    List<String> parseIngredients(dynamic ingredientsData) {
      if (ingredientsData is List) {
        return List<String>.from(ingredientsData);
      } else if (ingredientsData is String) {
        return ingredientsData.split(',').map((e) => e.trim()).toList();
      }
      return [];
    }

    return Recipe(
      // Highlight: Handle both 'id' and '_id' fields
      id: json['id'] is int
          ? json['id']
          : int.parse((json['id'] ?? json['_id'] ?? '0').toString()),
      // Highlight: Handle both 'cookCount' and 'cook_count' fields
      cookCount: json['cookCount'] ?? json['cook_count'] ?? 0,
      // Highlight: Handle both 'name' and 'dishName' fields
      name: json['name'] ?? json['dishName']?? json['recipeName'] ?? 'Unknown',
      // Highlight: Handle different ingredient formats
      ingredients: parseIngredients(json['ingredients'] ?? json['ingredientsAsList'] ?? json['ingredient']),
      // Highlight: Handle both 'labels' and 'label' fields
      labels: json['labels'] ?? json['label'] ?? '',
      // Highlight: Handle both 'calories' and 'calorie' fields
      calories: json['calories'] ?? json['calorie'] ?? 0,
      description: json['description'] ?? '',
      videoLink: json['videoLink'] ?? '',
      // Highlight: Handle both 'imageURL' and 'image' fields
      imageUrl: json['imageURL'] ?? json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cookCount': cookCount,
      'name': name,
      // Highlight: Join ingredients list into a comma-separated string
      'ingredients': ingredients.join(', '),
      'labels': labels,
      'calories': calories,
      'description': description,
      'videoLink': videoLink,
      'imageURL': imageUrl,
    };
  }
}