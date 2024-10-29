import 'package:flutter/material.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:foo_my_food_app/providers/shopping_list_provider.dart';

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
    // 调用各字段的验证方法
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

    await Provider.of<ShoppingListProvider>(context, listen: false)
        .addItem(newItem);
    Navigator.pop(context, newItem);
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
              labelText: 'Enter quantity',
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
              labelText: 'Enter unit',
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
          ElevatedButton(
            onPressed: isFormValid ? _saveItem : null, // 禁用按钮直到表单有效
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonBackgroundColor,
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
