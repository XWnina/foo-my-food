import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  File? _image;
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _videoLinkController = TextEditingController(); // 添加视频链接输入框

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      int imageSize = imageFile.lengthSync();

      if (imageSize > 1048576) {
        _showError('Image size exceeds 1MB. Please select a smaller image.');
      } else {
        setState(() {
          _image = imageFile;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: redErrorTextColor)),
      ),
    );
  }

  Future<void> _addRecipe() async {
  final recipeName = _recipeNameController.text;
  final ingredients = _ingredientsController.text;
  final calories = _caloriesController.text;
  final description = _descriptionController.text;
  final videoLink = _videoLinkController.text;

  // 仅验证必填项
  if (recipeName.isEmpty || ingredients.isEmpty || calories.isEmpty || description.isEmpty) {
    _showError('Please fill in all required fields');
    return;
  }

  try {
    String? imageUrl;
    if (_image != null) {
      var request = http.MultipartRequest('POST', Uri.parse('your_api_url_here'));
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

    // 构建 recipe 数据，不强制要求图片或视频链接
    final recipeData = {
      'name': recipeName,
      'ingredients': ingredients,
      'calories': calories,
      'description': description,
      'imageURL': imageUrl, // 使用上传后的图片 URL（如果有）
      'videoLink': videoLink.isNotEmpty ? videoLink : null, // 仅当视频链接不为空时传递
    };

    final response = await http.post(
      Uri.parse('your_api_url_here'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(recipeData),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe added successfully!')),
      );
      Navigator.pop(context); // 返回上一页
    } else {
      throw Exception('Failed to add recipe');
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
        title: const Text('Add Recipe', style: TextStyle(color: whiteTextColor)),
        backgroundColor: appBarColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Recipe Name
            TextField(
              controller: _recipeNameController,
              decoration: const InputDecoration(hintText: 'Recipe Name'),
            ),
            const SizedBox(height: 16),

            // Ingredients
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(hintText: 'Ingredients'),
            ),
            const SizedBox(height: 16),

            // Calories
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Calories'),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Description'),
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
                      color: greyBackgroundColor,
                      child: const Icon(Icons.camera_alt),
                    ),
            ),
            const SizedBox(height: 16),

            // Video Link
            TextField(
              controller: _videoLinkController,
              decoration: const InputDecoration(hintText: 'Video Link'),
            ),
            const SizedBox(height: 16),

            // Add Recipe Button
            ElevatedButton(
              onPressed: _addRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
              ),
              child: const Text('Add Recipe', style: TextStyle(color: whiteTextColor)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _ingredientsController.dispose();
    _caloriesController.dispose();
    _descriptionController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }
}
