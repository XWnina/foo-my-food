import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController _videoLinkController = TextEditingController();

  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // 加载 userId
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId'); // 从 SharedPreferences 中获取 userId
    if (userId == null) {
      print(
          "Error: userId is null. Ensure user is logged in and userId is saved in SharedPreferences.");
    }
  }


  Future<void> _pickImage() async {
    final pickedFile = await showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a photo'),
            onTap: () async {
              Navigator.pop(context);
              final picked =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (picked != null) {
                _handleImagePicked(picked);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Choose from gallery'),
            onTap: () async {
              Navigator.pop(context);
              final picked =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (picked != null) {
                _handleImagePicked(picked);
              }
            },
          ),
        ],
      ),
    );
  }

  void _handleImagePicked(XFile pickedFile) {
    final imageFile = File(pickedFile.path);
    int imageSize = imageFile.lengthSync();

    if (imageSize > 1048576) {
      _showError('Image size exceeds 1MB. Please select a smaller image.');
    } else {
      setState(() {
        _image = imageFile;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Future<void> _addRecipe() async {
    if (userId == null) {
      print("Error: userId is not loaded.");
      return;
    }

    final recipeName = _recipeNameController.text;
    final ingredients = _ingredientsController.text
        .split(',')
        .map((e) => e.trim())
        .toList(); // store ingredients as list
    final labels = _labelsController.text
        .split(',')
        .map((e) => e.trim())
        .toList(); // store ingredients as list
    final calories = _caloriesController.text;
    final description = _descriptionController.text;
    final videoLink = _videoLinkController.text;

    if (recipeName.isEmpty || ingredients.isEmpty) {
      _showError('Please fill in Recipe Name and Ingredients');
      return;
    }

    try {
      String? imageUrl;
      if (_image != null) {
        var request = http.MultipartRequest(
            'POST', Uri.parse('$baseApiUrl/myrecipes/upload_image'));
        request.files
            .add(await http.MultipartFile.fromPath('file', _image!.path));
        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await http.Response.fromStream(response);
          var jsonResponse = jsonDecode(responseBody.body);
          imageUrl = jsonResponse['imageUrl'];
        }
      }

      final recipeData = {

        'dishName': recipeName, // 修改了这里的字段名
        'ingredients': ingredients.join(', '), 

        'calories': int.tryParse(calories) ?? 0,
        'description': description,
        'userId': userId, // 新增 userId 字段
        if (imageUrl != null) 'imageURL': imageUrl,
        if (videoLink.isNotEmpty) 'videoLink': videoLink,
      };

      print('======Recipe data to be sent: $recipeData'); 

      final response = await http.post(
        Uri.parse('$baseApiUrl/myrecipes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(recipeData),
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe added successfully!')),
        );
        Navigator.pop(context);
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
        title: const Text('Add Recipe', style: TextStyle(color: Colors.white)),
        backgroundColor: appBarColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _image != null
                  ? Image.file(_image!,
                      height: 100, width: 100, fit: BoxFit.cover)
                  : Container(
                      height: 100,
                      width: 100,
                      color: greyBackgroundColor,
                      child: const Icon(Icons.camera_alt),
                    ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _recipeNameController,
              decoration: const InputDecoration(hintText: 'Recipe Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                  hintText: 'Ingredients (comma-separated)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelsController,
              decoration:
                  const InputDecoration(hintText: 'Labels (comma-separated)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Calories'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _videoLinkController,
              decoration: const InputDecoration(hintText: 'Video Link'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
              ),
              child: const Text('Add Recipe',
                  style: TextStyle(color: Colors.white)),
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
