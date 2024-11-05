import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:foo_my_food_app/utils/constants.dart';

class ShoppingListProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _shoppingList = [];
  List<Map<String, dynamic>> get shoppingList => _shoppingList;

  // 从 SharedPreferences 动态获取 userId
  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // 初始化购物清单，清空之前的数据并加载当前用户的数据
  Future<void> initializeShoppingList() async {
    _shoppingList.clear(); // 清空旧用户的数据
    notifyListeners(); // 通知 UI 更新为空列表

    // 获取当前用户的数据
    String? userId = await _getUserId();
    if (userId != null) {
      await fetchItems(); // 加载当前用户的购物清单数据
    }
  }

  Future<void> fetchItems() async {
    String? userId = await _getUserId();
    if (userId == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseApiUrl/my-shopping-list/user/$userId'),
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
    String? userId = await _getUserId();
    if (userId == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseApiUrl/my-shopping-list'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ...newItem,
          'userId': userId,
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

  Future<void> togglePurchasedStatus(int foodId, {bool isPurchased = true}) async {
    String? userId = await _getUserId();
    if (userId == null) return;

    final itemIndex = _shoppingList.indexWhere((item) => item['foodId'] == foodId);
    if (itemIndex == -1) {
      print("Item not found in the list");
      return;
    }

    final item = _shoppingList[itemIndex];
    item['isPurchased'] = isPurchased;

    try {
      final response = await http.put(
        Uri.parse('$baseApiUrl/my-shopping-list/$foodId/user/$userId/isPurchased'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(isPurchased),
      );

      if (response.statusCode == 200) {
        _shoppingList.removeAt(itemIndex);
        if (isPurchased) {
          _shoppingList.add(item);
        } else {
          _shoppingList.insert(0, item);
        }
        notifyListeners();
      } else {
        print("Failed to update item in backend. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating item: $e");
    }
  }

  Future<void> updateItem(Map<String, dynamic> updatedFields) async {
    String? userId = await _getUserId();
    if (userId == null) return;

    final itemIndex = _shoppingList.indexWhere((item) => item['foodId'] == updatedFields['foodId']);
    if (itemIndex == -1) {
      print("Item not found in the list");
      return;
    }

    final existingItem = _shoppingList[itemIndex];
    final updatedItem = {
      'foodId': existingItem['foodId'],
      'userId': existingItem['userId'],
      'name': updatedFields['name'] ?? existingItem['name'],
      'baseQuantity': updatedFields['baseQuantity'] ?? existingItem['baseQuantity'],
      'unit': updatedFields['unit'] ?? existingItem['unit'],
      'isPurchased': existingItem['isPurchased'],
    };

    try {
      final response = await http.put(
        Uri.parse('$baseApiUrl/my-shopping-list/${updatedItem['foodId']}/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedItem),
      );

      if (response.statusCode == 200) {
        _shoppingList[itemIndex] = updatedItem;
        notifyListeners();
      } else {
        print("Failed to update item in backend. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating item: $e");
    }
  }

  Future<void> deleteItem(int foodId) async {
    String? userId = await _getUserId();
    if (userId == null) return;

    final itemIndex = _shoppingList.indexWhere((item) => item['foodId'] == foodId);
    if (itemIndex == -1) {
      print("Item not found in the list");
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseApiUrl/my-shopping-list/$foodId/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204) {
        _shoppingList.removeAt(itemIndex);
        notifyListeners();
      } else {
        print("Failed to delete item in backend. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting item: $e");
    }
  }
}
