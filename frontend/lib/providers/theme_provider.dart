import 'package:flutter/material.dart';

class AppTheme {
  final Color backgroundColor;
  final Color appBarColor;
  final Color buttonBackgroundColor;
  final Color textColor;
  final Color cardColor;
  final Color cardExpiresTextColor;
  final Color cardNameTextColor;
  final Color lablebackground;

  AppTheme(
      {required this.backgroundColor,
      required this.appBarColor,
      required this.buttonBackgroundColor,
      required this.textColor,
      required this.cardColor,
      required this.cardExpiresTextColor,
      required this.cardNameTextColor,
      required this.lablebackground});
}

class ThemeProvider extends ChangeNotifier {
  // 定义多个主题组
  static final AppTheme yellowGreenTheme = AppTheme(
    backgroundColor: const Color(0xFFEEE7DA),
    appBarColor: const Color(0xFF598F83),
    buttonBackgroundColor: const Color(0xFF598F83),
    textColor: const Color(0xFFe6f3ec),
    cardColor: const Color.fromARGB(255, 255, 248, 235),
    cardExpiresTextColor: const Color(0xFF598F83),
    cardNameTextColor: const Color(0xFF265f60),
    lablebackground: const Color.fromARGB(255, 244, 244, 177),
  );

  static final AppTheme blueTheme = AppTheme(
      backgroundColor: const Color(0xFFDAE7FF),
      appBarColor: const Color(0xFF4A83C5),
      buttonBackgroundColor: const Color(0xFF4A83C5),
      textColor: const Color(0xFFEFF6FF),
      cardColor: const Color.fromARGB(255, 235, 248, 255),
      cardExpiresTextColor: const Color(0xFF4A83C5),
      cardNameTextColor: const Color(0xFF264A7D),
      lablebackground: const Color.fromARGB(255, 213, 243, 197));
  static final AppTheme pinkTheme = AppTheme(
    backgroundColor: const Color(0xFFFFE6E6),
    appBarColor: const Color(0xFFD46A6A),
    buttonBackgroundColor: const Color(0xFFD46A6A),
    textColor: const Color(0xFFFFF1F1),
    cardColor: const Color.fromARGB(255, 255, 230, 235),
    cardExpiresTextColor: const Color(0xFFD46A6A),
    cardNameTextColor: const Color(0xFFAD4D4D),
    lablebackground: const Color.fromARGB(255, 255, 209, 220),
  );

  AppTheme _currentTheme = yellowGreenTheme;

  AppTheme get theme => _currentTheme;

  // 切换主题的方法
  void switchTheme(AppTheme newTheme) {
    _currentTheme = newTheme;
    notifyListeners();
  }
}
