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
  final bool isPresetRecipe;
  const RecipeDetailPage({
    super.key,
    required this.recipe,
    required this.userId,
    required this.index,
    required this.isPresetRecipe,
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
  List<String> _options = [
    'breakfast',
    'lunch',
    'dinner',
    'dessert',
    'snack',
    'vegan',
    'vegetarian'
  ];
  Set<String> _selectedLabels = {};

  String? _newImageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipe['name']);
     _ingredientsController = TextEditingController(
      text: _getIngredientsString(),
    );
    _caloriesController = TextEditingController(
        text: widget.recipe['calories']?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.recipe['description'] ?? '');
    _videoLinkController =
        TextEditingController(text: widget.recipe['videoLink'] ?? '');
    _selectedLabels =
        Set<String>.from(widget.recipe['labels']?.split(', ') ?? []);
    /*test*/
    print('Recipe Details:');
    widget.recipe.forEach((key, value) {
      print('$key: $value');
    });
    /*test*/
  }
   String _getIngredientsString() {
    var ingredients = widget.recipe['ingredients'];
    //print(ingredients);
    if (ingredients is List) {
      return ingredients.join(', ');
    } else if (ingredients is String) {
      return ingredients;
    } else if (widget.isPresetRecipe && widget.recipe['ingredient'] is String) {
      // Highlight: Handle the case where preset recipes use 'ingredient' instead of 'ingredients'
      return widget.recipe['ingredient'];
    } else {
      return '';
    }
    
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
    if (_imageFile != null) {
      await _uploadImage(); // 上传图片并更新 _newImageUrl
    }

    // 过滤掉空标签
    final filteredLabels =
        _selectedLabels.where((label) => label.isNotEmpty).join(', ');

    final updatedRecipe = {
      'dishName': _nameController.text,
      'ingredients': _ingredientsController.text
          .split(',')
          .map((e) => e.trim())
          .join(', '), // 将数组转为逗号分隔字符串
      'labels': filteredLabels, // 使用过滤后的标签
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
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    final uploadUrl = '$baseApiUrl/myrecipes/upload_image';
    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..files.add(await http.MultipartFile.fromPath('file', _imageFile!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decodedData = jsonDecode(responseData);
      setState(() {
        _newImageUrl = decodedData['imageUrl'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.recipe['name'], style: const TextStyle(color: text)),
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
                    ? const Center(
                        child: Text('Tap to change image',
                            style: TextStyle(color: Colors.grey)),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    widget.recipe['name'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
            const SizedBox(height: 16),
            _isEditing
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        items: _options.map((String label) {
                          return DropdownMenuItem(
                            value: label,
                            child: Container(
                              width: MediaQuery.of(context).size.width *
                                  0.7, // 设置固定宽度
                              child: StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return CheckboxListTile(
                                    title: Text(label),
                                    value: _selectedLabels.contains(label),
                                    onChanged: (bool? selected) {
                                      setState(() {
                                        if (selected == true) {
                                          _selectedLabels.add(label);
                                        } else {
                                          _selectedLabels.remove(label);
                                        }
                                      });
                                      // 更新外部状态以反映勾选情况
                                      this.setState(() {});
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (_) {}, // 保持为空以阻止默认行为
                        hint: const Text('Select Labels'),
                        decoration: const InputDecoration(
                          hintText: 'Labels:',
                          filled: true, // 添加了这一行，使背景颜色填充
                          fillColor: Colors.white, // 添加了这一行，设置填充颜色为白色
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Selected Labels: ${_selectedLabels.where((label) => label.isNotEmpty).join(', ')}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  )
                : Text('Labels: ${widget.recipe['labels']}'),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _ingredientsController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredients (comma-separated)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    'Ingredients: ${widget.recipe['ingredients'] is List ? widget.recipe['ingredients'].join(', ') : widget.recipe['ingredients'] ?? 'No ingredients'}',
                  ),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(
                      labelText: 'Calories',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  )
                : Text('Calories: ${widget.recipe['calories']} kcal'),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  )
                : Text('Description: ${widget.recipe['description']}'),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _videoLinkController,
                    decoration: const InputDecoration(
                      labelText: 'Video Link',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  )
                : widget.recipe['videoLink'] != null &&
                        widget.recipe['videoLink'].isNotEmpty
                    ? Text('Video Link: ${widget.recipe['videoLink']}')
                    : const SizedBox(),
            Text(
              'Total Times Cooked: ${widget.recipe['cookCount'] ?? 0}',
            ),
          ],
        ),
      ),
    );
  }
}
