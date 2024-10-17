import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foo_my_food_app/screens/homepage.dart';
import 'package:foo_my_food_app/utils/calendar_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:foo_my_food_app/datasource/temp_db.dart'; // For food categories and storage methods
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foo_my_food_app/utils/helper_function.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:device_calendar/device_calendar.dart';

class AddIngredientPage extends StatefulWidget {
  const AddIngredientPage({super.key});

  @override
  AddIngredientPageState createState() => AddIngredientPageState();
}

class AddIngredientPageState extends State<AddIngredientPage> {
  File? _image;
  String? _selectedCategory;
  String? _selectedStorageMethod;
  int _quantity = 1;
  bool _isQuantityValid = true; // 用于跟踪数量输入是否有效
  DateTime _expirationDate = DateTime.now();
  String _ingredientName = '';
  String _unit = ''; // Unit of measurement
  double _calories = 0; // Calories
  double _protein = 0; // Protein
  double _fat = 0; // Fat
  double _carbohydrates = 0; // Carbohydrates
  double _fiber = 0; // Fiber
  bool _isFormValid = false; // 用于跟踪表单是否有效
  bool _isCaloriesValid = true;
  bool _isProteinValid = true;
  bool _isFatValid = true;
  bool _isCarbohydratesValid = true;
  bool _isFiberValid = true;
  final CalendarHelper _calendarHelper = CalendarHelper();

