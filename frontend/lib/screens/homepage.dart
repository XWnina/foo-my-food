import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:foo_my_food_app/models/ingredient.dart'; // Import the Ingredient model
import 'ingredient_detail.dart'; // Import the detail page
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foo_my_food_app/utils/constants.dart';
import 'login_page.dart';
import 'add_ingredient_manually.dart';
import 'user_info_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Ingredient> ingredients = [];
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
      _fetchUserIngredients();
    } else {
      // Redirect to login if userId is not found
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _fetchUserIngredients() async {
    try {
      // Get user ingredients
      final response = await http.get(Uri.parse('$baseApiUrl/user_ingredients/$userId'));
      
      if (response.statusCode == 200) {
        final List<dynamic> userIngredientsData = json.decode(response.body);
        print('User Ingredients: $userIngredientsData');

        // Create a list to store ingredient information
        List<Ingredient> ingredients = [];

        // Iterate through user ingredients data
        for (var item in userIngredientsData) {
          int? ingredientId = item['ingredientId']; 
          int userQuantity = item['userQuantity'];
          // Fetch ingredient details
          if (ingredientId == null) {
          print('Skipping ingredient with null ID');
          continue; // Skip to the next iteration if ingredientId is null
        }
          final ingredientResponse = await http.get(Uri.parse('$baseApiUrl/ingredients/$ingredientId'));
          
          if (ingredientResponse.statusCode == 200) {
            final ingredientData = json.decode(ingredientResponse.body);
            print('Ingredient: $ingredientData');

            // Convert the ingredient data to an Ingredient object
            ingredients.add(Ingredient.fromJson(ingredientData));
          } else {
            print('Failed to load ingredient with ID $ingredientId');
          }
        }

        // Update state
        setState(() {
          this.ingredients = ingredients;
        });
      } else {
        throw Exception('Failed to load user ingredients');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _navigateToAddIngredient() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddIngredientPage()),
    ).then((_) {
      _fetchUserIngredients(); // 重新获取食材
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfile()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Search box (optional)
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
              ),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(ingredient.imageURL)),
                    title: Text(ingredient.name),
                    subtitle: Text('Expires: ${ingredient.expirationDate}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodItemDetailPage(ingredient: ingredient, userId: userId),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddIngredient,
        tooltip: 'Add Ingredient',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_rounded), label: 'Recipes'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_rounded), label: 'My Account'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}