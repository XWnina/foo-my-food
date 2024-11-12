import 'package:flutter/material.dart';
import 'package:foo_my_food_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

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
const redErrorBorderColor = Colors.red; // 错误提示的红色边框颜色

class AppColors {
  // 动态获取背景颜色
  static Color backgroundColor(BuildContext context) =>
      Provider.of<ThemeProvider>(context).theme.backgroundColor;

  // 动态获取 AppBar 背景颜色
  static Color appBarColor(BuildContext context) =>
      Provider.of<ThemeProvider>(context).theme.appBarColor;

  // 动态获取按钮背景颜色
  static Color buttonBackgroundColor(BuildContext context) =>
      Provider.of<ThemeProvider>(context).theme.buttonBackgroundColor;

  // 动态获取文本颜色
  static Color textColor(BuildContext context) =>
      Provider.of<ThemeProvider>(context).theme.textColor;

  // 动态获取卡片颜色
  static Color cardColor(BuildContext context) =>
      Provider.of<ThemeProvider>(context).theme.cardColor;

  // 动态获取卡片过期文本颜色
  static Color cardExpiresTextColor(BuildContext context) =>
      Provider.of<ThemeProvider>(context).theme.cardExpiresTextColor;

  // 动态获取卡片名称文本颜色
  static Color cardNameTextColor(BuildContext context) =>
      Provider.of<ThemeProvider>(context).theme.cardNameTextColor;

  static Color lablebackground(BuildContext context) =>
      Provider.of<ThemeProvider>(context).theme.lablebackground;
}
