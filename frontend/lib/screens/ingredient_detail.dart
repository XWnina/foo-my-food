import 'dart:async';
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
import 'package:foo_my_food_app/datasource/temp_db.dart'; // For food categories and storage methods

class FoodItemDetailPage extends StatefulWidget {
  final Ingredient ingredient;
  final String userId;
  final int index;

  const FoodItemDetailPage({
    super.key,
    required this.ingredient,
    required this.userId,
    required this.index,
  });

  @override
  FoodItemDetailPageState createState() => FoodItemDetailPageState();
}

class FoodItemDetailPageState extends State<FoodItemDetailPage> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  String? _selectedCategory;
  String? _selectedStorageMethod;
  late TextEditingController _expirationDateController;
  late TextEditingController _quantityController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbohydratesController;
  late TextEditingController _fiberController;
  late TextEditingController _unitController;

  String? _newImageUrl;
  String? _expirationDateError;

  Timer? _debounce;

  bool _isFormValid = false;
  bool _isNameValid = true;
  bool _isQuantityValid = true;
  bool _isCaloriesValid = true;
  bool _isProteinValid = true;
  bool _isFatValid = true;
  bool _isCarbohydratesValid = true;
  bool _isFiberValid = true;
  bool _isExpirationDateValid = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.name);
    _selectedCategory = widget.ingredient.category;
    _selectedStorageMethod = widget.ingredient.storageMethod;
    _expirationDateController =
        TextEditingController(text: widget.ingredient.expirationDate);
    _quantityController =
        TextEditingController(text: widget.ingredient.baseQuantity.toString());
    _caloriesController =
        TextEditingController(text: widget.ingredient.calories.toString());
    _proteinController =
        TextEditingController(text: widget.ingredient.protein.toString());
    _fatController =
        TextEditingController(text: widget.ingredient.fat.toString());
    _carbohydratesController =
        TextEditingController(text: widget.ingredient.carbohydrates.toString());
    _fiberController =
        TextEditingController(text: widget.ingredient.fiber.toString());
    _unitController = TextEditingController(text: widget.ingredient.unit);

    _validateForm();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onDebounce(void Function() callback) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), callback);
  }

  void _validateForm() {
    setState(() {
      _isCaloriesValid = _caloriesController.text.isEmpty ||
          _isValidNonNegativeNumber(_caloriesController.text);
      _isProteinValid = _proteinController.text.isEmpty ||
          _isValidNonNegativeNumber(_proteinController.text);
      _isFatValid = _fatController.text.isEmpty ||
          _isValidNonNegativeNumber(_fatController.text);
      _isCarbohydratesValid = _carbohydratesController.text.isEmpty ||
          _isValidNonNegativeNumber(_carbohydratesController.text);
      _isFiberValid = _fiberController.text.isEmpty ||
          _isValidNonNegativeNumber(_fiberController.text);
      _isExpirationDateValid =
          _isValidExpirationDate(_expirationDateController.text);

      _isFormValid = _isNameValid &&
          _selectedCategory != null &&
          _selectedStorageMethod != null &&
          _isQuantityValid &&
          _isCaloriesValid &&
          _isProteinValid &&
          _isFatValid &&
          _isCarbohydratesValid &&
          _isFiberValid &&
          _isExpirationDateValid;
    });
  }

  bool _isValidPositiveNumber(String value) {
    final number = double.tryParse(value);
    return number != null && number > 0;
  }

  bool _isValidNonNegativeNumber(String value) {
    final number = double.tryParse(value);
    return number != null && number >= 0;
  }

  bool _isValidExpirationDate(String date) {
    try {
      final inputDate = DateFormat('yyyy-MM-dd').parseStrict(date);
      final today = DateTime.now();
      // 去掉时间部分，只比较日期
      final todayDateOnly = DateTime(today.year, today.month, today.day);
      final inputDateOnly =
          DateTime(inputDate.year, inputDate.month, inputDate.day);

      return !inputDateOnly.isBefore(todayDateOnly); // 允许今天或以后的日期
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveChanges() async {
    _validateForm();
    if (!_isFormValid) {
      _showError('Please correct the errors in the form before saving');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      _showError('User ID not found');
      return;
    }

    final apiUrl = '$baseApiUrl/ingredients/${widget.ingredient.ingredientId}';

    try {
      final updateResponse = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'userId': userId,
          'category': _selectedCategory,
          'storageMethod': _selectedStorageMethod,
          'ingredientId': widget.ingredient.ingredientId,
          'userQuantity': int.parse(_quantityController.text),
          'name': _nameController.text.trim(),
          'expirationDate': _expirationDateController.text,
          'calories': _caloriesController.text.isNotEmpty
              ? double.parse(_caloriesController.text)
              : null, // 允许为空
          'protein': _proteinController.text.isNotEmpty
              ? double.parse(_proteinController.text)
              : null,
          'fat': _fatController.text.isNotEmpty
              ? double.parse(_fatController.text)
              : null,
          'carbohydrates': _carbohydratesController.text.isNotEmpty
              ? double.parse(_carbohydratesController.text)
              : null,
          'fiber': _fiberController.text.isNotEmpty
              ? double.parse(_fiberController.text)
              : null,
          'unit': _unitController.text,
          'imageURL': _newImageUrl ?? widget.ingredient.imageURL,
        }),
      );

      if (updateResponse.statusCode == 200) {
        Provider.of<IngredientProvider>(context, listen: false)
            .updateIngredient(
          widget.index,
          Ingredient(
            name: _nameController.text.trim(),
            category: _selectedCategory!,
            storageMethod: _selectedStorageMethod!,
            expirationDate: _expirationDateController.text,
            baseQuantity: int.parse(_quantityController.text),
            calories: _caloriesController.text.isNotEmpty
                ? double.parse(_caloriesController.text)
                : 0.0,
            protein: _proteinController.text.isNotEmpty
                ? double.parse(_proteinController.text)
                : 0.0,
            fat: _fatController.text.isNotEmpty
                ? double.parse(_fatController.text)
                : 0.0,
            carbohydrates: _carbohydratesController.text.isNotEmpty
                ? double.parse(_carbohydratesController.text)
                : 0.0,
            fiber: _fiberController.text.isNotEmpty
                ? double.parse(_fiberController.text)
                : 0.0,
            ingredientId: widget.ingredient.ingredientId,
            imageURL: _newImageUrl ?? widget.ingredient.imageURL,
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
    } catch (e) {
      _showError('Error occurred while updating the ingredient');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.red))),
    );
  }

  List<String> _matchingPresets = [];
  bool _showDropdown = false;

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

  Future<void> _fillFormWithPreset(String presetName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseApiUrl/presetsaddfood/name/$presetName'),
      );

      if (response.statusCode == 200) {
        final presetData = jsonDecode(response.body);

        setState(() {
          _nameController.text = presetData['name'];
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
          _expirationDateController.text = presetData['expirationDate'];
          _showDropdown = false;
        });

        _validateForm();
      } else {
        _showError('No preset found with the name $presetName');
      }
    } catch (e) {
      _showError('Error fetching preset: ${e.toString()}');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      final int fileSizeInBytes = await file.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 1) {
        _showError('File size exceeds 1MB. Please choose a smaller image.');
        return;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseApiUrl/ingredients/upload_image'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      request.fields['oldImageUrl'] = widget.ingredient.imageURL ?? '';

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final responseBody = json.decode(responseData.body);
        setState(() {
          _newImageUrl = responseBody['imageUrl'];
        });
      } else {
        _showError('Failed to upload image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.ingredient.name,
            style: const TextStyle(
              color: text,
            )),
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: text,
            ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _onDebounce(() {
                    if (_isEditing) {
                      _pickImage();
                    }
                  });
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: greyBorderColor),
                    borderRadius: BorderRadius.circular(8),
                    image: (_newImageUrl != null && _newImageUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(_newImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : (widget.ingredient.imageURL.isNotEmpty)
                            ? DecorationImage(
                                image:
                                    NetworkImage(widget.ingredient.imageURL!),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: (_isEditing && _newImageUrl == null)
                      ? const Center(
                          child: Text(
                            'Tap to change image',
                            style: TextStyle(
                                color: Color.fromARGB(255, 18, 59, 88)),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              // 食材名称输入框和搜索下拉菜单
              if (_isEditing)
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    filled: true,
                    fillColor: whiteFillColor,
                    border: const OutlineInputBorder(),
                    errorText: _isNameValid ? null : 'Name cannot be empty',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        if (_nameController.text.isNotEmpty) {
                          _getMatchingPresets(_nameController.text);
                        }
                      },
                    ),
                  ),
                  onChanged: (value) {
                    _validateForm();
                  },
                ),
              if (_isEditing && _showDropdown)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _matchingPresets.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_matchingPresets[index]),
                      onTap: () => _fillFormWithPreset(_matchingPresets[index]),
                    );
                  },
                ),
              const SizedBox(height: 16),
              // 类别选择
              _isEditing
                  ? DropdownButtonFormField<String>(
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
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        filled: true,
                        fillColor: whiteFillColor,
                        border: OutlineInputBorder(),
                      ),
                    )
                  : Text('Category: ${widget.ingredient.category}'),
              const SizedBox(height: 16),
              // 存储方式选择
              _isEditing
                  ? DropdownButtonFormField<String>(
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
                      decoration: const InputDecoration(
                        labelText: 'Storage Method',
                        filled: true,
                        fillColor: whiteFillColor,
                        border: OutlineInputBorder(),
                      ),
                    )
                  : Text('Storage Method: ${widget.ingredient.storageMethod}'),
              const SizedBox(height: 16),
              // 过期日期选择
              _isEditing
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _expirationDateController,
                            decoration: InputDecoration(
                              labelText: 'Expiration Date',
                              filled: true,
                              fillColor: whiteFillColor,
                              border: const OutlineInputBorder(),
                              errorText: _isExpirationDateValid
                                  ? null
                                  : 'Invalid expiration date',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.calendar_today,
                                    color: greyIconColor),
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      _expirationDateController.text =
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickedDate);
                                      _validateForm();
                                    });
                                  }
                                },
                              ),
                            ),
                            onChanged: (value) {
                              _onDebounce(() {
                                _validateForm();
                              });
                            },
                          ),
                        ),
                      ],
                    )
                  : Text('Expires on: ${widget.ingredient.expirationDate}'),
              const SizedBox(height: 16),
              // 数量
              _isEditing
                  ? TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        filled: true,
                        fillColor: whiteFillColor,
                        border: const OutlineInputBorder(),
                        errorText: _isQuantityValid ? null : 'Invalid quantity',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _onDebounce(() {
                          _validateForm();
                        });
                      },
                    )
                  : Text('Quantity: ${widget.ingredient.baseQuantity}'),
              const SizedBox(height: 16),
              // 单位
              _isEditing
                  ? TextField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                          labelText: 'Unit',
                          filled: true,
                          fillColor: whiteFillColor,
                          border: OutlineInputBorder()),
                      onChanged: (value) {
                        _onDebounce(() {
                          _validateForm();
                        });
                      },
                    )
                  : Text('Unit: ${widget.ingredient.unit}'),
              const SizedBox(height: 16),
              // 热量
              _isEditing
                  ? TextField(
                      controller: _caloriesController,
                      decoration: InputDecoration(
                        labelText: 'Calories',
                        filled: true,
                        fillColor: whiteFillColor,
                        border: const OutlineInputBorder(),
                        errorText: _isCaloriesValid ? null : 'Invalid calories',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        _onDebounce(() {
                          _validateForm();
                        });
                      },
                    )
                  : Text('Calories: ${widget.ingredient.calories} kcal'),
              const SizedBox(height: 16),
              // 蛋白质
              _isEditing
                  ? TextField(
                      controller: _proteinController,
                      decoration: InputDecoration(
                        labelText: 'Protein',
                        filled: true,
                        fillColor: whiteFillColor,
                        border: const OutlineInputBorder(),
                        errorText: _isProteinValid ? null : 'Invalid protein',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        _onDebounce(() {
                          _validateForm();
                        });
                      },
                    )
                  : Text('Protein: ${widget.ingredient.protein} g'),
              const SizedBox(height: 16),
              // 脂肪
              _isEditing
                  ? TextField(
                      controller: _fatController,
                      decoration: InputDecoration(
                        labelText: 'Fat',
                        filled: true,
                        fillColor: whiteFillColor,
                        border: const OutlineInputBorder(),
                        errorText: _isFatValid ? null : 'Invalid fat',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        _onDebounce(() {
                          _validateForm();
                        });
                      },
                    )
                  : Text('Fat: ${widget.ingredient.fat} g'),
              const SizedBox(height: 16),
              // 碳水化合物
              _isEditing
                  ? TextField(
                      controller: _carbohydratesController,
                      decoration: InputDecoration(
                        labelText: 'Carbohydrates',
                        filled: true,
                        fillColor: whiteFillColor,
                        border: const OutlineInputBorder(),
                        errorText: _isCarbohydratesValid
                            ? null
                            : 'Invalid carbohydrates',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        _onDebounce(() {
                          _validateForm();
                        });
                      },
                    )
                  : Text('Carbohydrates: ${widget.ingredient.carbohydrates} g'),
              const SizedBox(height: 16),
              // 纤维
              _isEditing
                  ? TextField(
                      controller: _fiberController,
                      decoration: InputDecoration(
                        labelText: 'Fiber',
                        filled: true,
                        fillColor: whiteFillColor,
                        border: const OutlineInputBorder(),
                        errorText: _isFiberValid ? null : 'Invalid fiber',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        _onDebounce(() {
                          _validateForm();
                        });
                      },
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
