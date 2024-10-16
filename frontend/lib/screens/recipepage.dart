import 'package:flutter/material.dart';
import 'add_recipe.dart'; // 导入添加recipe的页面
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:foo_my_food_app/utils/text_style.dart';

class RecipePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('My Recipes', style: TextStyle(color: text)),
        backgroundColor: buttonBackgroundColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No recipes added yet! Click the + button to add.',
              style: AppTextStyles.headline4.copyWith(color: blackTextColor),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "AddRecipe",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipePage()),
          );
        },
        backgroundColor: buttonBackgroundColor,
        tooltip: 'Add Recipe',
        child: const Icon(Icons.add, color: whiteTextColor),
      ),
    );
  }
}
