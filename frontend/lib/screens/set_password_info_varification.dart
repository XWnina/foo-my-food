import 'package:flutter/material.dart';
import 'package:foo_my_food_app/utils/colors.dart';// 导入 color.dart 文件
import 'components/text_field.dart'; // 导入通用输入框函数

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foo my food Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 30, 108, 168)),
        useMaterial3: true,
      ),
      home: const PasswordResetPage(),
    );
  }
}

class PasswordResetPage extends StatelessWidget {
  const PasswordResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Password Reset',
          style: TextStyle(color: whiteTextColor), // 使用 color.dart 中的白色文字颜色
        ),
        backgroundColor: appBarColor, // 使用 color.dart 中的 AppBar 颜色
      ),
      body: Container(
        color: backgroundColor, // 使用 color.dart 中的背景颜色
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your username and email to reset your password',
              style: TextStyle(fontSize: 18, color: blackTextColor), // 使用 color.dart 中的黑色文字颜色
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 使用通用的 buildTextInputField 替代
            buildTextInputField(label: 'USERNAME'),
            const SizedBox(height: 20),

            // 使用通用的 buildTextInputField 替代
            buildTextInputField(label: 'EMAIL'),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your verification logic here
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Verification'),
                      content: const Text('A verification link has been sent to your email. Reset your password in your email.'),
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor, // 使用 color.dart 中的按钮背景颜色
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Send Verification',
                style: TextStyle(fontSize: 16, color: whiteTextColor), // 使用 color.dart 中的白色文字颜色
              ),
            ),
          ],
        ),
      ),
    );
  }
}
