import 'package:flutter/material.dart';
import 'package:foo_my_food_app/screens/user_info_page.dart'; // 修改路径确保正确
import 'package:foo_my_food_app/utils/colors.dart';

class UserMainPage extends StatefulWidget {
  @override
  _UserMainPageState createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  String? _username = 'Username'; // 临时用户名，可替换为实际数据
  String? _avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'User Main Page',
          style: TextStyle(color: text),
        ),
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // 跳转到 UserProfile 页面
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfile()),
              );
            },
            tooltip: 'Edit Profile',
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
                color: appBarColor,
              ),
              Positioned(
                bottom: 0,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundColor: greyBackgroundColor,
                      backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                      child: _avatarUrl == null
                          ? Icon(Icons.person, size: 50, color: greyIconColor)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _username ?? 'Loading...',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: blackTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // 设置主题颜色功能
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: appBarColor,
                        backgroundColor: backgroundColor,
                      ),
                      child: const Text("Set Theme Color"),
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
                  color: card,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Collection $index",
                          style: TextStyle(color: cardnametext),
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
