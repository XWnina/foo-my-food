import 'package:flutter/material.dart';
import 'package:foo_my_food_app/screens/user_info_page.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:foo_my_food_app/providers/theme_provider.dart';
import 'package:foo_my_food_app/services/user_theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foo_my_food_app/screens/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // 从 SharedPreferences 中加载 userId
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId'); // 获取存储的 userId
    });

    if (userId != null) {
      _loadUserTheme();
    }
  }

  Future<void> _loadUserTheme() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    String userTheme = await UserThemeService.fetchUserTheme(userId!);

    // 根据 userTheme 设置主题
    switch (userTheme) {
      case "yellowGreenTheme":
        themeProvider.switchTheme(ThemeProvider.yellowGreenTheme);
        break;
      case "blueTheme":
        themeProvider.switchTheme(ThemeProvider.blueTheme);
        break;
      default:
        themeProvider.switchTheme(ThemeProvider.yellowGreenTheme); // 默认主题
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      _showError('User ID not found');
      return;
    }

    const url = '$baseApiUrl/logout';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        await prefs.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout successful'),
            duration: Duration(seconds: 1),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        });
      } else {
        _showError('Logout failed: ${response.body}');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: redErrorTextColor)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text('Settings',
            style: TextStyle(color: AppColors.textColor(context))),
        backgroundColor: AppColors.appBarColor(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: whiteTextColor),
            onPressed: () {
              _confirmLogout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UserProfile()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBackgroundColor(context),
              ),
              child: Text(
                'Set User Information',
                style: TextStyle(color: AppColors.textColor(context)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FoodExpiryReminderSettingsPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBackgroundColor(context),
              ),
              child: Text(
                'Set Food Expiry Reminder',
                style: TextStyle(color: AppColors.textColor(context)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CookingReminderSettingsPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBackgroundColor(context),
              ),
              child: Text(
                'Set Cooking Reminder',
                style: TextStyle(color: AppColors.textColor(context)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (userId != null) {
                  _showThemeDialog(context, themeProvider);
                } else {
                  print("User ID not available");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBackgroundColor(context),
              ),
              child: Text(
                'Set Theme Color',
                style: TextStyle(color: AppColors.textColor(context)),
              ),
            ),
            SizedBox(height: 20),
            // 新增的文字登出按钮
            TextButton(
              onPressed: _confirmLogout,
              child: Text(
                "Logout",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示登出确认对话框
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Logout"),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  // 显示主题选择对话框
  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Theme Color"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Yellow Green Theme"),
                onTap: () async {
                  themeProvider.switchTheme(ThemeProvider.yellowGreenTheme);
                  if (userId != null) {
                    await UserThemeService.updateUserTheme(
                        userId!, "yellowGreenTheme");
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("Blue Theme"),
                onTap: () async {
                  themeProvider.switchTheme(ThemeProvider.blueTheme);
                  if (userId != null) {
                    await UserThemeService.updateUserTheme(
                        userId!, "blueTheme");
                  }
                  Navigator.of(context).pop();
                },
              ),
              // 可以在此处添加更多主题选项
            ],
          ),
        );
      },
    );
  }
}

class FoodExpiryReminderSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text('Food Expiry Reminder Settings'),
        backgroundColor: AppColors.appBarColor(context),
      ),
      body: Center(
        child: Text(
          'Food Expiry Reminder Settings Page',
          style: TextStyle(color: AppColors.textColor(context)),
        ),
      ),
    );
  }
}

class CookingReminderSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text('Cooking Reminder Settings'),
        backgroundColor: AppColors.appBarColor(context),
      ),
      body: Center(
        child: Text(
          'Cooking Reminder Settings Page',
          style: TextStyle(color: AppColors.textColor(context)),
        ),
      ),
    );
  }
}
