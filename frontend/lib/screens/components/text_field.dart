import 'package:flutter/material.dart';
import 'package:foo_my_food_app/utils/colors.dart'; // 导入 color.dart 文件

// 通用的文本输入框构造方法
Widget buildTextInputField({
  required String label, // 输入框的标签
  required TextEditingController controller, // 控制输入框的 controller
  void Function(String)? onChanged, // 输入变化时的回调
  TextInputType keyboardType = TextInputType.text, // 输入框的类型，默认是文本输入
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller, // 传入的 controller
      onChanged: onChanged, // 输入变化时调用回调
      keyboardType: keyboardType, // 自定义输入类型
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: whiteFillColor, // 使用 color.dart 中的白色背景
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: blueBorderColor, // 使用 color.dart 中的蓝色边框
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: greyBorderColor, // 使用 color.dart 中的灰色边框
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: blueBorderColor, // 使用 color.dart 中的蓝色边框
            width: 2.0,
          ),
        ),
      ),
    ),
  );
}

// 通用的密码输入框构造方法，支持错误提示
Widget buildPasswordInputField({
  required String label, // 输入框的标签
  required TextEditingController controller, // 用于控制输入内容
  bool isError = false, // 错误状态标志，默认是 false
  void Function(String)? onChanged, // 输入内容变化时的回调
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      obscureText: true, // 隐藏密码
      onChanged: onChanged, // 当输入改变时调用回调
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: whiteFillColor, // 使用 color.dart 中的白色背景
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: isError ? redErrorBorderColor : greyBorderColor, // 错误时变红
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: isError ? redErrorBorderColor : blueBorderColor, // 焦点状态下变红
            width: 2.0,
          ),
        ),
      ),
    ),
  );
}
