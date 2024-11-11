import 'package:flutter/material.dart';
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
  List<Recipe> _myRecipes = [];
  List<Recipe> _presetRecipes = [];
  List<Recipe> _filteredMyRecipes = [];
  List<Recipe> _filteredPresetRecipes = [];
  final Set<Recipe> _selectedRecipes = {};
  bool _isSelecting = false;
  int _totalCalories = 0;
  String _searchQuery = '';
  String _sortBy = 'what_i_have';
  String _mealPlan = '';
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
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      final myRecipesResponse = await http
          .get(Uri.parse('$baseApiUrl/myrecipes/user/${widget.userId}'));
      final presetRecipesResponse =
          await http.get(Uri.parse('$baseApiUrl/preset-recipes'));

      if (myRecipesResponse.statusCode == 200 &&
          presetRecipesResponse.statusCode == 200) {
        final List<dynamic> myRecipeData = json.decode(myRecipesResponse.body);
        final List<dynamic> presetRecipeData =
            json.decode(presetRecipesResponse.body);

        setState(() {
          _myRecipes =
              myRecipeData.map((data) => Recipe.fromJson(data)).toList();
          _presetRecipes =
              presetRecipeData.map((data) => Recipe.fromJson(data)).toList();
          /*test*/
          print('\nMapped Preset Recipes:');
          _presetRecipes.forEach((recipe) => print(recipe.toJson()));
          /*test*/
          _applyFilters();
        });
        //print(_presetRecipes);
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

      switch (_sortBy) {
        case 'what_i_have':
          // No need to sort
          break;
        case 'expires_soon':
          // Sorting logic remains the same
          break;
        case 'usually_cooked':
          // Sorting logic remains the same
          break;
      }
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
    if (_filteredMyRecipes.length < 3) {
      setState(() {
        _mealPlan = 'Not enough recipes to generate a meal plan.';
      });
      return;
    }

    final breakfast = _filteredMyRecipes
        .where((recipe) => recipe.labels?.contains('breakfast') ?? false)
        .toList();
    final lunch = _filteredMyRecipes
        .where((recipe) => recipe.labels?.contains('lunch') ?? false)
        .toList();
    final dinner = _filteredMyRecipes
        .where((recipe) => recipe.labels?.contains('dinner') ?? false)
        .toList();

    breakfast.shuffle();
    lunch.shuffle();
    dinner.shuffle();

    setState(() {
      _mealPlan = 'Suggested Meal Plan:\n'
          'Breakfast: ${breakfast.isNotEmpty ? breakfast.first.name : 'N/A'}\n'
          'Lunch: ${lunch.isNotEmpty ? lunch.first.name : 'N/A'}\n'
          'Dinner: ${dinner.isNotEmpty ? dinner.first.name : 'N/A'}';
    });
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
                style:TextStyle(color: AppColors.textColor(context)),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
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
              child: Text('Add Recipe', style:TextStyle(color: AppColors.textColor(context))),
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
              icon: Icon(
                _isSelecting ? Icons.calculate : Icons.select_all,
                color: Colors.white,
              ),
              label: Text(
                _isSelecting ? 'Calculate' : 'Select Recipes',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeSection(String title, List<Recipe> recipes) {
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
                      isPresetRecipe: title == 'Preset Recipes',
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
                            style: const TextStyle(
                              color: cardnametext,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Calories: ${recipe.calories} kcal',
                            style: const TextStyle(
                                color: cardexpirestext, fontSize: 12),
                          ),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: recipe.labels?.split(', ').map((label) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: lablebackground,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                          color: cardexpirestext, fontSize: 10),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meal Plan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
              _mealPlan.isNotEmpty ? _mealPlan : 'No meal plan generated yet.'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _generateMealPlan,
            child: Text('Generate Meal Plan',style:TextStyle(color: AppColors.textColor(context))),
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
              },
            ),
          ],
        );
      },
    );
  }
}
