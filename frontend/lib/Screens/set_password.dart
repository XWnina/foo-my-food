import 'package:flutter/material.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 30, 108, 168)),
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
          style: TextStyle(color: Colors.white), // 标题文字改为白色
        ),
        backgroundColor: const Color.fromARGB(255, 30, 108, 168),
      ),
      body: Container(
        color: const Color(0xFFD1E7FE), // 与登录页保持一致的背景颜色
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your new password twice to confirm the change',
              style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 18, 32, 47)), // 文本颜色改为深蓝色
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
                backgroundColor: const Color.fromARGB(255, 30, 108, 168), // 按钮颜色改为深蓝色
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Change Password',
                style: TextStyle(fontSize: 16, color: Colors.white), // 按钮文字颜色改为白色
              ),
            ),
          ],
        ),
      ),
    );
  }
}
