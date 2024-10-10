import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foo_my_food_app/screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_ingredient_manually.dart';
import 'ingredient_detail.dart';
import 'user_info_page.dart';
import 'package:http/http.dart' as http;
import 'package:foo_my_food_app/utils/constants.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<UserIngredient> foodItems = [];
  String userId = ''; // 添加 userId 字段

  @override
  void initState() {
    super.initState();
    _loadUserId(); // 加载 userId
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUserId = prefs.getString('userId'); // 读取 userId

    if (savedUserId != null) {
      setState(() {
        userId = savedUserId; // 将 userId 存储在状态中
      });
      _fetchUserIngredients(); // 获取食材
    } else {
      // 处理未找到 userId 的情况，如重定向到登录页面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _fetchUserIngredients() async {
    final response = await http.get(Uri.parse('$baseApiUrl/user_ingredients/$userId')); // 使用 userId 获取食材

    if (response.statusCode == 200) { 
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        foodItems = data.map((item) => UserIngredient.fromJson(item)).toList();
      });
    } else {
      // 处理错误情况
      throw Exception('Failed to load ingredients');
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
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for food',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
          ),
          // 食材列表
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
                    leading: CircleAvatar(backgroundImage: NetworkImage(item.imageUrl)),
                    title: Text(item.name),
                    subtitle: Text('Expires: ${item.expirationDate.split(' ')[0]}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodItemDetailPage(
                           ingredient: item, userId: userId
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

// 食材模型类
class UserIngredient {
  final String name;
  final String imageUrl;
  final String expirationDate;
  final Map<String, String> nutritionInfo;
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