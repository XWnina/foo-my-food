import 'package:flutter/foundation.dart';
import 'package:foo_my_food_app/models/collection_item.dart';

class CollectionProvider with ChangeNotifier {
  List<CollectionItem> _favorites = [];

  List<CollectionItem> get favorites => _favorites;

  // 设置初始收藏列表
  void setFavorites(List<CollectionItem> favorites) {
    _favorites = favorites;
    notifyListeners();
  }

  // 添加收藏，避免重复
  void addFavorite(CollectionItem item) {
    if (!_favorites.any((favorite) => favorite.id == item.id)) {
      _favorites.add(item);
      notifyListeners();
    }
  }

  // 删除收藏
  void removeFavorite(CollectionItem item) {
    _favorites.removeWhere((favorite) => favorite.id == item.id);
    notifyListeners();
  }
}
