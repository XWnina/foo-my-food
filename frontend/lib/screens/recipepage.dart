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

  @override
  void initState() {
    super.initState();
    _loadUserId();
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
      final response = await http.get(Uri.parse('$baseApiUrl/myrecipes/user/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> recipeData = json.decode(response.body);
        List<Recipe> recipes = recipeData.map((data) => Recipe.fromJson(data)).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes', style: TextStyle(color: Colors.white)),
        backgroundColor: appBarColor,
      ),
      body: _recipes.isEmpty
          ? const Center(
              child: Text(
                'No recipes added yet! Click the + button to add.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                final recipe = _recipes[index];
                return ListTile(
                  title: Text(recipe.name),
                  subtitle: Text('Calories: ${recipe.calories ?? 'N/A'}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(
                          recipe: recipe.toJson(), // 将 Recipe 转换为 Map<String, dynamic>
                          userId: userId,
                          index: index,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipePage()),
          ).then((_) {
            _fetchUserRecipes(); // Refresh the recipe list after adding a new recipe
          });
        },
        backgroundColor: buttonBackgroundColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
