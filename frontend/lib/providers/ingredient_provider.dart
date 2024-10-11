// providers/ingredient_provider.dart
import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientProvider with ChangeNotifier {
  List<Ingredient> _ingredients = [];

  List<Ingredient> get ingredients => _ingredients;
  
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

  void removeIngredient(int index) {
    _ingredients.removeAt(index);
    notifyListeners();
  }
}