import 'package:flutter/material.dart';
import 'package:foo_my_food_app/models/collection_item.dart';
import 'package:foo_my_food_app/models/recipe.dart';  // 确保正确引入路径

class UserFavorites with ChangeNotifier {
  List<CollectionItem> _favorites = [];

  List<CollectionItem> get favorites => _favorites;
  final Set<String> _favoriteRecipeKeys = {};

  Set<String> get favoriteRecipeKeys => _favoriteRecipeKeys;

  void toggleFavorite(String userId, Recipe recipe, bool isPresetRecipe) {
    final String key = isPresetRecipe ? 'preset_${recipe.id}' : 'my_${recipe.id}';
    if (_favoriteRecipeKeys.contains(key)) {
      _favoriteRecipeKeys.remove(key);
    } else {
      _favoriteRecipeKeys.add(key);
    }
    notifyListeners();
  }

  bool isFavorite(String recipeKey) {
    return _favoriteRecipeKeys.contains(recipeKey);
  }

  // 设置收藏列表
  void setFavorites(Set<String> favorites) {
    _favoriteRecipeKeys.clear();
    _favoriteRecipeKeys.addAll(favorites);
    notifyListeners(); // 通知所有监听者更新
  }

  // 添加收藏
  void addFavorite(CollectionItem item) {
    _favorites.add(item);
    notifyListeners();  // 通知所有监听者更新
  }

  // 移除收藏
  void removeFavorite(CollectionItem item) {
    _favorites.remove(item);
    notifyListeners();  // 通知所有监听者更新
  }
}
