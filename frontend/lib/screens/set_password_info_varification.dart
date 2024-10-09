import 'package:flutter/material.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:foo_my_food_app/services/password_reset_api_service.dart'; // 引入 API 服务
import 'components/text_field.dart'; // 导入通用输入框函数
import 'set_password.dart'; // 引入密码重置页面

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  PasswordResetPageState createState() => PasswordResetPageState();
}

class PasswordResetPageState extends State<PasswordResetPage> {
  // 创建 TextEditingController
  final TextEditingController _emailController = TextEditingController();
  late bool _isPolling; // 轮询状态

  @override
  void initState() {
    super.initState();
    _isPolling = false;
  }

  // 发送重置密码请求
  Future<void> _sendResetLink() async {
    String email = _emailController.text;

    try {
      final response = await PasswordResetApiService.sendResetLink(emailAddress: email);

      if (response.statusCode == 200) {
        // 显示成功提示，并开始轮询状态
        _showDialog('Success', 'A verification link has been sent to your email.');
        _startPolling(email); // 开始轮询以检测邮件链接点击后的验证状态
      } else if (response.statusCode == 404) {
        // 用户不存在，显示错误提示
        _showDialog('Error', 'The email is not registered.');
      } else {
        // 显示其他错误提示
        _showDialog('Error', 'Failed to send reset link.');
      }
    } catch (error) {
      _showDialog('Error', 'Failed to send reset link. Please try again later.');
    }
  }

  // 开始轮询验证状态
  Future<void> _startPolling(String email) async {
    _isPolling = true;
    const duration = Duration(seconds: 5); // 每 5 秒轮询一次

    while (_isPolling) {
      await Future.delayed(duration);

      // 检查后端 API 是否验证成功
      final response = await PasswordResetApiService.checkVerificationStatus(emailAddress: email);

      if (response.statusCode == 200) {
        // 停止轮询，并跳转到密码重置页面
        _isPolling = false;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SetPasswordPage()),
        );
      } else if (response.statusCode == 400) {
        // 如果发生错误或未验证，继续轮询
        print("Verification still pending...");
      }
    }
  }

  // 显示对话框
  void _showDialog(String title, String message) {
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
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _isPolling = false; // 停止轮询
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Password Reset',
          style: TextStyle(color: whiteTextColor),
        ),
        backgroundColor: appBarColor,
      ),
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your email to reset your password',
              style: TextStyle(fontSize: 18, color: blackTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 邮箱输入框
            buildTextInputField(
              label: 'EMAIL',
              controller: _emailController,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendResetLink, // 调用发送请求的方法
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Send Verification',
                style: TextStyle(fontSize: 16, color: whiteTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
