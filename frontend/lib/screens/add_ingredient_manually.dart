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
  bool _isSubmitting = false;
  final CalendarHelper _calendarHelper = CalendarHelper();
  bool _showNoResultsMessage = false;

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
          _quantity > 0 &&
          _isCaloriesValid &&
          _isProteinValid &&
          _isFatValid &&
          _isCarbohydratesValid &&
          _isFiberValid;
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
      // 允许 unit 为空时自动通过
      _isUnitValid =
          _unitController.text.isEmpty || _unitController.text.isNotEmpty;
    });
    _validateForm();
  }

  void _validateProtein() {
    setState(() {
      _isProteinValid = _proteinController.text.isEmpty ||
          (double.tryParse(_proteinController.text) != null &&
              double.parse(_proteinController.text) >= 0);
    });
    _validateForm();
  }

  void _validateCalories() {
    setState(() {
      _isCaloriesValid = _caloriesController.text.isEmpty ||
          (double.tryParse(_caloriesController.text) != null &&
              double.parse(_caloriesController.text) >= 0);
    });
    _validateForm();
  }

  void _validateFat() {
    setState(() {
      _isFatValid = _fatController.text.isEmpty ||
          (double.tryParse(_fatController.text) != null &&
              double.parse(_fatController.text) >= 0);
    });
    _validateForm();
  }

  void _validateCarbohydrates() {
    setState(() {
      _isCarbohydratesValid = _carbohydratesController.text.isEmpty ||
          (double.tryParse(_carbohydratesController.text) != null &&
              double.parse(_carbohydratesController.text) >= 0);
    });
    _validateForm();
  }

  void _validateFiber() {
    setState(() {
      _isFiberValid = _fiberController.text.isEmpty ||
          (double.tryParse(_fiberController.text) != null &&
              double.parse(_fiberController.text) >= 0);
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
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      _showError('User ID not found');
      setState(() {
        _isSubmitting = false;
      });
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
        'unit': _unitController.text.isNotEmpty
            ? _unitController.text
            : null, // 单位为空时设为 null
        'expirationDate': DateFormat('yyyy-MM-dd').format(_expirationDate),
        'isUserCreated': true,
        'createdBy': userId,
        'calories': _caloriesController.text.isNotEmpty
            ? double.parse(_caloriesController.text)
            : 0.0, // 默认值 0.0
        'protein': _proteinController.text.isNotEmpty
            ? double.parse(_proteinController.text)
            : 0.0,
        'fat': _fatController.text.isNotEmpty
            ? double.parse(_fatController.text)
            : 0.0,
        'carbohydrates': _carbohydratesController.text.isNotEmpty
            ? double.parse(_carbohydratesController.text)
            : 0.0,
        'fiber': _fiberController.text.isNotEmpty
            ? double.parse(_fiberController.text)
            : 0.0,
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

            String formattedDate =
                DateFormat('yyyy-MM-dd').format(_expirationDate);
            String eventTitle =
                '${_ingredientNameController.text} - $formattedDate Expired';

            bool eventCreated = await _calendarHelper.createCalendarEvent(
                eventTitle, _expirationDate);

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

          Navigator.pop(context);
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
    } finally {
      setState(() {
        _isSubmitting = false; // 操作完成后，重新允许点击
      });
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
          _showNoResultsMessage = presets.isEmpty;
        });
      } else {
        setState(() {
          _matchingPresets = [];
          _showDropdown = false;
          _showNoResultsMessage = true;
        });
        _showError("No related ingredients, please enter manually.");
      }
    } catch (e) {
      _showError('Error fetching matching presets: ${e.toString()}');
      setState(() {
        _matchingPresets = [];
        _showDropdown = false;
        _showNoResultsMessage = true;
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

  void _onSearchFieldChanged(String value) {
    setState(() {
      _showNoResultsMessage = false;
    });
    _validateName();
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
              // 食材名称输入框，带搜索图标
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
                onChanged: _onSearchFieldChanged,
              ),

              // 无匹配结果时显示提示
              if (_showNoResultsMessage)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "No related ingredients, please enter manually.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

              // 显示匹配的食材下拉菜单
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

              // 图片选择器
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

              // 分类选择
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

              // 存储方法选择
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

              // 数量输入框
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Quantity',
                  errorText: !_isQuantityValid ? quantityError : null,
                ),
                onChanged: (value) {
                  _validateQuantity();
                },
              ),
              const SizedBox(height: 16),

              // 单位输入框
              TextField(
                controller: _unitController,
                decoration: InputDecoration(
                  hintText: 'Unit (e.g., grams, liters)',
                  errorText: !_isUnitValid ? 'Unit is required' : null,
                ),
                onChanged: (value) {
                  _validateUnit();
                },
              ),
              const SizedBox(height: 16),

              // 过期日期选择
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

              // 营养信息输入框
              TextField(
                controller: _caloriesController,
                decoration: InputDecoration(
                  hintText: 'Calories',
                  errorText: !_isCaloriesValid ? caloriesInvalidError : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _validateCalories();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _proteinController,
                decoration: InputDecoration(
                  hintText: 'Protein (g)',
                  errorText: !_isProteinValid ? proteinInvalidError : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _validateProtein();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fatController,
                decoration: InputDecoration(
                  hintText: 'Fat (g)',
                  errorText: !_isFatValid ? fatInvalidError : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _validateFat();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _carbohydratesController,
                decoration: InputDecoration(
                  hintText: 'Carbohydrates (g)',
                  errorText:
                      !_isCarbohydratesValid ? carbohydratesInvalidError : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _validateCarbohydrates();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fiberController,
                decoration: InputDecoration(
                  hintText: 'Fiber (g)',
                  errorText: !_isFiberValid ? fiberInvalidError : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _validateFiber();
                },
              ),
              const SizedBox(height: 16),

              // 提交按钮
              ElevatedButton(
                onPressed:
                    _isFormValid && !_isSubmitting ? _addIngredient : null,
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
