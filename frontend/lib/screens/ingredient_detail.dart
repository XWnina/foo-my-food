import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:foo_my_food_app/utils/text_style.dart';
import 'package:foo_my_food_app/utils/font_weights.dart';

class FoodItemDetailPage extends StatelessWidget {
  final String name;
  final String imageUrl;
  final DateTime expirationDate;
  final Map<String, String> nutritionInfo;
  final String category;
  final String storageMethod;
  final int quantity;

  const FoodItemDetailPage({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.expirationDate,
    required this.nutritionInfo,
    required this.category,
    required this.storageMethod,
    required this.quantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.headline4,
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow(context, 'Category', category),
                  _buildInfoRow(context, 'Expiration Date', DateFormat('yyyy-MM-dd').format(expirationDate)),
                  _buildInfoRow(context, 'Storage Method', storageMethod),
                  _buildInfoRow(context, 'Quantity', quantity.toString()),
                  SizedBox(height: 24),
                  Text(
                    'Nutrition Information',
                    style: AppTextStyles.headline6,
                  ),
                  SizedBox(height: 8),
                  ...nutritionInfo.entries.map((entry) => _buildNutritionRow(context, entry.key, entry.value)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.subtitle1.copyWith(fontWeight: AppFontWeight.semiBold),
          ),
          Text(
            value,
            style: AppTextStyles.subtitle1,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(BuildContext context, String nutrient, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nutrient,
            style: AppTextStyles.bodyText2,
          ),
          Text(
            value,
            style: AppTextStyles.bodyText2.copyWith(fontWeight: AppFontWeight.semiBold),
          ),
        ],
      ),
    );
  }
}