import 'package:flutter/material.dart';
import '../utils/colors.dart';

class ThemeProvider extends ChangeNotifier {
  int _currentThemeIndex = 0;

  // 获取当前的主题方案
  AppTheme get theme => themes[_currentThemeIndex];

  // 切换主题
  void toggleTheme() {
    _currentThemeIndex = (_currentThemeIndex + 1) % themes.length;
    notifyListeners();
  }
}
