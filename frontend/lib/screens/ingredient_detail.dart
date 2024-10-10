import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';
class FoodItemDetailPage extends StatefulWidget {
  final UserIngredient ingredient; // 更新为 UserIngredient
  final int userId;

  const FoodItemDetailPage({
    Key? key,
    required this.ingredient,
    required this.userId,
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.name);
    _expirationDateController = TextEditingController(text: widget.ingredient.expirationDate);
    _quantityController = TextEditingController(text: widget.ingredient.quantity.toString());
    _nutritionControllers = widget.ingredient.nutritionInfo.map((key, value) => MapEntry(key, TextEditingController(text: value)));
  }

  Future<void> _saveChanges() async {
    final String apiUrl = 'http://your-api-url/api/user-ingredients/${widget.userId}/${widget.ingredient.name}';

    final response = await http.put(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'name': _nameController.text,
        'expirationDate': _expirationDateController.text,
        'quantity': int.parse(_quantityController.text),
        'nutritionInfo': _nutritionControllers.map((key, controller) => MapEntry(key, controller.text)),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save changes')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ingredient.name),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
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
                widget.ingredient.imageUrl,
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
                      widget.ingredient.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _expirationDateController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateFormat('yyyy-MM-dd').parse(widget.ingredient.expirationDate),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _expirationDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Expiration Date', border: OutlineInputBorder()),
                    )
                  : Text('Expires on: ${widget.ingredient.expirationDate}'),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                    )
                  : Text('Quantity: ${widget.ingredient.quantity}'),
              const SizedBox(height: 24),
              const Text('Nutrition Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...widget.ingredient.nutritionInfo.keys.map(
                (key) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(key),
                    _isEditing
                        ? SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _nutritionControllers[key],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          )
                        : Text(widget.ingredient.nutritionInfo[key]!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}