import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foo_my_food_app/screens/homepage.dart';
import 'package:foo_my_food_app/utils/calendar_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:foo_my_food_app/datasource/temp_db.dart'; // For food categories and storage methods
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // 控制器
  final TextEditingController _ingredientNameController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbohydratesController =
      TextEditingController();
  final TextEditingController _fiberController = TextEditingController();

  String? _selectedCategory;
  String? _selectedStorageMethod;
  int _quantity = 1;
  bool _isQuantityValid = true;
  bool _isNameValid = true;
  bool _isUnitValid = true;
  bool _isCaloriesValid = true;
  bool _isProteinValid = true;
  bool _isFatValid = true;
  bool _isCarbohydratesValid = true;
  bool _isFiberValid = true;
  DateTime _expirationDate = DateTime.now();
  bool _isFormValid = false;
  final CalendarHelper _calendarHelper = CalendarHelper();

  // 用于模糊搜索结果
  List<String> _matchingPresets = [];
  bool _showDropdown = false;

  @override
  void dispose() {
    // 释放控制器资源
    _ingredientNameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbohydratesController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _ingredientNameController.text.isNotEmpty &&
          _selectedCategory != null &&
          _selectedStorageMethod != null &&
          _unitController.text.isNotEmpty &&
          _quantity > 0 &&
          _caloriesController.text.isNotEmpty &&
          _proteinController.text.isNotEmpty &&
          _fatController.text.isNotEmpty &&
          _carbohydratesController.text.isNotEmpty &&
          _fiberController.text.isNotEmpty;
    });
  }

  void _validateName() {
    setState(() {
      _isNameValid = _ingredientNameController.text.isNotEmpty;
    });
    _validateForm();
  }

  void _validateQuantity() {
    setState(() {
      final quantity = int.tryParse(_quantityController.text);
      _isQuantityValid = quantity != null && quantity > 0; // 确保数量是有效数字且大于 0
    });
    _validateForm(); // 验证表单
  }

  void _validateUnit() {
    setState(() {
      _isUnitValid = _unitController.text.isNotEmpty;
    });
    _validateForm();
  }

  void _validateProtein() {
    setState(() {
      if (_proteinController.text.isEmpty) {
        _isProteinValid = true; // 空值时，不报错
      } else {
        final protein = double.tryParse(_proteinController.text);
        _isProteinValid = protein != null && protein >= 0;
      }
    });
    _validateForm();
  }

  void _validateCalories() {
    setState(() {
      if (_caloriesController.text.isEmpty) {
        _isCaloriesValid = true;
      } else {
        final calories = double.tryParse(_caloriesController.text);
        _isCaloriesValid = calories != null && calories >= 0;
      }
    });
    _validateForm();
  }

  void _validateFat() {
    setState(() {
      if (_fatController.text.isEmpty) {
        _isFatValid = true;
      } else {
        final fat = double.tryParse(_fatController.text);
        _isFatValid = fat != null && fat >= 0;
      }
    });
    _validateForm();
  }

  void _validateCarbohydrates() {
    setState(() {
      if (_carbohydratesController.text.isEmpty) {
        _isCarbohydratesValid = true;
      } else {
        final carbohydrates = double.tryParse(_carbohydratesController.text);
        _isCarbohydratesValid = carbohydrates != null && carbohydrates >= 0;
      }
    });
    _validateForm();
  }

  void _validateFiber() {
    setState(() {
      if (_fiberController.text.isEmpty) {
        _isFiberValid = true;
      } else {
        final fiber = double.tryParse(_fiberController.text);
        _isFiberValid = fiber != null && fiber >= 0;
      }
    });
    _validateForm();
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
        _validateForm();
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
        'name': _ingredientNameController.text,
        'category': _selectedCategory,
        'imageURL': imageUrl,
        'storageMethod': _selectedStorageMethod,
        'baseQuantity': int.parse(_quantityController.text),
        'unit': _unitController.text,
        'expirationDate': DateFormat('yyyy-MM-dd').format(_expirationDate),
        'isUserCreated': true,
        'createdBy': userId,
        'calories': double.parse(_caloriesController.text),
        'protein': double.parse(_proteinController.text),
        'fat': double.parse(_fatController.text),
        'carbohydrates': double.parse(_carbohydratesController.text),
        'fiber': double.parse(_fiberController.text),
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
          'userQuantity': int.parse(_quantityController.text),
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
                _ingredientNameController.text, _expirationDate);
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
            _ingredientNameController.clear();
            _quantityController.clear();
            _unitController.clear();
            _caloriesController.clear();
            _proteinController.clear();
            _fatController.clear();
            _carbohydratesController.clear();
            _fiberController.clear();
            _selectedCategory = null;
            _selectedStorageMethod = null;
            _quantity = 1;
            _expirationDate = DateTime.now();
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const MyHomePage(title: 'Home Page')),
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

  // 实时获取匹配食材
  Future<void> _getMatchingPresets(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseApiUrl/presetsaddfood/search?query=$query'),
      );

      if (response.statusCode == 200) {
        final List<String> presets =
            List<String>.from(jsonDecode(response.body));
        setState(() {
          _matchingPresets = presets;
          _showDropdown = presets.isNotEmpty;
        });
      } else {
        setState(() {
          _matchingPresets = [];
          _showDropdown = false;
        });
      }
    } catch (e) {
      _showError('Error fetching matching presets: ${e.toString()}');
      setState(() {
        _matchingPresets = [];
        _showDropdown = false;
      });
    }
  }

  // 根据选中的预设名称填充表单
  Future<void> _fillFormWithPreset(String presetName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseApiUrl/presetsaddfood/name/$presetName'),
      );

      if (response.statusCode == 200) {
        final presetData = jsonDecode(response.body);

        setState(() {
          _ingredientNameController.text = presetData['name'];
          _unitController.text = presetData['unit'];
          _caloriesController.text = presetData['calories'].toString();
          _proteinController.text = presetData['protein'].toString();
          _fatController.text = presetData['fat'].toString();
          _carbohydratesController.text =
              presetData['carbohydrates'].toString();
          _fiberController.text = presetData['fiber'].toString();

          _selectedCategory = presetData['category'];
          _selectedStorageMethod = presetData['storageMethod'];
          _quantityController.text = presetData['baseQuantity'].toString();
          _expirationDate =
              DateFormat('yyyy-MM-dd').parse(presetData['expirationDate']);
          _showDropdown = false; // 选中后隐藏下拉菜单
        });

        _validateForm();
      } else {
        _showError('No preset found with the name $presetName');
      }
    } catch (e) {
      _showError('Error fetching preset: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Add food', style: TextStyle(color: Colors.white)),
        backgroundColor: appBarColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 食材名称输入框，使用控制器来管理文本
              TextField(
                controller: _ingredientNameController,
                decoration: InputDecoration(
                  hintText: 'Enter Ingredient Name',
                  errorText: !_isNameValid ? 'Name is required' : null,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      if (_ingredientNameController.text.isNotEmpty) {
                        _getMatchingPresets(_ingredientNameController.text);
                      }
                    },
                  ),
                ),
                onChanged: (value) {
                  _validateName(); // 验证name字段
                },
              ),
              // 如果有匹配结果，则显示下拉菜单
              if (_showDropdown)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _matchingPresets.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_matchingPresets[index]),
                      onTap: () => _fillFormWithPreset(
                          _matchingPresets[index]), // 选择后自动填充表单
                    );
                  },
                ),
              const SizedBox(height: 16),
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
                  _validateForm();
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
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
                  _validateForm();
                },
                decoration: const InputDecoration(labelText: 'Storage method'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Quantity',
                  errorText: !_isQuantityValid
                      ? 'Quantity must be greater than 0'
                      : null,
                ),
                onChanged: (value) {
                  _validateQuantity(); // 验证quantity字段
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _unitController,
                decoration: InputDecoration(
                  hintText: 'Unit (e.g., grams, liters)',
                  errorText: !_isUnitValid ? 'Unit is required' : null,
                ),
                onChanged: (value) {
                  _validateUnit(); // 验证unit字段
                },
              ),
              const SizedBox(height: 16),
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
              TextField(
                controller: _caloriesController,
                decoration: InputDecoration(
                  hintText: 'Calories',
                  errorText: !_isCaloriesValid
                      ? 'Calories must be a valid number'
                      : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _validateCalories(); // 验证calories字段
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _proteinController,
                decoration: InputDecoration(
                  hintText: 'Protein (g)',
                  errorText: !_isProteinValid
                      ? 'Protein must be a valid number'
                      : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _validateProtein(); // 验证protein字段
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fatController,
                decoration: InputDecoration(
                  hintText: 'Fat (g)',
                  errorText: !_isFatValid ? 'Fat must be a valid number' : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _validateFat(); // 验证fat字段
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _carbohydratesController,
                decoration: InputDecoration(
                  hintText: 'Carbohydrates (g)',
                  errorText: !_isCarbohydratesValid
                      ? 'Carbohydrates must be a valid number'
                      : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _validateCarbohydrates(); // 验证carbohydrates字段
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fiberController,
                decoration: InputDecoration(
                  hintText: 'Fiber (g)',
                  errorText:
                      !_isFiberValid ? 'Fiber must be a valid number' : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _validateFiber(); // 验证fiber字段
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isFormValid ? _addIngredient : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isFormValid ? buttonBackgroundColor : Colors.grey,
                ),
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