  // 表单验证方法
  void _validateForm() {
    setState(() {
      _isFormValid = _ingredientName.isNotEmpty &&
          _selectedCategory != null &&
          _selectedStorageMethod != null &&
          _unit.isNotEmpty &&
          _quantity > 0 &&
          _calories >= 0 &&
          _protein >= 0 &&
          _fat >= 0 &&
          _carbohydrates >= 0 &&
          _fiber >= 0;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      int imageSize = imageFile.lengthSync();

      if (imageSize > 1048576) {
        _showError('Image size exceeds 1MB. Please select a smaller image.');
      } else {
        setState(() {
          _image = imageFile;
        });
        _validateForm(); // 更新图片后进行表单验证
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
        content:
            Text(message, style: const TextStyle(color: redErrorTextColor)),
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

    try {
      String? imageUrl;
      if (_image != null) {
        var request = http.MultipartRequest(
            'POST', Uri.parse('$baseApiUrl/ingredients/upload_image'));
        request.files
            .add(await http.MultipartFile.fromPath('file', _image!.path));
        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await http.Response.fromStream(response);
          var jsonResponse = jsonDecode(responseBody.body);
          imageUrl = jsonResponse['imageUrl'];
        } else {
          throw Exception('Failed to upload image');
        }
      }

      const String ingredientApiUrl = '$baseApiUrl/ingredients';

      final ingredientData = {
        'name': _ingredientName,
        'category': _selectedCategory,
        'imageURL': imageUrl,
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

          bool addToCalendar = await _showAddToCalendarDialog();

          if (addToCalendar) {
            bool hasCalendarPermission =
                await _calendarHelper.checkCalendarPermission();
            if (!hasCalendarPermission) {
              _showError(
                  'Calendar permission is required to sync ingredient expiration date.');
              return;
            }

            bool eventCreated = await _calendarHelper.createCalendarEvent(
                _ingredientName, _expirationDate);
            if (eventCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Expiration date added to calendar!')),
              );
            } else {
              _showError('Failed to add event to calendar');
            }
          }

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
  

  Future<bool> _showAddToCalendarDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Add to Calendar'),
              content: const Text(
                  'Would you like to add the ingredient\'s expiration date to your calendar?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Ingredient Name
              TextField(
                decoration:
                    const InputDecoration(hintText: 'Enter Ingredient Name'),
                onChanged: (value) {
                  setState(() {
                    _ingredientName = value;
                  });
                  _validateForm(); // 验证表单
                },
              ),
              const SizedBox(height: 16),

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: _image != null
                    ? Image.file(_image!,
                        height: 100, width: 100, fit: BoxFit.cover)
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
                  _validateForm(); // 验证表单
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
                  _validateForm(); // 验证表单
                },
                decoration: const InputDecoration(labelText: 'Storage method'),
              ),
              const SizedBox(height: 16),

              // Quantity Input
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Quantity',
                  errorText: !_isQuantityValid ? quantityError : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _quantity = int.tryParse(value) ?? 0;
                    _isQuantityValid = _quantity > 0; // 数量必须大于0
                  });
                  _validateForm(); // 验证表单
                },
              ),
              const SizedBox(height: 16),

              // Unit Input
              TextField(
                decoration: const InputDecoration(
                    hintText: 'Unit (e.g., grams, liters)'),
                onChanged: (value) {
                  setState(() {
                    _unit = value;
                  });
                  _validateForm(); // 验证表单
                },
              ),
              const SizedBox(height: 16),

              // Expiration Date Picker
              GestureDetector(
                onTap: () => _selectExpirationDate(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        'Expiration date: ${_expirationDate.toLocal().toString().split(' ')[0]}'),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nutritional Information Inputs
              TextField(
                decoration: InputDecoration(
                  hintText: 'Calories',
                  errorText: !_isCaloriesValid ? caloriesInvalidError : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      // 如果用户删除输入，设置默认值为 0
                      _calories = 0;
                      _isCaloriesValid = true; // 重置验证状态
                    } else {
                      _calories = double.tryParse(value) ?? -1;
                      _isCaloriesValid = _calories >= 0; // 只要输入有效，允许继续操作
                    }
                  });
                  _validateForm(); // 验证表单
                },
              ),
              const SizedBox(height: 16),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Protein (g)',
                  errorText: !_isProteinValid ? proteinInvalidError : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      // 如果用户删除输入，设置默认值为 0
                      _protein = 0;
                      _isProteinValid = true; // 重置验证状态
                    } else {
                      _protein = double.tryParse(value) ?? -1;
                      _isProteinValid = _protein >= 0; // 只要输入有效，允许继续操作
                    }
                  });
                  _validateForm(); // 验证表单
                },
              ),
              const SizedBox(height: 16),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Fat (g)',
                  errorText: !_isFatValid ? fatInvalidError : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      // 如果用户删除输入，设置默认值为 0
                      _fat = 0;
                      _isFatValid = true; // 重置验证状态
                    } else {
                      _fat = double.tryParse(value) ?? -1;
                      _isFatValid = _fat >= 0; // 只要输入有效，允许继续操作
                    }
                  });
                  _validateForm(); // 验证表单
                },
              ),
              const SizedBox(height: 16),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Carbohydrates (g)',
                  errorText:
                      !_isCarbohydratesValid ? carbohydratesInvalidError : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      // 如果用户删除输入，设置默认值为 0
                      _carbohydrates = 0;
                      _isCarbohydratesValid = true; // 重置验证状态
                    } else {
                      _carbohydrates = double.tryParse(value) ?? -1;
                      _isCarbohydratesValid =
                          _carbohydrates >= 0; // 只要输入有效，允许继续操作
                    }
                  });
                  _validateForm(); // 验证表单
                },
              ),
              const SizedBox(height: 16),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Fiber (g)',
                  errorText: !_isFiberValid ? fiberInvalidError : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      // 如果用户删除输入，设置默认值为 0
                      _fiber = 0;
                      _isFiberValid = true; // 重置验证状态
                    } else {
                      _fiber = double.tryParse(value) ?? -1;
                      _isFiberValid = _fiber >= 0; // 只要输入有效，允许继续操作
                    }
                  });
                  _validateForm(); // 验证表单
                },
              ),
              const SizedBox(height: 16),

              // Add Button, disabled if form is not valid
              ElevatedButton(
                onPressed:
                    _isFormValid ? _addIngredient : null, // 只有当表单有效时才启用按钮
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid
                      ? buttonBackgroundColor
                      : Colors.grey, // 根据表单状态设置按钮颜色
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.white), // 设置文字为白色
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
