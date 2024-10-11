import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:foo_my_food_app/datasource/temp_db.dart'; // For food categories and storage methods
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foo_my_food_app/utils/helper_function.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddIngredientPage extends StatefulWidget {
  @override
  _AddIngredientPageState createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  File? _image;
  String? _selectedCategory;
  String? _selectedStorageMethod;
  int _quantity = 1;
  DateTime _expirationDate = DateTime.now();
  String _ingredientId = '';
  String _ingredientName = '';
  String _unit = ''; // Unit of measurement
  double _calories = 0; // Calories
  double _protein = 0; // Protein
  double _fat = 0; // Fat
  double _carbohydrates = 0; // Carbohydrates
  double _fiber = 0; // Fiber

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Update image file
      });
    }
  }

  Future<void> _selectExpirationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: TextStyle(color: redErrorTextColor))));
  }

  Future<void> _addIngredient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      _showError('User ID not found');
      return;
    }

    if (_ingredientName.isEmpty || _selectedCategory == null || _selectedStorageMethod == null || _unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    const String ingredientApiUrl = '$baseApiUrl/ingredients';

    final ingredientData = {
      'id': _ingredientId,
      'name': _ingredientName,
      'category': _selectedCategory,
      'imageURL': _image?.path,
      'storageMethod': _selectedStorageMethod,
      'baseQuantity': _quantity,
      'unit': _unit,
      //'expirationDate': _expirationDate.toIso8601String(),
      'expirationDate': DateFormat('yyyy-MM-dd').format(_expirationDate),
      'isUserCreated': true,
      'createdBy': userId,
      'calories': _calories,
      'protein': _protein,
      'fat': _fat,
      'carbohydrates': _carbohydrates,
      'fiber': _fiber,
    };

    try {
      final ingredientResponse = await http.post(
        Uri.parse(ingredientApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ingredientData),
      );

      if (ingredientResponse.statusCode == 201) {
        final createdIngredient = jsonDecode(ingredientResponse.body);
        final ingredientId = createdIngredient['ingredientId'];

        const String userIngredientApiUrl = '$baseApiUrl/user_ingredients';

        final userIngredientData = {
          'userId': userId,
          'ingredientId': ingredientId,
          'userQuantity': _quantity,
        };

        final userIngredientResponse = await http.post(
          Uri.parse(userIngredientApiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(userIngredientData),
        );

        if (userIngredientResponse.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingredient added successfully!')),
          );
          // Clear form or navigate back
          setState(() {
            _ingredientId ='';
            _ingredientName = '';
            _image = null;
            _selectedCategory = null;
            _selectedStorageMethod = null;
            _quantity = 1;
            _expirationDate = DateTime.now();
            _unit = '';
            _calories = 0;
            _protein = 0;
            _fat = 0;
            _carbohydrates = 0;
            _fiber = 0;
          });
        } else {
          throw Exception('Failed to add ingredient to user ingredients');
        }
      } else {
        throw Exception('Failed to create ingredient');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Add food'),
        backgroundColor: appBarColor,
      ),
      body: SingleChildScrollView( // Added for scrolling
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Ingredient Name
              TextField(
                decoration: InputDecoration(hintText: 'Enter Ingredient Name'),
                onChanged: (value) {
                  setState(() {
                    _ingredientName = value;
                  });
                },
              ),
              SizedBox(height: 16),

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: _image != null
                    ? Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover)
                    : Container(height: 100, width: 100, color: Colors.grey[300], child: Icon(Icons.camera_alt)),
              ),
              SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: foodCategories.map((String category) {
                  return DropdownMenuItem<String>(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: 16),

              // Storage Method Dropdown
              DropdownButtonFormField<String>(
                value: _selectedStorageMethod,
                items: storageMethods.map((String method) {
                  return DropdownMenuItem<String>(value: method, child: Text(method));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStorageMethod = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Storage method'),
              ),
              SizedBox(height: 16),

              // Quantity Input (Only Manual Input)
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Quantity'),
                onChanged: (value) {
                  setState(() {
                    _quantity = int.tryParse(value) ?? 1; // Default to 1 if parsing fails
                  });
                },
              ),
              SizedBox(height: 16),
              // Unit Input
              TextField(
                decoration: InputDecoration(hintText: 'Unit (e.g., grams, liters)'),
                onChanged: (value) {
                  setState(() {
                    _unit = value;
                  });
                },
              ),
              SizedBox(height: 16),
              // Expiration Date Picker
              GestureDetector(
                onTap: () => _selectExpirationDate(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Expiration date: ${_expirationDate.toLocal().toString().split(' ')[0]}'), // Display formatted date
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Nutritional Information Inputs
              TextField(
                decoration: InputDecoration(hintText: 'Calories'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _calories = double.tryParse(value) ?? 0;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(hintText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _protein = double.tryParse(value) ?? 0;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(hintText: 'Fat (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _fat = double.tryParse(value) ?? 0;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(hintText: 'Carbohydrates (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _carbohydrates = double.tryParse(value) ?? 0;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(hintText: 'Fiber (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _fiber = double.tryParse(value) ?? 0;
                  });
                },
              ),
              SizedBox(height: 16),

              // Add Button
              ElevatedButton(
                onPressed: _addIngredient,
                child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}