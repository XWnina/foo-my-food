import 'package:flutter/material.dart';
import 'package:foo_my_food_app/providers/shopping_list_provider.dart';
import 'package:foo_my_food_app/screens/shopping_list_page.dart';
import 'package:foo_my_food_app/screens/add_shopping_item_page.dart';
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
  List<String> categories = [
    'Vegetables',
    'Fruits',
    'Meat',
    'Dairy',
    'Grains',
    'Spices',
    'Beverages'
  ];
  List<String> selectedCategories = [];

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

  // 导航到添加购物清单页面
  void _navigateToAddShoppingItem() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // 设置圆角弧度
        ),
        child: const AddShoppingItemPage(),
      ),
    ).then((newItem) {
      if (newItem != null) {
        print("New shopping item added: $newItem");
        // 刷新购物清单
        Provider.of<ShoppingListProvider>(context, listen: false).fetchItems();
      }
    });
  }

  // 页面切换函数
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCategorySelected(String category, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedCategories.add(category);
      } else {
        selectedCategories.remove(category);
      }
    });
    Provider.of<IngredientProvider>(context, listen: false).selectedCategories =
        selectedCategories;
  }

  final List<Widget> _pages = [
    MyFoodPage(),
    RecipePage(), // 替换为 RecipePage
    ShoppingListPage(),
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
      // body: IndexedStack(
      //   index: _selectedIndex,
      //   children: _pages,
      // ),
      body: Column(
        children: [
          if (_selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                children: categories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: selectedCategories.contains(category),
                    onSelected: (isSelected) =>
                        _onCategorySelected(category, isSelected),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),

      floatingActionButton: (_selectedIndex == 0 ||
              _selectedIndex == 2) // 在 MyFood 和 ShoppingList 页面时显示悬浮按钮
          ? FloatingActionButton(
              heroTag: "Add",
              onPressed: () {
                if (_selectedIndex == 0) {
                  _navigateToAddIngredient(); // MyFood 页面添加食材的行为
                } else if (_selectedIndex == 2) {
                  _navigateToAddShoppingItem(); // ShoppingList 页面添加物品的行为
                }
              },
              backgroundColor: buttonBackgroundColor,
              tooltip: 'Add Item',
              child: _selectedIndex == 2 // 在 ShoppingList 页面显示不同的图标
                  ? const Icon(Icons.shopping_cart_checkout_outlined,
                      color: whiteTextColor) // 购物清单页面显示购物车图标
                  : const Icon(Icons.add, color: whiteTextColor), // 其他页面显示添加图标
            )
          : null, // 在其他页面不显示悬浮按钮
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank_outlined),
            label: 'My Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_rounded),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shopping List', // 添加购物清单按钮
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: text, // 设置选中的项目颜色
        onTap: _onItemTapped,
        backgroundColor: buttonBackgroundColor,
        type: BottomNavigationBarType.fixed, // 确保使用固定样式，避免颜色问题
      ),
    );
  }
}

class MyFoodPage extends StatefulWidget {
  @override
  _MyFoodPageState createState() => _MyFoodPageState();
}

class _MyFoodPageState extends State<MyFoodPage> {
  List<String> selectedCategories = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final homePageState = context.findAncestorStateOfType<_MyHomePageState>();
    if (homePageState != null) {
      setState(() {
        selectedCategories = homePageState.selectedCategories;
      });
    }
  }

  Future<void> _deleteIngredient(
      BuildContext context, String userId, int ingredientId, int index) async {
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
        List<Ingredient> filteredIngredients = provider.ingredients;
        if (provider.selectedCategories.isNotEmpty) {
          filteredIngredients = provider.ingredients
              .where((ingredient) =>
                  provider.selectedCategories.contains(ingredient.category))
              .toList();
        }
        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                ),
                itemCount: filteredIngredients.length,
                itemBuilder: (context, index) {
                  final ingredient = filteredIngredients[index];
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
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (ingredient.imageURL.isNotEmpty)
                                  CircleAvatar(
                                    backgroundColor: greyBackgroundColor,
                                    backgroundImage:
                                        NetworkImage(ingredient.imageURL),
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
                                  style:
                                      const TextStyle(color: cardexpirestext),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Category: ${ingredient.category}',
                                  style:
                                      const TextStyle(color: cardexpirestext),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
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
                                      content: const Text(
                                          'Are you sure you want to delete this ingredient?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        TextButton(
                                          child: const Text('Delete'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmDelete) {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  String userId =
                                      prefs.getString('userId') ?? '';
                                  _deleteIngredient(context, userId,
                                      ingredient.ingredientId, index);
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
