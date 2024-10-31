import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];
  List<int> _selectedRecipeIds = [];

  List<Recipe> get recipes => _recipes;

  List<Recipe> get selectedRecipes => _recipes
      .where((recipe) => _selectedRecipeIds.contains(recipe.id))
      .toList();

  // 设置食谱列表
  void setRecipes(List<Recipe> recipes) {
    _recipes = recipes;
    notifyListeners();
  }

  // 选择和取消选择食谱
  void toggleRecipeSelection(int recipeId) {
    if (_selectedRecipeIds.contains(recipeId)) {
      _selectedRecipeIds.remove(recipeId);
    } else {
      _selectedRecipeIds.add(recipeId);
    }
    notifyListeners();
  }

  // 计算选中食谱的卡路里总和
  int get totalCaloriesOfSelectedRecipes {
    return selectedRecipes.fold(0, (sum, recipe) => sum + recipe.calories);
  }

  // 添加新的食谱
  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    notifyListeners();
  }

  // 删除指定的食谱
  void removeRecipe(int id) {
    _recipes.removeWhere((recipe) => recipe.id == id);
    notifyListeners();
  }

  // 更新现有的食谱
  void updateRecipe(int id, Recipe updatedRecipe) {
    final index = _recipes.indexWhere((recipe) => recipe.id == id);
    if (index != -1) {
      _recipes[index] = updatedRecipe;
      notifyListeners();
    }
  }
}
