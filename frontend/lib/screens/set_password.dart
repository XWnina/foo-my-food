import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';  // 引入 JSON 序列化
import 'package:foo_my_food_app/utils/constants.dart';  // 引入 constants.dart 文件
import 'package:foo_my_food_app/utils/colors.dart';  // 引入 colors.dart 文件
import 'package:foo_my_food_app/screens/login_page.dart';  // 导入 login_page.dart 文件

class SetPasswordPage extends StatefulWidget {
  final String email;  // 接收传递的邮箱

  const SetPasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  _SetPasswordPageState createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _errorMessage = '';  // 用于显示错误信息

  Future<void> _resetPassword() async {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // 检查密码格式是否符合要求
    final passwordRegex = RegExp(passwordRegexPsttern);
    if (!passwordRegex.hasMatch(password)) {
      setState(() {
        _errorMessage = 'Password must be at least 5 characters long and contain a special character.';
      });
      return;
    }

    if (password == confirmPassword) {
      try {
        // 将密码数据序列化为 JSON
        final response = await http.post(
          Uri.parse(resetPasswordUrl),
          headers: {
            'Content-Type': 'application/json',  // 设置请求头为 JSON
          },
          body: jsonEncode({
            'newPassword': password,  // 传递的字段需与后端一致
            'email': widget.email,  // 使用从上一个页面传递过来的邮箱
          }),
        );

        if (response.statusCode == 200) {
          _showDialog('Success', 'Password has been reset successfully.', true);
        } else {
          _showDialog('Error', 'Failed to reset password.', false);
        }
      } catch (error) {
        _showDialog('Error', 'An error occurred: $error', false);
      }
    } else {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
    }
  }

  void _showDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  // 使用 Navigator.pushReplacement 跳转到 LoginPage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),  // 直接跳转到 LoginPage
                    ),
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password', style: TextStyle(color: whiteTextColor)),
        backgroundColor: appBarColor,  // 使用 colors.dart 中的 appBarColor
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your new password:',
              style: TextStyle(fontSize: 18, color: blackTextColor),  // 使用 colors.dart 中的黑色文字颜色
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: blackTextColor),  // 使用黑色文字颜色
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: blackTextColor),  // 黑色下划线
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: blackTextColor),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: blackTextColor),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,  // 使用按钮背景颜色
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Reset Password',
                style: TextStyle(fontSize: 16, color: whiteTextColor),  // 使用白色文字颜色
              ),
            ),
          ],
        ),
      ),
    );
  }
}
