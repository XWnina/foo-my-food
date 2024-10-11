import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:foo_my_food_app/models/ingredient.dart';
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:foo_my_food_app/providers/ingredient_provider.dart';
import 'package:image_picker/image_picker.dart';

class FoodItemDetailPage extends StatefulWidget {
  final Ingredient ingredient;
  final String userId;
  final int index;

  const FoodItemDetailPage({
    Key? key,
    required this.ingredient,
    required this.userId,
    required this.index,
  }) : super(key: key);

  @override
  FoodItemDetailPageState createState() => FoodItemDetailPageState();
}

class FoodItemDetailPageState extends State<FoodItemDetailPage> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _expirationDateController;
  late TextEditingController _quantityController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbohydratesController;
  late TextEditingController _fiberController;
  late TextEditingController _unitController;

  String? _newImageUrl; // 用来保存后端返回的新图片 URL

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.name);
    _expirationDateController = TextEditingController(text: widget.ingredient.expirationDate);
    _quantityController = TextEditingController(text: widget.ingredient.baseQuantity.toString());
    _caloriesController = TextEditingController(text: widget.ingredient.calories.toString());
    _proteinController = TextEditingController(text: widget.ingredient.protein.toString());
    _fatController = TextEditingController(text: widget.ingredient.fat.toString());
    _carbohydratesController = TextEditingController(text: widget.ingredient.carbohydrates.toString());
    _fiberController = TextEditingController(text: widget.ingredient.fiber.toString());
    _unitController = TextEditingController(text: widget.ingredient.unit);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: redErrorTextColor))),
    );
  }

  Future<void> _saveChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      _showError('User ID not found');
      return;
    }

    final apiUrl = '$baseApiUrl/ingredients/${widget.ingredient.ingredientId}';

    // 提交更新的数据
    final updateResponse = await http.put(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userId': userId,
        'ingredientId': widget.ingredient.ingredientId,
        'userQuantity': int.parse(_quantityController.text),
        'name': _nameController.text,
        'expirationDate': _expirationDateController.text,
        'calories': double.parse(_caloriesController.text),
        'protein': double.parse(_proteinController.text),
        'fat': double.parse(_fatController.text),
        'carbohydrates': double.parse(_carbohydratesController.text),
        'fiber': double.parse(_fiberController.text),
        'unit': _unitController.text,
        'imageURL': _newImageUrl ?? widget.ingredient.imageURL, // 如果有新图片则使用新 URL
      }),
    );

    if (updateResponse.statusCode == 200) {
      // 更新 provider 中的 ingredient
      Provider.of<IngredientProvider>(context, listen: false).updateIngredient(
        widget.index,
        Ingredient(
          name: _nameController.text,
          expirationDate: _expirationDateController.text,
          baseQuantity: int.parse(_quantityController.text),
          calories: double.parse(_caloriesController.text),
          protein: double.parse(_proteinController.text),
          fat: double.parse(_fatController.text),
          carbohydrates: double.parse(_carbohydratesController.text),
          fiber: double.parse(_fiberController.text),
          ingredientId: widget.ingredient.ingredientId,
          imageURL: _newImageUrl ?? widget.ingredient.imageURL, // 使用更新后的图片 URL
          unit: _unitController.text,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully!')),
      );
      Navigator.pop(context);
    } else {
      _showError('Update failed');
    }
  }

  Future<void> _pickImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.getImage(source: ImageSource.gallery); // 从图库中选择图片

  if (pickedFile != null) {
    final file = File(pickedFile.path);

    // 获取文件大小（单位：字节）
    final int fileSizeInBytes = await file.length();
    final double fileSizeInMB = fileSizeInBytes / (1024 * 1024); // 转换为 MB

    // 检查文件大小是否超过 1MB
    if (fileSizeInMB > 1) {
      _showError('File size exceeds 1MB. Please choose a smaller image.');
      return; // 不继续上传
    }

    // 如果文件大小符合要求，则继续上传
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseApiUrl/ingredients/upload_image'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final responseBody = json.decode(responseData.body);
      setState(() {
        _newImageUrl = responseBody['imageUrl']; // 使用上传的图片 URL
        print('Uploaded image URL: $_newImageUrl'); // 打印调试信息
      });
    } else {
      _showError('Failed to upload image');
    }
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
                _saveChanges(); // 保存更新
              } else {
                setState(() {
                  _isEditing = true; // 进入编辑模式
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
              GestureDetector(
                onTap: _isEditing ? _pickImage : null, // 编辑模式下允许选择图片
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    image: _isEditing && _newImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_newImageUrl!), // 使用新上传的图片 URL
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(
                            image: NetworkImage(widget.ingredient.imageURL), // 使用已有的图片 URL
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: _isEditing && _newImageUrl == null
                      ? const Center(child: Text('Tap to change image', style: TextStyle(color: Colors.grey)))
                      : null,
                ),
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
                  ? GestureDetector(
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
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _expirationDateController,
                          decoration: const InputDecoration(labelText: 'Expiration Date', border: OutlineInputBorder()),
                        ),
                      ),
                    )
                  : Text('Expires on: ${widget.ingredient.expirationDate}'),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    )
                  : Text('Quantity: ${widget.ingredient.baseQuantity}'),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _unitController,
                      decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                    )
                  : Text('Unit: ${widget.ingredient.unit}'),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _caloriesController,
                      decoration: const InputDecoration(labelText: 'Calories', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    )
                  : Text('Calories: ${widget.ingredient.calories} kcal'),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _proteinController,
                      decoration: const InputDecoration(labelText: 'Protein', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    )
                  : Text('Protein: ${widget.ingredient.protein} g'),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _fatController,
                      decoration: const InputDecoration(labelText: 'Fat', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    )
                  : Text('Fat: ${widget.ingredient.fat} g'),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _carbohydratesController,
                      decoration: const InputDecoration(labelText: 'Carbohydrates', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    )
                  : Text('Carbohydrates: ${widget.ingredient.carbohydrates} g'),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _fiberController,
                      decoration: const InputDecoration(labelText: 'Fiber', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    )
                  : Text('Fiber: ${widget.ingredient.fiber} g'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
