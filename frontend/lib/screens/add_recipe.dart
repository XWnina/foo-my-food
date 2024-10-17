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
  final TextEditingController _videoLinkController = TextEditingController();

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
        content:
            Text(message, style: const TextStyle(color: redErrorTextColor)),
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
    if (recipeName.isEmpty || ingredients.isEmpty) {
      _showError('Please fill in Recipe Name and Ingredients');
      return;
    }

    try {
      String? imageUrl;
      if (_image != null) {
        var request = http.MultipartRequest(
            'POST', Uri.parse('your_image_upload_api_url_here'));
        request.files
            .add(await http.MultipartFile.fromPath('file', _image!.path));
        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await http.Response.fromStream(response);
          var jsonResponse = jsonDecode(responseBody.body);
          imageUrl = jsonResponse['imageUrl'];
        }
      }

      // 构建 recipe 数据，videoLink 和 imageURL 都是可选的
      final recipeData = {
        'name': recipeName,
        'ingredients': ingredients,
        'calories': calories,
        'description': description,
        if (imageUrl != null) 'imageURL': imageUrl, // 仅当有图片时传递URL
        if (videoLink.isNotEmpty) 'videoLink': videoLink, // 仅当视频链接不为空时传递
      };

      // 仅当videoLink不为空时，进行API请求
      if (videoLink.isNotEmpty) {
        final response = await http.post(
          Uri.parse('your_video_api_url_here'),
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
      } else {
        // 如果没有视频链接，只是提示用户成功添加，而不进行网络请求
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Recipe added successfully!')),
        );
        Navigator.pop(context); // 返回上一页
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
        title:
            const Text('Add Recipe', style: TextStyle(color: whiteTextColor)),
        backgroundColor: appBarColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image Picker (Moved to top)
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
              child: const Text('Add Recipe',
                  style: TextStyle(color: whiteTextColor)),
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
