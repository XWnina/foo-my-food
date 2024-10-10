class Ingredient {
  final String name;
  final String category;
  final String imageURL;
  final String storageMethod;
  final int baseQuantity;
  final String unit;
  final String expirationDate;
  final bool isUserCreated;
  final int createdBy;
  final int calories;
  final double protein;
  final double fat;
  final double carbohydrates;
  final double fiber;

  Ingredient({
    required this.name,
    required this.category,
    required this.imageURL,
    required this.storageMethod,
    required this.baseQuantity,
    required this.unit,
    required this.expirationDate,
    required this.isUserCreated,
    required this.createdBy,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.fiber,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? 'Unknown', // 默认值
      category: json['category'] ?? 'Uncategorized', // 默认值
      imageURL: json['imageURL'] ?? '', // 默认值
      storageMethod: json['StorageMethod'] ?? 'Unknown', // 默认值
      baseQuantity: json['base_quantity'] ?? 0, // 默认值
      unit: json['unit'] ?? 'units', // 默认值
      expirationDate: json['expirationDate'] ?? 'N/A', // 默认值
      isUserCreated: json['is_user_created'] ?? false, // 默认值
      createdBy: json['created_by'] ?? 0, // 默认值
      calories: json['calories'] ?? 0, // 默认值
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0, // 处理可能的 null
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0, // 处理可能的 null
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble() ?? 0.0, // 处理可能的 null
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0, // 处理可能的 null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'imageURL': imageURL,
      'StorageMethod': storageMethod,
      'base_quantity': baseQuantity,
      'unit': unit,
      'expiration_date': expirationDate,
      'is_user_created': isUserCreated,
      'created_by': createdBy,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbohydrates,
      'fiber': fiber,
    };
  }
}