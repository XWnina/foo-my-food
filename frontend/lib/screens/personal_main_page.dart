import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foo_my_food_app/screens/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:foo_my_food_app/providers/theme_provider.dart';
import 'package:foo_my_food_app/screens/user_info_page.dart'; // 确保路径正确
import 'package:foo_my_food_app/utils/colors.dart'; // 导入 AppColors
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:foo_my_food_app/utils/constants.dart';

class UserMainPage extends StatefulWidget {
  @override
  _UserMainPageState createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  String? _username = 'Username'; // 临时用户名
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 页面加载时调用
  }

  // 从后端加载用户数据
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID not found. Please log in again.')),
      );
      return;
    }

    final url = '$baseApiUrl/user/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        if (userData.isNotEmpty) {
          setState(() {
            _username = userData["userName"] ?? 'Unknown User';
            _avatarUrl = userData["imageURL"];
          });
        } else {
          throw Exception('User data is empty.');
        }
      } else {
        throw Exception(
            'Failed to retrieve user data, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Main Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.appBarColor(context), // 使用 AppColors 获取动态主题色
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
            tooltip: 'Setting',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.25,
            color: AppColors.appBarColor(context), // 使用 AppColors 获取动态主题色
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                  child: _avatarUrl == null
                      ? Icon(Icons.person,
                          size: 50, color: Colors.grey.shade700)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  _username ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // 将 "Collections" 标签上移，靠近头像区域
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Center(
              child: Text("Collections",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
          const SizedBox(height: 10), // 添加间距
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 6, // Example count, replace with your data
              itemBuilder: (context, index) {
                return Card(
                  color: AppColors.cardColor(
                      context), // 使用 AppColors 获取动态背景色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Collection $index",
                        style: TextStyle(
                          color: AppColors.cardNameTextColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
