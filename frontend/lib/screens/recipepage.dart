import 'package:flutter/material.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:foo_my_food_app/models/recipe.dart';
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_recipe.dart';
import 'recipe_detail.dart';
import 'smart_menu_page.dart';

class RecipePage extends StatefulWidget {
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  List<Recipe> _recipes = [];
  String userId = '';
  final Set<Recipe> _selectedRecipes = {}; // 存储选中的菜谱
  bool _isSelecting = false; // 控制是否启用选择功能
  int _totalCalories = 0;

  final Set<String> _selectedLabels = {}; // 存储选中的标签
  List<Recipe> _filteredRecipes = []; // 存储筛选后的菜谱
  final List<String> _labels = [
    'breakfast',
    'lunch',
    'dinner',
    'dessert',
    'snack',
    'vegan',
    'vegetarian'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _calculateTotalCalories() {
    setState(() {
      _totalCalories = _selectedRecipes.fold(
          0, (sum, recipe) => sum + (recipe.calories ?? 0));
    });
  }

  void _showNutritionReport(int totalCalories) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nutritional Information'),
          content: Text('Total Calories: $totalCalories kcal'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // 关闭当前对话框
                await _showMarkAsCookedDialog(); // 直接在这里调用对话框
              },
              child: const Text('Mark as Cooked'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMarkAsCookedDialog() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark Recipes as Cooked Today'),
          content: const Text(
              'Would you like to mark these selected recipes as cooked today?'),
          actions: [
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
    );

    // 如果用户点击了“是”，则调用存储方法
    if (confirmed) {
      await _markSelectedRecipesAsCooked();
    }
  }

  Future<void> _markSelectedRecipesAsCooked() async {
    if (_selectedRecipes.isEmpty) {
      print('No recipes selected to mark as cooked.');
      return;
    }

    DateTime today = DateTime.now();
    String formattedDate = "${today.year}-${today.month}-${today.day}";

    for (var recipe in _selectedRecipes) {
      print('Marking recipe as cooked:');
      print('User ID: $userId');
      print('Recipe ID: ${recipe.id}');
      print('Cooking Date: $formattedDate');

      final response = await http.post(
        Uri.parse('$baseApiUrl/api/cooking_history'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'recipeId': recipe.id.toString(),
          'cookingDate': formattedDate,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Marked ${recipe.name} as cooked today.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark ${recipe.name} as cooked.')),
        );
        print('Error: ${response.statusCode} - ${response.body}');
      }
    }
    _fetchUserRecipes(); // 刷新菜谱列表以更新制作次数
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUserId = prefs.getString('userId');
    if (savedUserId != null) {
      setState(() {
        userId = savedUserId;
      });
      _fetchUserRecipes();
    }
  }

  Future<void> _fetchUserRecipes() async {
    try {
      final response =
          await http.get(Uri.parse('$baseApiUrl/myrecipes/user/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> recipeData = json.decode(response.body);
        List<Recipe> recipes =
            recipeData.map((data) => Recipe.fromJson(data)).toList();
        setState(() {
          _recipes = recipes;
          _applyFilters();
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _confirmDeleteRecipe(int recipeId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this recipe?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteRecipe(recipeId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecipe(int recipeId) async {
    final apiUrl = '$baseApiUrl/recipes/$recipeId';
    try {
      final response = await http.delete(Uri.parse(apiUrl));
      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe deleted successfully!')),
        );
        _fetchUserRecipes(); // Refresh the list after deletion
      } else {
        throw Exception('Failed to delete recipe');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _applyFilters() {
    if (_selectedLabels.isEmpty) {
      _filteredRecipes = _recipes;
    } else {
      _filteredRecipes = _recipes.where((recipe) {
        final recipeLabels = recipe.labels?.split(', ') ?? [];
        return _selectedLabels.every((label) =>
            recipeLabels.contains(label) && label.isNotEmpty); // 确保过滤掉空标签
      }).toList();
    }
    setState(() {});
  }

  void _showLabelFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: _labels.map((String label) {
                      return CheckboxListTile(
                        title: Text(label),
                        value: _selectedLabels.contains(label),
                        onChanged: (bool? selected) {
                          setModalState(() {
                            if (selected == true) {
                              _selectedLabels.add(label);
                            } else {
                              _selectedLabels.remove(label);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedLabels.clear();
                        });
                        Navigator.pop(context);
                        _applyFilters(); // 应用更改
                      },
                      child: const Text('Clear'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyFilters(); // 应用过滤器
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('My Recipes', style: TextStyle(color: Colors.white)),
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showLabelFilterDialog, // 显示筛选弹窗
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _filteredRecipes.isEmpty
                ? const Center(
                    child: Text(
                      'No recipes match your filters. Click the + to add or adjust filters.',
                      style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 9,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _filteredRecipes[index];
                      final isSelected = _selectedRecipes.contains(recipe);

                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailPage(
                                    recipe: recipe.toJson(),
                                    userId: userId,
                                    index: index,
                                  ),
                                ),
                              ).then((_) {
                                _fetchUserRecipes(); // 刷新列表
                              });
                            },
                            child: Card(
                              color: card,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 3,
                                      child: recipe.imageUrl != null &&
                                              recipe.imageUrl!.isNotEmpty
                                          ? Image.network(recipe.imageUrl!,
                                              fit: BoxFit.cover)
                                          : const Icon(Icons.image, size: 50),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          recipe.name,
                                          style: const TextStyle(
                                            color: cardnametext,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Calories: ${recipe.calories} kcal',
                                          style: const TextStyle(
                                              color: cardexpirestext),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 4,
                                          runSpacing: 4,
                                          alignment: WrapAlignment.center,
                                          children: recipe.labels != null &&
                                                  recipe.labels!.isNotEmpty
                                              ? recipe.labels!
                                                  .split(', ')
                                                  .where((label) => label
                                                      .isNotEmpty) // 确保标签不为空
                                                  .map((label) {
                                                  return Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 2,
                                                        horizontal: 6),
                                                    decoration: BoxDecoration(
                                                      color: lablebackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      label,
                                                      style: const TextStyle(
                                                          color:
                                                              cardexpirestext,
                                                          fontSize: 12),
                                                    ),
                                                  );
                                                }).toList()
                                              : [
                                                  const Text(
                                                    "No label in this Recipe",
                                                    style: TextStyle(
                                                        color: cardexpirestext,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_isSelecting)
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (bool? selected) {
                                        setState(() {
                                          if (selected == true) {
                                            _selectedRecipes.add(recipe);
                                          } else {
                                            _selectedRecipes.remove(recipe);
                                          }
                                          _calculateTotalCalories(); // 更新总卡路里
                                          print(
                                              'Selected recipes: $_selectedRecipes');
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(
                                Icons.delete_forever_rounded,
                                color: _isSelecting
                                    ? Colors.grey
                                    : Colors.red, // 在选择模式下使用灰色图标
                              ),
                              onPressed: _isSelecting
                                  ? null
                                  : () => _confirmDeleteRecipe(
                                      recipe.id), // 禁用点击事件但保持图标显示
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SmartMenuPage(userId: userId),
                  ),
                );
              },
              child: Text("Don't know what to eat?"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (_isSelecting) {
                  // 如果未选择任何食谱，弹出提示
                  if (_selectedRecipes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('You have not selected any recipes')),
                    );
                  } else {
                    // 计算总卡路里并退出选择模式
                    _showNutritionReport(_totalCalories);
                    setState(() {
                      _isSelecting = false;
                      _selectedRecipes.clear();
                      _totalCalories = 0;
                    });
                  }
                } else {
                  // 进入选择模式
                  setState(() {
                    _isSelecting = true;
                    _selectedRecipes.clear();
                    _totalCalories = 0;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSelecting && _selectedRecipes.isEmpty
                    ? Colors.grey
                    : buttonBackgroundColor,
              ),
              icon: Icon(
                _isSelecting ? Icons.calculate : Icons.select_all,
                color: Colors.white,
              ),
              label: Text(
                _isSelecting ? 'Calculate' : 'Select Recipes',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (_isSelecting)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _isSelecting = false; // 退出选择模式
                    _selectedRecipes.clear();
                    _totalCalories = 0; // 重置总卡路里
                  });
                },
                tooltip: 'Exit selection mode',
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecipePage()),
          ).then((_) {
            _fetchUserRecipes();
          });
        },
        backgroundColor: buttonBackgroundColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
