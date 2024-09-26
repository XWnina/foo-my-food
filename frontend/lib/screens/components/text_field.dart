// text_field.dart
import 'package:flutter/material.dart';

// 通用的文本输入框构造方法
Widget buildTextInputField({
  required String label, // 输入框的标签
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.blue,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.blue,
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
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: isError ? Colors.red : Colors.grey, // 如果有错误，边框变红
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: isError ? Colors.red : Colors.blue, // 焦点状态下变红
            width: 2.0,
          ),
        ),
      ),
    ),
  );
}
