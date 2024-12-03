import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

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
    final filteredLabels = (_selectedLabels.isEmpty ||
            _selectedLabels.every((label) => label.trim().isEmpty))
        ? null
        : _selectedLabels.join(', ');

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

  // Future<void> _pickImage() async {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SafeArea(
  //         child: Wrap(
  //           children: <Widget>[
  //             ListTile(
  //               leading: const Icon(Icons.camera_alt),
  //               title: const Text('Take a photo'),
  //               onTap: () async {
  //                 Navigator.of(context).pop();
  //                 final pickedFile =
  //                     await ImagePicker().pickImage(source: ImageSource.camera);
  //                 if (pickedFile != null) {
  //                   setState(() {
  //                     _imageFile = File(pickedFile.path);
  //                   });
  //                 }
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.photo_library),
  //               title: const Text('Choose from gallery'),
  //               onTap: () async {
  //                 Navigator.of(context).pop();
  //                 final pickedFile = await ImagePicker()
  //                     .pickImage(source: ImageSource.gallery);
  //                 if (pickedFile != null) {
  //                   setState(() {
  //                     _imageFile = File(pickedFile.path);
  //                   });
  //                 }
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
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
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(widget.recipe['name'],
            style: TextStyle(color: AppColors.textColor(context))),
        backgroundColor: AppColors.appBarColor(context),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit,
                color: AppColors.textColor(context)),
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
          IconButton(
            icon: Icon(Icons.download, color: AppColors.textColor(context)),
            onPressed: _showConfirmationDialog, // Show confirmation dialog
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
                : Text(
                    'Labels: ${widget.recipe['labels']?.isNotEmpty == true ? widget.recipe['labels'] : 'No label in this Recipe'}',
                  ),
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
                : Text(
                    'Description: ${widget.recipe['description'] ?? 'No description for this recipe'}',
                  ),
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
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // 确保内容从顶部对齐
                    children: [
                      const Text(
                        'Video Link: ',
                        style: TextStyle(fontSize: 16),
                      ),
                      if (widget.recipe['videoLink'] != null &&
                          widget.recipe['videoLink'].isNotEmpty)
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              final url = Uri.parse(widget.recipe['videoLink']);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Could not launch ${widget.recipe['videoLink']}'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              widget.recipe['videoLink'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              softWrap: true, // 启用自动换行
                            ),
                          ),
                        )
                      else
                        const Text(
                          'No video link for this recipe',
                          style: TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
            const SizedBox(height: 16),
            if (!widget.isPresetRecipe)
              Text(
                'Total Times Cooked: ${widget.recipe['cookCount'] ?? 0}',
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save as Picture'),
          content: const Text(
              'Do you want to save this recipe as a picture in the gallery?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User chose "No"
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User chose "Yes"
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    // Proceed with saving the image if the user confirmed
    if (result == true) {
      await _saveImageToGallery();
    }
  }

  Future<void> _saveImageToGallery() async {
    // Request storage permission
    final permission = await Permission.storage.request();
    if (!permission.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied.')),
      );
      return;
    }

    try {
      // Create canvas and draw content (same as your previous logic)
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 1080, 1920));

      // Background color
      final paint = Paint()
        ..color = const Color(0xFFFFFFFF); // White background
      canvas.drawRect(const Rect.fromLTWH(0, 0, 1080, 1920), paint);

      // Title
      final titleStyle = ui.TextStyle(
        color: const Color(0xFF000000),
        fontSize: 48,
        fontWeight: ui.FontWeight.bold,
      );
      final titleParagraph =
          ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center))
            ..pushStyle(titleStyle)
            ..addText(widget.recipe['name']);
      final titleParagraphLayout = titleParagraph.build()
        ..layout(const ui.ParagraphConstraints(width: 1000));
      canvas.drawParagraph(titleParagraphLayout, const Offset(40, 60));

      // Ingredients
      final ingredientStyle = ui.TextStyle(
        color: const Color(0xFF333333),
        fontSize: 36,
      );
      final ingredientText = 'Ingredients: ${widget.recipe['ingredients']}';
      final ingredientParagraph =
          ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.left))
            ..pushStyle(ingredientStyle)
            ..addText(ingredientText);
      final ingredientParagraphLayout = ingredientParagraph.build()
        ..layout(const ui.ParagraphConstraints(width: 1000));
      canvas.drawParagraph(ingredientParagraphLayout, const Offset(40, 200));

      // Description
      final descriptionStyle = ui.TextStyle(
        color: const Color(0xFF555555),
        fontSize: 32,
      );
      final descriptionText = 'Description:\n${widget.recipe['description']}';
      final descriptionParagraph =
          ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.left))
            ..pushStyle(descriptionStyle)
            ..addText(descriptionText);
      final descriptionParagraphLayout = descriptionParagraph.build()
        ..layout(const ui.ParagraphConstraints(width: 1000));
      canvas.drawParagraph(descriptionParagraphLayout, const Offset(40, 400));

      // End recording
      final picture = recorder.endRecording();
      final img = await picture.toImage(1080, 1920);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      // Save to gallery
      if (pngBytes != null) {
        final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(pngBytes),
          quality: 80,
          name: 'recipe_${widget.recipe['name']}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['isSuccess']
                  ? 'Recipe image saved to gallery!'
                  : 'Failed to save image.',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating image: $e')),
      );
    }
  }

  Future<void> _generateAndSaveImage() async {
    // 请求存储权限
    final permission = await Permission.storage.request();
    if (!permission.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied.')),
      );
      return;
    }

    try {
      // 创建画布
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 1080, 1920));

      // 设置背景颜色
      final paint = Paint()..color = const Color(0xFFFFFFFF); // 白色背景
      canvas.drawRect(const Rect.fromLTWH(0, 0, 1080, 1920), paint);

      // 添加标题
      final titleStyle = ui.TextStyle(
        color: const Color(0xFF000000),
        fontSize: 48,
        fontWeight: ui.FontWeight.bold,
      );
      final titleParagraph =
          ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center))
            ..pushStyle(titleStyle)
            ..addText(widget.recipe['name']);
      final titleParagraphLayout = titleParagraph.build()
        ..layout(const ui.ParagraphConstraints(width: 1000));
      canvas.drawParagraph(titleParagraphLayout, const Offset(40, 60));

      // 添加食材信息
      final ingredientStyle = ui.TextStyle(
        color: const Color(0xFF333333),
        fontSize: 36,
      );
      final ingredientText = 'Ingredients: ${widget.recipe['ingredients']}';
      final ingredientParagraph =
          ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.left))
            ..pushStyle(ingredientStyle)
            ..addText(ingredientText);
      final ingredientParagraphLayout = ingredientParagraph.build()
        ..layout(const ui.ParagraphConstraints(width: 1000));
      canvas.drawParagraph(ingredientParagraphLayout, const Offset(40, 200));

      // 添加描述
      final descriptionStyle = ui.TextStyle(
        color: const Color(0xFF555555),
        fontSize: 32,
      );
      final descriptionText = 'Description:\n${widget.recipe['description']}';
      final descriptionParagraph =
          ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.left))
            ..pushStyle(descriptionStyle)
            ..addText(descriptionText);
      final descriptionParagraphLayout = descriptionParagraph.build()
        ..layout(const ui.ParagraphConstraints(width: 1000));
      canvas.drawParagraph(descriptionParagraphLayout, const Offset(40, 400));

      // 结束绘制
      final picture = recorder.endRecording();
      final img = await picture.toImage(1080, 1920);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      // 保存图片到相册
      if (pngBytes != null) {
        final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(pngBytes),
          quality: 80,
          name: 'recipe_${widget.recipe['name']}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['isSuccess']
                  ? 'Recipe image saved to gallery!'
                  : 'Failed to save image.',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating image: $e')),
      );
    }
  }
}
