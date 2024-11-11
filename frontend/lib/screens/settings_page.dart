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

  // 显示输入天数的对话框
  void _showDaysInputDialog() {
    final _daysController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Set Cooking Reminder Days"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Days",
                      errorText: errorText,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (int.tryParse(value) == null) {
                          errorText = "Please enter a valid integer.";
                        } else {
                          errorText = null;
                        }
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if (int.tryParse(_daysController.text) != null) {
                      int days = int.parse(_daysController.text);
                      await _saveTrackingDays(days); // 保存到 SharedPreferences
                      await _saveTrackingDaysToDatabase(days); // 保存到数据库
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        errorText = "Please enter a valid integer.";
                      });
                    }
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveTrackingDaysToDatabase(int days) async {
    final url =
        '$baseApiUrl/user/$userId/tracking-days'; // 请确保使用正确的 API 基础 URL 和 userId
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'trackingDays': days}),
    );
    if (response.statusCode == 200) {
      print("Tracking days saved to database: $days");
    } else {
      print("Failed to save tracking days to database: ${response.statusCode}");
    }
  }

  Future<void> _saveTrackingDays(int days) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('user_recipe_tracking_time', days);
    print("Tracking days saved: $days"); // 检查是否成功保存
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
              onPressed: _showDaysInputDialog, // 显示输入天数的对话框
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
