import 'package:flutter/material.dart';

class AppTheme {
  final Color backgroundColor;
  final Color appBarColor;
  final Color buttonBackgroundColor;
  final Color textColor;
  final Color cardColor;
  final Color cardExpiresTextColor;
  final Color cardNameTextColor;

  AppTheme({
    required this.backgroundColor,
    required this.appBarColor,
    required this.buttonBackgroundColor,
    required this.textColor,
    required this.cardColor,
    required this.cardExpiresTextColor,
    required this.cardNameTextColor,
  });
}

class ThemeProvider extends ChangeNotifier {
  // 定义多个主题组
  static final AppTheme yellowGreenTheme = AppTheme(
    backgroundColor: Color(0xFFEEE7DA),
    appBarColor: Color(0xFF598F83),
    buttonBackgroundColor: Color(0xFF598F83),
    textColor: Color(0xFFe6f3ec),
    cardColor: Color.fromARGB(255, 255, 248, 235),
    cardExpiresTextColor: Color(0xFF598F83),
    cardNameTextColor: Color(0xFF265f60),
  );

  static final AppTheme blueTheme = AppTheme(
    backgroundColor: Color(0xFFDAE7FF),
    appBarColor: Color(0xFF4A83C5),
    buttonBackgroundColor: Color(0xFF4A83C5),
    textColor: Color(0xFFEFF6FF),
    cardColor: Color.fromARGB(255, 235, 248, 255),
    cardExpiresTextColor: Color(0xFF4A83C5),
    cardNameTextColor: Color(0xFF264A7D),
  );

  AppTheme _currentTheme = yellowGreenTheme;

  AppTheme get theme => _currentTheme;

  // 切换主题的方法
  void switchTheme(AppTheme newTheme) {
    _currentTheme = newTheme;
    notifyListeners();
  }
}
