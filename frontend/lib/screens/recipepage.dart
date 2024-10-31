import 'package:flutter/material.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:foo_my_food_app/models/recipe.dart';
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_recipe.dart';
import 'recipe_detail.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('My Recipes', style: TextStyle(color: Colors.white)),
        backgroundColor: appBarColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: _recipes.isEmpty
                ? const Center(
                    child: Text(
                      'You have no recipes! Click the + to add.',
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
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
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
                                      ],
                                    ),
                                  ),
                                  // 显示选择框，用于选择菜谱
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
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteRecipe(recipe.id),
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
            ElevatedButton.icon(
              onPressed: () {
                if (_isSelecting) {
                  // In selection mode, calculate if any items are selected
                  if (_selectedRecipes.isNotEmpty) {
                    _showNutritionReport(_totalCalories);
                    setState(() {
                      _isSelecting = false;
                      _selectedRecipes.clear();
                      _totalCalories = 0;
                    });
                  }
                } else {
                  // Enter selection mode
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
              icon: Icon(_isSelecting ? Icons.calculate : Icons.select_all,
                  color: Colors.white),
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
                    _isSelecting = false; // Exit selection mode
                    _selectedRecipes.clear();
                    _totalCalories = 0; // Reset total calories
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
