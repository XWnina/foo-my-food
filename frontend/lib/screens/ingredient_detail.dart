import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:foo_my_food_app/utils/text_style.dart';
import 'package:foo_my_food_app/utils/font_weights.dart';

class FoodItemDetailPage extends StatefulWidget {
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
  FoodItemDetailPageState createState() => FoodItemDetailPageState();
}

class FoodItemDetailPageState extends State<FoodItemDetailPage> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _expirationDateController;
  late TextEditingController _quantityController;
  late Map<String, TextEditingController> _nutritionControllers;
  String? _selectedCategory;
  String? _selectedStorageMethod;

  final List<String> _categories = ['Vegetables', 'Fruits', 'Meat', 'Dairy', 'Grains', 'Spices', 'Beverages'];
  final List<String> _storageMethods = ['Refrigerator', 'Freezer', 'Pantry', 'Room Temperature'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _expirationDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.expirationDate));
    _quantityController = TextEditingController(text: widget.quantity.toString());
    _nutritionControllers = widget.nutritionInfo.map((key, value) => MapEntry(key, TextEditingController(text: value)));

    _selectedCategory = _categories.contains(widget.category)
        ? widget.category
        : _categories.first;

    _selectedStorageMethod = _storageMethods.contains(widget.storageMethod)
        ? widget.storageMethod
        : _storageMethods.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _expirationDateController.dispose();
    _quantityController.dispose();
    _nutritionControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.expirationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != widget.expirationDate) {
      setState(() {
        _expirationDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                    )
                  : Text(
                      widget.name,
                      style: AppTextStyles.headline4,
                    ),
              const SizedBox(height: 16),
              _isEditing
                  ? DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    )
                  : _buildInfoRow(context, 'Category', widget.category),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _expirationDateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: const InputDecoration(
                        labelText: 'Expiration Date',
                        border: OutlineInputBorder(),
                      ),
                    )
                  : _buildInfoRow(context, 'Expiration Date', DateFormat('yyyy-MM-dd').format(widget.expirationDate)),
              const SizedBox(height: 16),
              _isEditing
                  ? DropdownButtonFormField<String>(
                      value: _selectedStorageMethod,
                      items: _storageMethods.map((String method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStorageMethod = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Storage Method',
                        border: OutlineInputBorder(),
                      ),
                    )
                  : _buildInfoRow(context, 'Storage Method', widget.storageMethod),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                    )
                  : _buildInfoRow(context, 'Quantity', widget.quantity.toString()),
              const SizedBox(height: 24),
              const Text(
                'Nutrition Information',
                style: AppTextStyles.headline6,
              ),
              const SizedBox(height: 8),
              ...widget.nutritionInfo.keys.map(
                (key) => _buildNutritionRow(
                  context,
                  key,
                  _nutritionControllers[key]!,
                  editable: _isEditing,
                ),
              ),
            ],
          ),
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

  Widget _buildNutritionRow(BuildContext context, String nutrient, TextEditingController controller,
      {required bool editable}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nutrient,
            style: AppTextStyles.bodyText2,
          ),
          editable
              ? SizedBox(
                  width: 100, // 限制 TextField 宽度
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                )
              : Text(
                  controller.text,
                  style: AppTextStyles.bodyText2.copyWith(fontWeight: AppFontWeight.semiBold),
                ),
        ],
      ),
    );
  }
}
