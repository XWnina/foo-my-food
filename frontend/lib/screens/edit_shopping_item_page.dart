import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:foo_my_food_app/providers/shopping_list_provider.dart';
import 'package:foo_my_food_app/datasource/temp_db.dart';

class EditShoppingItemPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const EditShoppingItemPage({super.key, required this.item});

  @override
  _EditShoppingItemPageState createState() => _EditShoppingItemPageState();
}

class _EditShoppingItemPageState extends State<EditShoppingItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  String? itemError, quantityError, unitError;
  String? _selectedCategory;

  bool get isFormValid =>
      itemError == null &&
      quantityError == null &&
      unitError == null &&
      _nameController.text.isNotEmpty &&
      _quantityController.text.isNotEmpty &&
      _unitController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item['name']);
    _quantityController =
        TextEditingController(text: widget.item['baseQuantity'].toString());
    _unitController = TextEditingController(text: widget.item['unit']);
    _selectedCategory = widget.item['category'];
  }

  void _validateItemName() {
    setState(() {
      itemError =
          _nameController.text.trim().isEmpty ? 'Item name is required' : null;
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
    // 调用各字段的验证方法
    _validateItemName();
    _validateQuantity();
    _validateUnit();

    if (!isFormValid) return;

    String name = _nameController.text.trim();
    int quantity = int.parse(_quantityController.text.trim());
    String unit = _unitController.text.trim();

    // 创建更新的物品数据
    Map<String, dynamic> updatedItem = {
      'foodId': widget.item['foodId'],
      'name': name,
      'baseQuantity': quantity,
      'unit': unit,
      'category': _selectedCategory, // 添加分类字段
    };
    print("Updated shopplinglist item: $updatedItem");

    // 调用后端更新方法
    await Provider.of<ShoppingListProvider>(context, listen: false)
        .updateItem(updatedItem);

    // 返回到上一页，并传递更新后的数据
    Navigator.pop(context, updatedItem);
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
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Edit item name',
              border: OutlineInputBorder(),
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
              labelText: 'Edit quantity',
              border: OutlineInputBorder(),
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
              labelText: 'Edit unit',
              border: OutlineInputBorder(),
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
              labelText: 'Edit category (optional)',
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
              'Save Changes',
              style: TextStyle(color: whiteTextColor),
            ),
          ),
        ],
      ),
    );
  }
}
