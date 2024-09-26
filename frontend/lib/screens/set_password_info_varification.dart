import 'package:flutter/material.dart';
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
          style: TextStyle(color: Colors.white), // 将标题颜色设置为白色
        ),
        backgroundColor: const Color(0xFF47709B),
      ),
      body: Container(
        color: const Color(0xFFD1E7FE), // 背景颜色与 LoginPage 一致
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your username and email to reset your password',
              style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 18, 32, 47)),
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
                backgroundColor: const Color(0xFF47709B), // 按钮颜色与之前一致
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Send Verification',
                style: TextStyle(fontSize: 16, color: Colors.white), // 按钮文本颜色改为白色
              ),
            ),
          ],
        ),
      ),
    );
  }
}
