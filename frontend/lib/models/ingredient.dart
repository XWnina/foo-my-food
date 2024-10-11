import 'package:flutter/material.dart';

class Ingredient with ChangeNotifier {
  int ingredientId; // 确保这个字段在 JSON 中是可用的
  String name;
  String imageURL;
  String expirationDate;
  int baseQuantity;
  String unit;
  double calories;
  double protein;
  double fat;
  double carbohydrates;
  double fiber;

  Ingredient({
    required this.ingredientId,
    required this.name,
    required this.imageURL,
    required this.expirationDate,
    required this.baseQuantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.fiber,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    // 检查 id 是否为 null 并处理
    if (json['ingredientId'] == null) {
      throw Exception('Ingredient ID cannot be null');
    }

    return Ingredient(
      ingredientId: json['ingredientId'], // 从 JSON 中解析 id
      name: json['name'] ?? '', // 提供默认值
      imageURL: json['imageURL'] ?? '',
      expirationDate: json['expirationDate'] ?? '',
      baseQuantity: json['baseQuantity'] ?? 0,
      unit: json['unit'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      carbohydrates: (json['carbohydrates'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': ingredientId,
      'name': name,
      'imageURL': imageURL,
      'expirationDate': expirationDate,
      'baseQuantity': baseQuantity,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbohydrates,
      'fiber': fiber,
    };
  }

  void update(Ingredient newIngredient) {
    name = newIngredient.name;
    expirationDate = newIngredient.expirationDate;
    baseQuantity = newIngredient.baseQuantity;
    calories = newIngredient.calories;
    protein = newIngredient.protein;
    fat = newIngredient.fat;
    carbohydrates = newIngredient.carbohydrates;
    fiber = newIngredient.fiber;
    imageURL = newIngredient.imageURL;
    notifyListeners(); // Notify listeners about the change
  }
}
