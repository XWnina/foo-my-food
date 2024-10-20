import 'package:flutter/material.dart';
import 'package:foo_my_food_app/utils/colors.dart';

class AddShoppingItemPage extends StatefulWidget {
  @override
  _AddShoppingItemPageState createState() => _AddShoppingItemPageState();
}

class _AddShoppingItemPageState extends State<AddShoppingItemPage> {
  final TextEditingController _itemController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  // 模拟保存物品的方法，可以根据实际逻辑进行修改
  void _saveItem() {
    String newItem = _itemController.text.trim();
    if (newItem.isNotEmpty) {
      // 打印新物品，也可以保存到全局状态管理中或者调用API
      print("New shopping item added: $newItem");

      // 清空输入框
      _itemController.clear();

      // 返回到购物清单页面，并传递新添加的物品数据
      Navigator.pop(context, newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Add Shopping Item'),
        backgroundColor: appBarColor, // 你可以根据需要修改背景颜色
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _itemController,
              decoration: const InputDecoration(
                labelText: 'Enter item name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveItem,
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
