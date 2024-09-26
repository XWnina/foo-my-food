import 'package:flutter/material.dart';
import 'package:foo_my_food_app/utils/colors.dart';// 导入 color.dart 文件
import 'components/text_field.dart'; // 导入你自定义的 text_field.dart 文件

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Change Password Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appBarColor), // 使用 color.dart 中的颜色
        useMaterial3: true,
      ),
      home: const ChangePasswordPage(),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _changePassword() {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password == confirmPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Password changed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Passwords do not match. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(color: whiteTextColor), // 使用 color.dart 中的白色文字颜色
        ),
        backgroundColor: appBarColor, // 使用 color.dart 中的 AppBar 背景颜色
      ),
      body: Container(
        color: backgroundColor, // 使用 color.dart 中的背景颜色
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your new password twice to confirm the change',
              style: TextStyle(fontSize: 18, color: blackTextColor), // 使用 color.dart 中的深蓝色文字颜色
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // 使用 buildPasswordInputField 替代原先的 TextField
            buildPasswordInputField(
              label: 'New Password',
              controller: _passwordController,
            ),
            const SizedBox(height: 20),
            buildPasswordInputField(
              label: 'Confirm New Password',
              controller: _confirmPasswordController,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor, // 使用 color.dart 中的按钮背景颜色
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Change Password',
                style: TextStyle(fontSize: 16, color: whiteTextColor), // 使用 color.dart 中的白色文字颜色
              ),
            ),
          ],
        ),
      ),
    );
  }
}
