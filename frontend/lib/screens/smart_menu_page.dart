import 'package:flutter/material.dart';
import 'package:foo_my_food_app/services/recipe_collection_service.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:foo_my_food_app/models/recipe.dart';
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_recipe.dart';
import 'recipe_detail.dart';

class SmartMenuPage extends StatefulWidget {
  final String userId;

  const SmartMenuPage({Key? key, required this.userId}) : super(key: key);

  @override
  _SmartMenuPageState createState() => _SmartMenuPageState();
}

class _SmartMenuPageState extends State<SmartMenuPage> {
  final RecipeCollectionService _recipeCollectionService =
      RecipeCollectionService();
  Set<String> _favoriteRecipes = {};
  List<Recipe> _myRecipes = [];
  List<Recipe> _presetRecipes = [];
  List<Recipe> _filteredMyRecipes = [];
  List<Recipe> _filteredPresetRecipes = [];
  final Set<Recipe> _selectedRecipes = {};
  bool _isSelecting = false;
  int _totalCalories = 0;
  String _searchQuery = '';
  String _sortBy = 'what_i_have';
  Map<String, Recipe?> _mealPlan = {
    'breakfast': null,
    'lunch': null,
    'dinner': null,
  };
  List<String> _matchingIngredients = [];
  bool _showDropdown = false;
  bool _showNoResultsMessage = false;
  TextEditingController _searchController = TextEditingController();
  List<String> _selectedIngredients = [];
  final Map<String, String> _modeDisplayNames = {
    'what_i_have': 'What I Have',
    'expires_soon': 'Expires Soon',
    'usually_cooked': 'Usually Cooked',
  };
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _fetchRecipes(),
      _fetchUserFavorites(),
    ]);
    _generateMealPlan();
  }

  void _toggleFavorite(Recipe recipe, bool isPresetRecipe) async {
    final String key =
        isPresetRecipe ? 'preset_${recipe.id}' : 'my_${recipe.id}';
    final bool isFavorited = _favoriteRecipes.contains(key);

    try {
      if (isFavorited) {
        await _recipeCollectionService.removeFavorite(
            widget.userId,
            isPresetRecipe ? null : recipe.id.toString(),
            isPresetRecipe ? recipe.id.toString() : null);
        setState(() {
          _favoriteRecipes.remove(key);
        });
      } else {
        await _recipeCollectionService.addFavorite(
            widget.userId,
            isPresetRecipe ? null : recipe.id.toString(),
            isPresetRecipe ? recipe.id.toString() : null);
        setState(() {
          _favoriteRecipes.add(key);
        });
      }
    } catch (e) {
      print('Error in toggle favorite: $e');
      // 可以添加错误提示，如：SnackBar通知用户操作失败
    }
  }

  // 获取用户的收藏
  Future<void> _fetchUserFavorites() async {
    try {
      final favoritesData =
          await _recipeCollectionService.getUserFavorites(widget.userId);
      setState(() {
        for (var item in favoritesData) {
          final isPreset = item['presetRecipeId'] != null;
          final id = item[isPreset ? 'presetRecipeId' : 'recipeId'].toString();
          _favoriteRecipes.add(isPreset ? 'preset_$id' : 'my_$id');
        }
      });
    } catch (e) {
      print('Error fetching favorites: $e');
      // 可以使用 SnackBar 或对话框提示用户
    }
  }
  // 检查菜谱是否已收藏
