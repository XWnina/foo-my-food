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
  String _ingredientName = ''; // Store ingredient name

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 更新图片文件
      });
    }
  }

  // 显示选择图片来源的选项
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera); // 从相机拍照
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery); // 从相册选择图片
                },
              ),
            ],
          ),
        );
      },
    );
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
        SnackBar(content: Text(message, style: TextStyle(color: redErrorTextColor))));
  }

  // 上传图片并添加食材
  Future<void> _uploadImageAndAddIngredient() async {
    if (_image == null) {
      _showError('Please upload an image');
      return;
    }

    // 上传图片到后端API
    final String uploadImageUrl = '$baseApiUrl/ingredients/upload_image';
    var request = http.MultipartRequest('POST', Uri.parse(uploadImageUrl));
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var imageUrl = jsonDecode(responseData.body)['imageUrl'];

        await _addIngredientWithImage(imageUrl);
      } else {
        throw Exception('Image upload failed');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  // 添加食材并包含图片URL
  Future<void> _addIngredientWithImage(String imageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      _showError('User ID not found');
      return;
    }

    final ingredientData = {
      'name': _ingredientName,
      'category': _selectedCategory,
      'isUserCreated': true,
      'createdBy': userId,
      'imageURL': imageUrl, // 上传图片后的URL
      'storageMethod': _selectedStorageMethod,
      'baseQuantity': _quantity,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseApiUrl/ingredients'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ingredientData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient added successfully!')),
        );
      } else {
        throw Exception('Failed to add ingredient');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: SizedBox(
                width: 300, // Set width of the text field
                child: TextField(
                  textAlign: TextAlign.center, // Center the text inside the field
                  decoration: InputDecoration(
                    hintText: 'Enter Ingredient Name',
                    hintStyle: TextStyle(color: Colors.grey), // Placeholder color
                    filled: true,
                    fillColor: Colors.transparent, // Transparent background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0), // Rounded border
                      borderSide: BorderSide(
                        color: Colors.grey, // Border color
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: Colors.grey, // Border color
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: Colors.blue, // Focused border color
                        width: 2.0,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _ingredientName = value; // Capture the entered name
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _showImageSourceActionSheet, // 弹出选择框
              child: _image != null
                  ? Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover)
                  : Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[300],
                      child: Icon(Icons.camera_alt),
                    ),
            ),
            SizedBox(height: 16),
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
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 16),
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
              decoration: InputDecoration(labelText: 'Storage method'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Quantity:'),
                SizedBox(width: 8),
                DropdownButton<int>(
                  value: _quantity,
                  items: List.generate(10, (index) => index + 1).map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _quantity = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectExpirationDate(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expiration time: ${_expirationDate.toLocal()}'.split(' ')[0],
                  ),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
               onPressed: _uploadImageAndAddIngredient,
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
