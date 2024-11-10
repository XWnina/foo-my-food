import 'package:flutter/material.dart';

const backgroundColor = Color(0xFFEEE7DA); // 页面背景颜色
const appBarColor = Color(0xFF598F83); // AppBar 背景颜色
const buttonBackgroundColor = Color(0xFF598F83); // 按钮背景颜色
const blackTextColor = Colors.black; // 黑色字体颜色
const whiteTextColor = Colors.white; // 白色字体颜色
const redErrorTextColor = Colors.red; // 错误提示的红色文字
final greyBackgroundColor = Colors.grey.shade300; // 灰色背景（头像的默认背景）
const text = Color(0xFFe6f3ec);
const card = Color.fromARGB(255, 255, 248, 235);
const cardexpirestext = Color(0xFF598F83);
const cardnametext = Color(0xFF265f60);
final greyIconColor = Colors.grey.shade700; // 灰色图标颜色（上传图标）
const lablebackground = Color.fromARGB(255, 244, 244, 177);

const whiteFillColor = Colors.white; // 输入框填充背景色
const blueBorderColor = Colors.blue; // 蓝色边框颜色
const greyBorderColor = Colors.grey; // 灰色边框颜色
const redErrorBorderColor = Colors.red;  // 错误提示的红色边框颜色

class AppTheme {
  final Color backgroundColor;
  final Color appBarColor;
  final Color buttonBackgroundColor;

  AppTheme({
    required this.backgroundColor,
    required this.appBarColor,
    required this.buttonBackgroundColor,
  });
}
// 定义多个主题方案
final List<AppTheme> themes = [
  AppTheme(
    backgroundColor: Color(0xFFEEE7DA),
    appBarColor: Color(0xFF598F83),
    buttonBackgroundColor: Color(0xFF598F83),
  ),
  AppTheme(
    backgroundColor: Color(0xFFF5E1E1),
    appBarColor: Color(0xFFD32F2F),
    buttonBackgroundColor: Color(0xFFD32F2F),
  ),
  AppTheme(
    backgroundColor: Color(0xFFE7F5DA),
    appBarColor: Color(0xFF388E3C),
    buttonBackgroundColor: Color(0xFF388E3C),
  ),
  // 可以继续添加更多的颜色方案
];