bool _isRecipeFavorited(Recipe recipe, bool isPresetRecipe) {
  final String key = isPresetRecipe ? 'preset_${recipe.id}' : 'my_${recipe.id}';
  return _favoriteRecipes.contains(key);
}



  Future<void> _fetchRecipes() async {
    try {
      String customRecipesUrl;
      String presetRecipesUrl;

      switch (_sortBy) {
        case 'expires_soon':
          customRecipesUrl = '$baseApiUrl/recipes/custom/expiring?userId=${widget.userId}';
          presetRecipesUrl = '$baseApiUrl/recipes/preset/expiring?userId=${widget.userId}';
          break;
        case 'usually_cooked':
          // TODO: Implement when backend supports this feature
          customRecipesUrl = '$baseApiUrl/myrecipes/user/${widget.userId}';
          presetRecipesUrl = '$baseApiUrl/preset-recipes';
          break;
        case 'what_i_have':
        default:
          //print("yeaahhh");
          //print(widget.userId);
          customRecipesUrl = '$baseApiUrl/recipes/custom?userId=${widget.userId}';
          presetRecipesUrl = '$baseApiUrl/recipes/preset?userId=${widget.userId}';
          break;
      }
      final customRecipesResponse = await http.get(Uri.parse(customRecipesUrl));
      final presetRecipesResponse = await http.get(Uri.parse(presetRecipesUrl));
      if (customRecipesResponse.statusCode == 200 && presetRecipesResponse.statusCode == 200) {
        final List<dynamic> customRecipeData = json.decode(customRecipesResponse.body);
        final List<dynamic> presetRecipeData = json.decode(presetRecipesResponse.body);

        // setState(() {
        //   _myRecipes = customRecipeData.map((data) => Recipe.fromJson(data)).toList();
        //   _presetRecipes = presetRecipeData.map((data) => Recipe.fromJson(data)).toList();
        //   _applyFilters();
        // });
            setState(() {
            _myRecipes = customRecipeData.map((data) {
              print('Custom Recipe Data: $data'); // 打印 custom recipe data
              return Recipe.fromJson(data);
            }).toList();

            _presetRecipes = presetRecipeData.map((data) {
              print('Preset Recipe Data: $data'); // 打印 preset recipe data
              return Recipe.fromJson(data);
            }).toList();
            _applyFilters();
          });
          _generateMealPlan();
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error: $e');
    }
  }



    void _applyFilters() {
    setState(() {
      if (_selectedIngredients.isEmpty) {
        _filteredMyRecipes = _myRecipes;
        _filteredPresetRecipes = _presetRecipes;
      } else {
        _filteredMyRecipes = _myRecipes.where((recipe) {
          return _selectedIngredients.every((ingredient) => recipe.ingredients
              .any((recipeIngredient) => recipeIngredient
                  .toLowerCase()
                  .contains(ingredient.toLowerCase())));
        }).toList();

        _filteredPresetRecipes = _presetRecipes.where((recipe) {
          return _selectedIngredients.every((ingredient) => recipe.ingredients
              .any((recipeIngredient) => recipeIngredient
                  .toLowerCase()
                  .contains(ingredient.toLowerCase())));
        }).toList();
      }

      // No need for additional sorting as the API now returns sorted results
    });
  }


  void _addIngredient(String ingredient) {
    if (ingredient.isNotEmpty && !_selectedIngredients.contains(ingredient)) {
      setState(() {
        _selectedIngredients.add(ingredient);
        _searchController.clear();
        _showDropdown = false;
        _applyFilters();
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _selectedIngredients.remove(ingredient);
      _applyFilters();
    });
  }

  Widget _buildIngredientChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _selectedIngredients.map((ingredient) {
        return Chip(
          label: Text(ingredient),
          deleteIcon: Icon(Icons.close, size: 18),
          onDeleted: () => _removeIngredient(ingredient),
          backgroundColor: Colors.blue[100],
          labelStyle: TextStyle(color: Colors.blue[900]),
        );
      }).toList(),
    );
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

void _generateMealPlan() {
    if (_filteredMyRecipes.isEmpty && _filteredPresetRecipes.isEmpty) {
      setState(() {
        _mealPlan = {
          'breakfast': null,
          'lunch': null,
          'dinner': null,
        };
      });
      return;
    }

    List<Recipe> allRecipes = [..._filteredMyRecipes, ..._filteredPresetRecipes];

    /// New: Create a copy of allRecipes to modify
    List<Recipe> availableRecipes = List.from(allRecipes);

    setState(() {
      _mealPlan = {
        'breakfast': _getRandomRecipeByLabel(availableRecipes, 'breakfast'),
        'lunch': _getRandomRecipeByLabel(availableRecipes, 'lunch'),
        'dinner': _getRandomRecipeByLabel(availableRecipes, 'dinner'),
      };
    });
  }


  Recipe? _getRandomRecipeByLabel(List<Recipe> recipes, String label) {
    final matchingRecipes = recipes.where((recipe) =>
      recipe.labels?.toLowerCase().contains(label.toLowerCase()) ?? false
    ).toList();
    if (matchingRecipes.isEmpty) return null;
    matchingRecipes.shuffle();
    Recipe selectedRecipe = matchingRecipes.first;
    /// New: Remove the selected recipe from the available recipes
    recipes.remove(selectedRecipe);
    return selectedRecipe;
  }


  Future<void> _getMatchingIngredients(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseApiUrl/presetsaddfood/search?query=$query'),
      );

      if (response.statusCode == 200) {
        final List<String> ingredients =
            List<String>.from(jsonDecode(response.body));
        setState(() {
          _matchingIngredients = ingredients;
          _showDropdown = ingredients.isNotEmpty;
          _showNoResultsMessage = ingredients.isEmpty;
        });
      } else {
        setState(() {
          _matchingIngredients = [];
          _showDropdown = false;
          _showNoResultsMessage = true;
        });
      }
    } catch (e) {
      print('Error fetching matching ingredients: ${e.toString()}');
      setState(() {
        _matchingIngredients = [];
        _showDropdown = false;
        _showNoResultsMessage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text('Smart Menu',
            style: TextStyle(color: AppColors.textColor(context))),
        backgroundColor: AppColors.appBarColor(context),
        actions: [
          // Add current mode display
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Mode: ${_modeDisplayNames[_sortBy] ?? ""}',
                style: TextStyle(color: AppColors.textColor(context)),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.sort, color: AppColors.textColor(context)),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (_selectedIngredients.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildIngredientChips(),
                  ),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search ingredients...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _showDropdown = false;
                          _showNoResultsMessage = false;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _showNoResultsMessage = false;
                    });
                    if (value.isNotEmpty) {
                      _getMatchingIngredients(value);
                    } else {
                      setState(() {
                        _showDropdown = false;
                      });
                    }
                  },
                  onSubmitted: (value) {
                    _addIngredient(value);
                  },
                ),
              ],
            ),
          ),
          if (_showDropdown)
            Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _matchingIngredients.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_matchingIngredients[index]),
                    onTap: () {
                      _addIngredient(_matchingIngredients[index]);
                    },
                  );
                },
              ),
            ),
          if (_showNoResultsMessage)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'No matching ingredients found.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                _buildRecipeSection('My Recipes', _filteredMyRecipes),
                _buildRecipeSection('Preset Recipes', _filteredPresetRecipes),
                _buildMealPlanSection(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppColors.backgroundColor(context),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRecipePage(),
                  ),
                ).then((_) {
                  _fetchRecipes();
                });
              },
              child: Text('Add Recipe',
                  style: TextStyle(color: AppColors.textColor(context))),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (_isSelecting) {
                  if (_selectedRecipes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('You have not selected any recipes')),
                    );
                  } else {
                    _showNutritionReport(_totalCalories);
                    setState(() {
                      _isSelecting = false;
                      _selectedRecipes.clear();
                      _totalCalories = 0;
                    });
                  }
                } else {
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
                    : AppColors.appBarColor(context),
              ),
              icon: Icon(_isSelecting ? Icons.calculate : Icons.select_all,
                  color: AppColors.textColor(context)),
              label: Text(
                _isSelecting ? 'Calculate' : 'Select Recipes',
                style: TextStyle(color: AppColors.textColor(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeSection(String title, List<Recipe> recipes) {
    final bool isPresetRecipe = title == 'Preset Recipes';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            // print("Nooooooooo");
            // print(recipe.toJson());
            final isSelected = _selectedRecipes.contains(recipe);

            return GestureDetector(
              onTap: () {
                // print('Recipe being passed to RecipeDetailPage:');
                // print(recipe.toJson());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(
                      recipe: recipe.toJson(),
                      userId: widget.userId,
                      index: index,
                      isPresetRecipe: isPresetRecipe,
                    ),
                  ),
                ).then((_) {
                  _fetchRecipes();
                });
              },
              child: Card(
                color: AppColors.cardColor(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.5,
                            child: recipe.imageUrl != null &&
                                    recipe.imageUrl!.isNotEmpty
                                ? Image.network(recipe.imageUrl!,
                                    fit: BoxFit.cover)
                                : const Icon(Icons.image, size: 50),
                          ),
                          // 添加星形图标
                          Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(
                              _isRecipeFavorited(recipe, isPresetRecipe)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: _isRecipeFavorited(recipe, isPresetRecipe)
                                  ? Colors.yellow
                                  : Colors.grey,
                            ),
                            onPressed: () =>
                                _toggleFavorite(recipe, isPresetRecipe),
                          ),
                        ),
                          if (_isSelecting)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (bool? selected) {
                                  setState(() {
                                    if (selected == true) {
                                      _selectedRecipes.add(recipe);
                                    } else {
                                      _selectedRecipes.remove(recipe);
                                    }
                                    _calculateTotalCalories();
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.name,
                            style: TextStyle(
                              color: AppColors.cardNameTextColor(context),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Calories: ${recipe.calories} kcal',
                            style: TextStyle(
                                color: AppColors.cardExpiresTextColor(context),
                                fontSize: 12),
                          ),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: recipe.labels?.split(', ').map((label) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.lablebackground(context),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                          color: AppColors.cardExpiresTextColor(
                                              context),
                                          fontSize: 10),
                                    ),
                                  );
                                }).toList() ??
                                [],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMealPlanSection() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Meal Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ..._mealPlan.entries.map((entry) => _buildMealItem(entry.key, entry.value)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateMealPlan,
              child: Text('Generate New Meal Plan',
                  style: TextStyle(color: AppColors.textColor(context))),
            ),
          ],
        ),
      ),
    );
  }

  /// 添加：新方法 _buildMealItem
  Widget _buildMealItem(String mealType, Recipe? recipe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            mealType.capitalize(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            recipe != null
                ? '${recipe.name} (${recipe.calories} kcal)'
                : 'No suitable recipe found',
            style: TextStyle(
              color: recipe != null ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton() {
    return TextButton(
      onPressed: _showSortOptions,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _modeDisplayNames[_sortBy] ?? '',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('What I have'),
              onTap: () {
                setState(() {
                  _sortBy = 'what_i_have';
                  _applyFilters();
                });
                Navigator.pop(context);
                 _fetchRecipes();
              },
            ),
            ListTile(
              title: Text('Expires soon'),
              onTap: () {
                setState(() {
                  _sortBy = 'expires_soon';
                  _applyFilters();
                });
                Navigator.pop(context);
                 _fetchRecipes();
              },
            ),
            ListTile(
              title: Text('Usually cooked'),
              onTap: () {
                setState(() {
                  _sortBy = 'usually_cooked';
                  _applyFilters();
                });
                Navigator.pop(context);
                 _fetchRecipes();
              },
            ),
          ],
        );
      },
    );
  }
}
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
