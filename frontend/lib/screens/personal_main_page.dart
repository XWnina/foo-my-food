import 'package:flutter/material.dart';
import 'package:foo_my_food_app/screens/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:foo_my_food_app/providers/theme_provider.dart';
import 'package:foo_my_food_app/screens/user_info_page.dart'; // 确保路径正确

class UserMainPage extends StatefulWidget {
  @override
  _UserMainPageState createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  String? _username = 'Username'; // 临时用户名
  String? _avatarUrl;

  @override
  Widget build(BuildContext context) {
    // 获取当前的 ThemeProvider 实例
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Main Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: themeProvider.theme.appBarColor, // 使用动态主题色
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
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 250,
                color: themeProvider.theme.appBarColor, // 使用动态主题色
              ),
              Positioned(
                bottom: 0,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                      child: _avatarUrl == null
                          ? Icon(Icons.person, size: 50, color: Colors.grey.shade700)
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
            ],
          ),
          const SizedBox(height: 20),
          // 仅显示 "Collections" 标签
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Center(
              child: Text("Collections", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
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
                return Container(
                  color: themeProvider.theme.backgroundColor, // 动态背景色
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Collection $index",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
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
