import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foo_my_food_app/screens/homepage.dart';
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
  const AddIngredientPage({super.key});

  @override
  _AddIngredientPageState createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  File? _image;
  String? _selectedCategory;
  String? _selectedStorageMethod;
  int _quantity = 1;
  bool _isQuantityValid = true; // 用于跟踪数量输入是否有效
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
      File imageFile = File(pickedFile.path);
      int imageSize = imageFile.lengthSync();

      if (imageSize > 1048576) {
        // 如果图片大小超过1MB，显示错误提示
        _showError('Image size exceeds 1MB. Please select a smaller image.');
      } else {
        setState(() {
          _image = imageFile; // 图片符合大小要求，更新 image 文件
        });
      }
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: redErrorTextColor)),
      ),
    );
  }

  Future<void> _addIngredient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      _showError('User ID not found');
      return;
    }

    if (_ingredientName.isEmpty || _selectedCategory == null || _selectedStorageMethod == null || _unit.isEmpty || !_isQuantityValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      // 1. 上传图片并获取图片URL
      String? imageUrl;
      if (_image != null) {
        var request = http.MultipartRequest('POST', Uri.parse('$baseApiUrl/ingredients/upload_image'));
        request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await http.Response.fromStream(response);
          var jsonResponse = jsonDecode(responseBody.body);
          imageUrl = jsonResponse['imageUrl'];
        } else {
          throw Exception('Failed to upload image');
        }
      }

      // 2. 创建 Ingredient 并传递 imageURL
      const String ingredientApiUrl = '$baseApiUrl/ingredients';

      final ingredientData = {
        'name': _ingredientName,
        'category': _selectedCategory,
        'imageURL': imageUrl, // 使用上传后的图片 URL
        'storageMethod': _selectedStorageMethod,
        'baseQuantity': _quantity,
        'unit': _unit,
        'expirationDate': DateFormat('yyyy-MM-dd').format(_expirationDate),
        'isUserCreated': true,
        'createdBy': userId,
        'calories': _calories,
        'protein': _protein,
        'fat': _fat,
        'carbohydrates': _carbohydrates,
        'fiber': _fiber,
      };

      final ingredientResponse = await http.post(
        Uri.parse(ingredientApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ingredientData),
      );

      if (ingredientResponse.statusCode == 201) {
        // 3. Ingredient 成功创建后，获取 ingredientId
        final createdIngredient = jsonDecode(ingredientResponse.body);
        final ingredientId = createdIngredient['ingredientId'];

        // 4. 创建 UserIngredient
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
          // 重置表单
          setState(() {
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MyHomePage(title: 'Home Page'),
            ),
          );
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
        title: const Text(
          'Add food',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: appBarColor,
      ),
      body: SingleChildScrollView(
        // Added for scrolling
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Ingredient Name
              TextField(
                decoration: const InputDecoration(hintText: 'Enter Ingredient Name'),
                onChanged: (value) {
                  setState(() {
                    _ingredientName = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: _image != null
                    ? Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover)
                    : Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.camera_alt),
                      ),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: foodCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),

              // Storage Method Dropdown
              DropdownButtonFormField<String>(
                value: _selectedStorageMethod,
                items: storageMethods.map((String method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStorageMethod = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Storage method'),
              ),
              const SizedBox(height: 16),

              // Quantity Input
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Quantity',
                  errorText: _isQuantityValid ? null : 'Please enter a valid number',
                ),
                onChanged: (value) {
                  setState(() {
                    _quantity = int.tryParse(value) ?? 0; // 默认值为0
                    _isQuantityValid = _quantity > 0; // 确保数量为正数
                  });
                },
              ),
              const SizedBox(height: 16),

              // Unit Input
              TextField(
                decoration: const InputDecoration(hintText: 'Unit (e.g., grams, liters)'),
                onChanged: (value) {
                  setState(() {
                    _unit = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Expiration Date Picker
              GestureDetector(
                onTap: () => _selectExpirationDate(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Expiration date: ${_expirationDate.toLocal().toString().split(' ')[0]}'),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nutritional Information Inputs
              TextField(
                decoration: const InputDecoration(hintText: 'Calories'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _calories = double.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(hintText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _protein = double.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(hintText: 'Fat (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _fat = double.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(hintText: 'Carbohydrates (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _carbohydrates = double.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(hintText: 'Fiber (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _fiber = double.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Add Button
              ElevatedButton(
                onPressed: _addIngredient,
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
