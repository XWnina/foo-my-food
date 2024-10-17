import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:image_picker/image_picker.dart';

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final String userId;
  final int index;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    required this.userId,
    required this.index,
  });

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _ingredientsController;
  late TextEditingController _caloriesController;
  late TextEditingController _descriptionController;
  late TextEditingController _videoLinkController;

  String? _newImageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipe['name']);
    _ingredientsController =
        TextEditingController(text: widget.recipe['ingredients']?.join(', '));
    _caloriesController = TextEditingController(
        text: widget.recipe['calories']?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.recipe['description'] ?? '');
    _videoLinkController =
        TextEditingController(text: widget.recipe['videoLink'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ingredientsController.dispose();
    _caloriesController.dispose();
    _descriptionController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final updatedRecipe = {
      'name': _nameController.text,
      'ingredients':
          _ingredientsController.text.split(',').map((e) => e.trim()).toList(),
      'calories': int.tryParse(_caloriesController.text) ?? 0,
      'description': _descriptionController.text,
      'videoLink': _videoLinkController.text,
      'imageURL': _newImageUrl ?? widget.recipe['imageURL'],
    };

    final apiUrl = '$baseApiUrl/recipes/${widget.recipe['id']}';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedRecipe),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to update recipe');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      _imageFile = file;
      // Add code to upload the file to your backend or Google Cloud here.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.recipe['name'], style: TextStyle(color: text)),
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: text),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: greyBorderColor),
                  borderRadius: BorderRadius.circular(8),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : (widget.recipe['imageURL'] != null &&
                              widget.recipe['imageURL'].isNotEmpty)
                          ? DecorationImage(
                              image: NetworkImage(widget.recipe['imageURL']),
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child: _isEditing && _imageFile == null
                    ? Center(
                        child: Text(
                          'Tap to change image',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Recipe Name'),
                  )
                : Text(
                    widget.recipe['name'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _ingredientsController,
                    decoration: const InputDecoration(
                        labelText: 'Ingredients (comma-separated)'),
                  )
                : Text(
                    'Ingredients: ${widget.recipe['ingredients']?.join(', ')}'),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(labelText: 'Calories'),
                    keyboardType: TextInputType.number,
                  )
                : Text('Calories: ${widget.recipe['calories']} kcal'),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 4,
                  )
                : Text('Description: ${widget.recipe['description']}'),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _videoLinkController,
                    decoration: const InputDecoration(labelText: 'Video Link'),
                  )
                : widget.recipe['videoLink'] != null &&
                        widget.recipe['videoLink'].isNotEmpty
                    ? Text('Video Link: ${widget.recipe['videoLink']}')
                    : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
