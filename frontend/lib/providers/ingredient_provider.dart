// providers/ingredient_provider.dart
import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientProvider with ChangeNotifier {
  List<Ingredient> _ingredients = [];
  List<String> _selectedCategories = [];
  bool _showExpirationAlert = false;

  List<Ingredient> get ingredients => _ingredients;
  List<String> get selectedCategories => _selectedCategories;
  bool get showExpirationAlert => _showExpirationAlert; // Getter for dialog status

  set ingredients(List<Ingredient> newIngredients) {
    _ingredients = newIngredients; // Setter to update the ingredient list
    notifyListeners(); // Notify listeners about the change
  }
  set showExpirationAlert(bool value) {
    if (_showExpirationAlert != value) {
      _showExpirationAlert = value;
      notifyListeners(); // 确保在状态变化时通知 UI
    }
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
  void removeIngredient_F(Ingredient ingredient) {
  _ingredients.remove(ingredient);
  notifyListeners();
}
}