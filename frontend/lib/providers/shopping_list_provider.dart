import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:foo_my_food_app/utils/constants.dart';

class ShoppingListProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _shoppingList = [];
  List<Map<String, dynamic>> get shoppingList => _shoppingList;

  String? _userId;

  ShoppingListProvider() {
    _initializeUserIdAndFetchList();
  }

  Future<void> _initializeUserIdAndFetchList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    if (_userId != null) {
      await fetchItems();
    }
  }

  Future<void> fetchItems() async {
    if (_userId == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseApiUrl/shopping-list/user/$_userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _shoppingList = List<Map<String, dynamic>>.from(data);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
  }

  Future<void> addItem(Map<String, dynamic> newItem) async {
    try {
      final response = await http.post(
        Uri.parse('$baseApiUrl/shopping-list'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ...newItem,
          'userId': _userId,
        }),
      );

      if (response.statusCode == 200) {
        _shoppingList.add(newItem);
        notifyListeners();
      }
    } catch (e) {
      print("Error adding item: $e");
    }
  }

  Future<void> togglePurchasedStatus(int foodId,
      {bool isPurchased = true}) async {
    final itemIndex =
        _shoppingList.indexWhere((item) => item['foodId'] == foodId);
    if (itemIndex == -1) {
      print("Item not found in the list");
      return;
    }

    final item = _shoppingList[itemIndex];
    item['isPurchased'] = isPurchased;

    try {
      final response = await http.put(
        Uri.parse('$baseApiUrl/shopping-list/$foodId/isPurchased'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(isPurchased), // 更新购买状态
      );

      if (response.statusCode == 200) {
        // 更新后将物品移动到对应的状态部分
        _shoppingList.removeAt(itemIndex);
        if (isPurchased) {
          _shoppingList.add(item); // 如果已购买，将其放到列表末尾
        } else {
          _shoppingList.insert(0, item); // 如果未购买，将其放到列表开头
        }
        notifyListeners();
      } else {
        print(
            "Failed to update item in backend. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating item: $e");
    }
  }

  Future<void> updateItem(Map<String, dynamic> updatedFields) async {
    final itemIndex = _shoppingList
        .indexWhere((item) => item['foodId'] == updatedFields['foodId']);
    if (itemIndex == -1) {
      print("Item not found in the list");
      return;
    }

    final existingItem = _shoppingList[itemIndex];
    final updatedItem = {
      'foodId': existingItem['foodId'],
      'userId': existingItem['userId'],
      'name': updatedFields['name'] ?? existingItem['name'],
      'baseQuantity':
          updatedFields['baseQuantity'] ?? existingItem['baseQuantity'],
      'unit': updatedFields['unit'] ?? existingItem['unit'],
      'isPurchased': existingItem['isPurchased'],
    };

    try {
      final response = await http.put(
        Uri.parse('$baseApiUrl/shopping-list/${updatedItem['foodId']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedItem),
      );

      if (response.statusCode == 200) {
        _shoppingList[itemIndex] = updatedItem;
        notifyListeners();
        print("Item updated successfully in backend and list.");
      } else {
        print(
            "Failed to update item in backend. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating item: $e");
    }
  }

  Future<void> deleteItem(int foodId) async {
    final itemIndex =
        _shoppingList.indexWhere((item) => item['foodId'] == foodId);
    if (itemIndex == -1) {
      print("Item not found in the list");
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseApiUrl/shopping-list/$foodId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204) {
        _shoppingList.removeAt(itemIndex);
        notifyListeners();
        print("Item deleted successfully from backend and list.");
      } else {
        print(
            "Failed to delete item in backend. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting item: $e");
    }
  }
}
