import 'package:flutter/material.dart';
import 'user_info_page.dart';
import 'add_ingredient_manually.dart';
import 'ingredient_detail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.userId}); // 更新构造函数

  final String title;
  final String userId; // 添加 userId 字段

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<UserIngredient> foodItems = [];

  @override
  void initState() {
    super.initState();
    _fetchUserIngredients(); // Fetch ingredients on initialization
  }

  Future<void> _fetchUserIngredients() async {
    final response = await http.get(Uri.parse('http://your-api-url/api/user-ingredients/${widget.userId}')); // 使用传入的 userId

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        foodItems = data.map((item) => UserIngredient.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load ingredients');
    }
  }

  void _navigateToAddIngredient() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddIngredientPage()),
    ).then((_) {
      _fetchUserIngredients(); // Refresh the list after adding an ingredient
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Food name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
              ),
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(item.imageUrl),
                    ),
                    title: Text(item.name),
                    subtitle: Text('Expires: ${item.expirationDate.split(' ')[0]}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodItemDetailPage(
                            ingredient: item, // 传递整个 UserIngredient 对象
                          ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_rounded),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_rounded),
            label: 'My Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Model class for UserIngredient
class UserIngredient {
  final String name;
  final String imageUrl;
  final String expirationDate;
  final Map<String, String> nutritionInfo; // 修改为 Map 类型
  final String category;
  final String storageMethod;
  final int quantity;

  UserIngredient({
    required this.name,
    required this.imageUrl,
    required this.expirationDate,
    required this.nutritionInfo,
    required this.category,
    required this.storageMethod,
    required this.quantity,
  });

  factory UserIngredient.fromJson(Map<String, dynamic> json) {
    return UserIngredient(
      name: json['name'],
      imageUrl: json['imageUrl'],
      expirationDate: json['expirationDate'],
      nutritionInfo: Map<String, String>.from(json['nutritionInfo']),
      category: json['category'],
      storageMethod: json['storageMethod'],
      quantity: json['quantity'],
    );
  }
}