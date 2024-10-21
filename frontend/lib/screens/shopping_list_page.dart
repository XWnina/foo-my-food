import 'package:flutter/material.dart';
import 'package:foo_my_food_app/utils/colors.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Shopping List'),
        backgroundColor: appBarColor, // 可以更改为适合你的颜色
      ),
      body: const Center(
        child: Text(
          'Your shopping list is empty!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
