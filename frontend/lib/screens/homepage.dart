import 'package:flutter/material.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:foo_my_food_app/models/ingredient.dart';
import 'ingredient_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foo_my_food_app/utils/constants.dart';
import 'login_page.dart';
import 'add_ingredient_manually.dart';
import 'user_info_page.dart';
import 'package:provider/provider.dart';
import 'package:foo_my_food_app/providers/ingredient_provider.dart';
import 'recipepage.dart';

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
      _fetchUserIngredients();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _fetchUserIngredients() async {
    try {
      final response =
          await http.get(Uri.parse('$baseApiUrl/user_ingredients/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> userIngredientsData = json.decode(response.body);
        List<Ingredient> ingredients = [];

        for (var item in userIngredientsData) {
          int? ingredientId = item['ingredientId'];
          int userQuantity = item['userQuantity'];

          if (ingredientId == null) continue;

          final ingredientResponse = await http
              .get(Uri.parse('$baseApiUrl/ingredients/$ingredientId'));
          if (ingredientResponse.statusCode == 200) {
            final ingredientData = json.decode(ingredientResponse.body);
            ingredients.add(Ingredient.fromJson(ingredientData));
          }
        }

        Provider.of<IngredientProvider>(context, listen: false).ingredients =
            ingredients;
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
      _fetchUserIngredients();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    MyFoodPage(),
    RecipePage(),
    UserProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text(widget.title, style: TextStyle(color: text)),
              backgroundColor: buttonBackgroundColor,
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              heroTag: "Add",
              onPressed: _navigateToAddIngredient,
              backgroundColor: buttonBackgroundColor,
              tooltip: 'Add Ingredient',
              child: const Icon(Icons.add, color: whiteTextColor),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.food_bank_outlined), label: 'My Food'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_rounded), label: 'Recipes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: text,
        onTap: _onItemTapped,
        backgroundColor: buttonBackgroundColor,
      ),
    );
  }
}

class MyFoodPage extends StatelessWidget {
  // HIGHLIGHT: Added delete ingredient function
  Future<void> _deleteIngredient(BuildContext context, String userId, int ingredientId,int index) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseApiUrl/user_ingredients/$userId/$ingredientId'),
      );
      print(response.statusCode);
      if (response.statusCode == 204) {
       
        Provider.of<IngredientProvider>(context, listen: false)
            .removeIngredient(index);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete ingredient');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting ingredient: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IngredientProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                ),
                itemCount: provider.ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = provider.ingredients[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodItemDetailPage(
                            ingredient: ingredient,
                            userId: "",
                            index: index,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      color: card,
                      // HIGHLIGHT: Wrapped Column with Stack to add delete button
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (ingredient.imageURL.isNotEmpty)
                                CircleAvatar(
                                  backgroundColor: greyBackgroundColor,
                                  backgroundImage: NetworkImage(ingredient.imageURL),
                                  radius: 40,
                                ),
                              const SizedBox(height: 10),
                              Text(
                                ingredient.name,
                                style: const TextStyle(
                                  color: cardnametext,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Expires: ${ingredient.expirationDate}',
                                style: const TextStyle(color: cardexpirestext),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          // HIGHLIGHT: Added delete button
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool confirmDelete = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: const Text('Are you sure you want to delete this ingredient?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () => Navigator.of(context).pop(false),
                                        ),
                                        TextButton(
                                          child: const Text('Delete'),
                                          onPressed: () => Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmDelete) {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  String userId = prefs.getString('userId') ?? '';
                                  _deleteIngredient(context, userId,ingredient.ingredientId, index);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}