// providers/ingredient_provider.dart
import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientProvider with ChangeNotifier {
  List<Ingredient> _ingredients = [];
  List<String> _selectedCategories = [];

  List<Ingredient> get ingredients => _ingredients;
  List<String> get selectedCategories => _selectedCategories;
  
  set ingredients(List<Ingredient> newIngredients) {
    _ingredients = newIngredients; // Setter to update the ingredient list
    notifyListeners(); // Notify listeners about the change
  }

  void addIngredient(Ingredient ingredient) {
    _ingredients.add(ingredient);
    notifyListeners();
  }

  void updateIngredient(int index, Ingredient ingredient) {
    _ingredients[index] = ingredient;
    notifyListeners();
  }
  set selectedCategories(List<String> categories) {
    _selectedCategories = categories;
    notifyListeners(); // 确保 UI 更新
  }

  void removeIngredient(int index) {
    _ingredients.removeAt(index);
    notifyListeners();
  }
}