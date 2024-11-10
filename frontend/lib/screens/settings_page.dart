import 'package:flutter/material.dart';
import 'package:foo_my_food_app/screens/user_info_page.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:foo_my_food_app/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 获取当前的 ThemeProvider 实例
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor, // 使用页面背景颜色
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: appBarColor, // 使用AppBar背景颜色
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor, // 按钮背景颜色
              ),
              child: Text('Set User Information', style: TextStyle(color: whiteTextColor)), // 白色字体
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FoodExpiryReminderSettingsPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
              ),
              child: Text('Set Food Expiry Reminder', style: TextStyle(color: whiteTextColor)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CookingReminderSettingsPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
              ),
              child: Text('Set Cooking Reminder', style: TextStyle(color: whiteTextColor)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                themeProvider.toggleTheme(); // 切换主题颜色
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.theme.buttonBackgroundColor,
              ),
              child: Text('Set Theme Color', style: TextStyle(color: whiteTextColor)),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodExpiryReminderSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greyBackgroundColor,
      appBar: AppBar(
        title: Text('Food Expiry Reminder Settings'),
        backgroundColor: appBarColor,
      ),
      body: Center(
        child: Text('Food Expiry Reminder Settings Page', style: TextStyle(color: blackTextColor)),
      ),
    );
  }
}

class CookingReminderSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greyBackgroundColor,
      appBar: AppBar(
        title: Text('Cooking Reminder Settings'),
        backgroundColor: appBarColor,
      ),
      body: Center(
        child: Text('Cooking Reminder Settings Page', style: TextStyle(color: blackTextColor)),
      ),
    );
  }
}
