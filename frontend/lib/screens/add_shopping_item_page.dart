import 'package:flutter/material.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:foo_my_food_app/providers/shopping_list_provider.dart';
import 'package:foo_my_food_app/datasource/temp_db.dart';
import 'dart:convert';

class AddShoppingItemPage extends StatefulWidget {
  const AddShoppingItemPage({super.key});

  @override
  _AddShoppingItemPageState createState() => _AddShoppingItemPageState();
}

class _AddShoppingItemPageState extends State<AddShoppingItemPage> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  String? itemError, quantityError, unitError;
  String? _selectedCategory;

  bool get isFormValid =>
      itemError == null &&
      quantityError == null &&
      unitError == null &&
      _itemController.text.isNotEmpty &&
      _quantityController.text.isNotEmpty &&
      _unitController.text.isNotEmpty;

  void _validateItemName() {
    setState(() {
      itemError =
          _itemController.text.trim().isEmpty ? 'Item name is required' : null;
    });
  }

  void _validateQuantity() {
    setState(() {
      String quantityText = _quantityController.text.trim();
      if (quantityText.isEmpty) {
        quantityError = 'Quantity is required';
      } else {
        int? quantity = int.tryParse(quantityText);
        if (quantity == null || quantity <= 0) {
          quantityError = 'Quantity must be a positive number';
        } else {
          quantityError = null;
        }
      }
    });
  }

  void _validateUnit() {
    setState(() {
      unitError =
          _unitController.text.trim().isEmpty ? 'Unit is required' : null;
    });
  }

  Future<void> _saveItem() async {
    _validateItemName();
    _validateQuantity();
    _validateUnit();

    if (!isFormValid) return;

    String name = _itemController.text.trim();
    int quantity = int.parse(_quantityController.text.trim());
    String unit = _unitController.text.trim();

    Map<String, dynamic> newItem = {
      'name': name,
      'baseQuantity': quantity,
      'unit': unit,
      'isPurchased': false,
    };

    // 如果用户选择了分类，才添加分类字段
    if (_selectedCategory != null) {
      newItem['category'] = _selectedCategory;
    }

    final response =
        await Provider.of<ShoppingListProvider>(context, listen: false)
            .addItem(newItem);

    if (response == null) {
      print("Failed to add item to backend.");
      return;
    }

    if (response.statusCode == 409) {
      print("Item already exists on the backend.");

      // 解析冲突项的详细信息
      Map<String, dynamic> conflictingItem = jsonDecode(response.body);
      _showConflictDialog(conflictingItem);
    } else if (response.statusCode == 200) {
      print("Item successfully added to backend.");
      Navigator.pop(context, newItem);
    } else {
      print("Unexpected status code from backend: ${response.statusCode}");
    }
  }

  Future<void> _addItemToShoppingList(Map<String, dynamic> newItem) async {
    await Provider.of<ShoppingListProvider>(context, listen: false)
        .addItem(newItem);
    Navigator.pop(context, newItem);
  }

  Future<void> _forceAddItemToShoppingList(Map<String, dynamic> newItem) async {
    await Provider.of<ShoppingListProvider>(context, listen: false)
        .forceAddItem(newItem);
    Navigator.pop(context, newItem);
  }

  void _showConflictDialog(Map<String, dynamic> conflictingItem) {
    print("Showing conflict dialog for item: ${conflictingItem['name']}");

    // 保存用户输入的数据
    Map<String, dynamic> userInputItem = {
      'name': _itemController.text.trim(),
      'baseQuantity': int.parse(_quantityController.text.trim()),
      'unit': _unitController.text.trim(),
      'isPurchased': false,
      // 如果需要还可以添加其他字段，例如用户ID
    };

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Item Already Exists"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  "You already have this item in your shopping list. Details:"),
              const SizedBox(height: 8),
              Text("Name: ${conflictingItem['name']}"),
              Text("Category: ${conflictingItem['category'] ?? 'N/A'}"),
              Text(
                  "Storage Method: ${conflictingItem['storageMethod'] ?? 'N/A'}"),
              Text(
                  "Expiration Date: ${conflictingItem['expirationDate'] ?? 'N/A'}"),
              Text(
                  "Quantity: ${conflictingItem['baseQuantity']} ${conflictingItem['unit']}"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.of(context).pop(); // 返回购物清单页Ï面
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                _forceAddItemToShoppingList(userInputItem); // 使用用户输入的数据
              },
              child: const Text("Add Anyway"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _itemController,
            decoration: InputDecoration(
              labelText: 'Enter item name',
              border: const OutlineInputBorder(),
              fillColor: whiteFillColor,
              filled: true,
              errorText: itemError,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: itemError != null
                        ? redErrorBorderColor
                        : greyBorderColor),
              ),
            ),
            onChanged: (_) => _validateItemName(), // 单独验证 item name
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: 'Enter quantity',
              border: const OutlineInputBorder(),
              fillColor: whiteFillColor,
              filled: true,
              errorText: quantityError,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: quantityError != null
                        ? redErrorBorderColor
                        : greyBorderColor),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _validateQuantity(), // 单独验证 quantity
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _unitController,
            decoration: InputDecoration(
              labelText: 'Enter unit',
              border: const OutlineInputBorder(),
              fillColor: whiteFillColor,
              filled: true,
              errorText: unitError,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: unitError != null
                        ? redErrorBorderColor
                        : greyBorderColor),
              ),
            ),
            onChanged: (_) => _validateUnit(), // 单独验证 unit
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Category (Optional)',
              border: const OutlineInputBorder(),
              fillColor: whiteFillColor,
              filled: true,
            ),
            value: _selectedCategory,
            items: categories
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isFormValid ? _saveItem : null, // 禁用按钮直到表单有效
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appBarColor(context),
            ),
            child: const Text(
              'Add Item',
              style: TextStyle(color: whiteTextColor),
            ),
          ),
        ],
      ),
    );
  }
}
