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
import 'package:provider/provider.dart'; // Add this import
import 'package:foo_my_food_app/providers/ingredient_provider.dart'; // Import the ingredient provider

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
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
      _fetchUserIngredients(); // Fetch ingredients after loading user ID
    } else {
      // Redirect to login if userId is not found
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  // **Update the method to use the provider**
  Future<void> _fetchUserIngredients() async {
    try {
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

          // Skip if ingredientId is null
          if (ingredientId == null) {
            print('Skipping ingredient with null ID');
            continue;
          }

          // Fetch ingredient details
          final ingredientResponse = await http.get(Uri.parse('$baseApiUrl/ingredients/$ingredientId'));

          if (ingredientResponse.statusCode == 200) {
            final ingredientData = json.decode(ingredientResponse.body);
            print('Ingredient: $ingredientData');

            ingredients.add(Ingredient.fromJson(ingredientData));
          } else {
            print('Failed to load ingredient with ID $ingredientId');
          }
        }

        // **Update the provider with fetched ingredients**
        Provider.of<IngredientProvider>(context, listen: false).ingredients = ingredients;

        print('Ingredients count: ${ingredients.length}');
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
      _fetchUserIngredients(); // Re-fetch ingredients after addition
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
    // **Use Consumer to listen for ingredient changes**
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Consumer<IngredientProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                  ),
                  itemCount: provider.ingredients.length, // Update to use provider
                  itemBuilder: (context, index) {
                    final ingredient = provider.ingredients[index]; // Update to use provider
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
                              builder: (context) => FoodItemDetailPage(
                                ingredient: ingredient,
                                userId: userId,
                                index:index,
                              ),
                            ),
                          ).then((_) {
                            _fetchUserIngredients(); // Re-fetch ingredients after returning from detail page
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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