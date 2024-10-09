import 'package:flutter/material.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:foo_my_food_app/services/password_reset_api_service.dart';
import 'components/text_field.dart';
import 'set_password.dart';
import 'package:foo_my_food_app/utils/constants.dart';  // 引入 constants.dart 文件
import 'package:foo_my_food_app/utils/helper_function.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  PasswordResetPageState createState() => PasswordResetPageState();
}

class PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController(); // 新增用户名输入框
  late bool _isPolling;

  @override
  void initState() {
    super.initState();
    _isPolling = false;
  }

  // 发送重置链接到用户邮箱并验证用户名
  Future<void> _sendResetLink() async {
    String email = _emailController.text;
    String username = _usernameController.text;

    // 检查邮箱格式
    if (!HelperFunctions.checkEmailFormat(email)) {
      _showDialog('Error', 'Invalid email format.');
      return;
    }

    // 调用后端 API 验证用户名和邮箱
    try {
      final response = await PasswordResetApiService.sendResetLink(
        emailAddress: email,
        userName: username,  // 传递用户名到 API
      );

      if (response.statusCode == 200) {
        _showDialog('Success', 'A verification link has been sent to your email.');
        _startPolling(email); // 开始轮询检测邮箱验证状态
      } else if (response.statusCode == 404) {
        _showDialog('Error', 'The email or username is not registered.');
      } else if (response.statusCode == 409) {
        _showSnackBar('Username and email do not match.'); // 弹出用户名和邮箱不匹配的提示
      } else {
        _showDialog('Error', 'Failed to send reset link.');
      }
    } catch (error) {
      _showDialog('Error', 'Failed to send reset link. Please try again later.');
    }
  }

  // 显示 SnackBar
  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // 轮询以检测用户是否点击了验证链接
  Future<void> _startPolling(String email) async {
    _isPolling = true;
    const duration = Duration(seconds: 5); // 每 5 秒轮询一次

    while (_isPolling) {
      await Future.delayed(duration);

      final response = await PasswordResetApiService.checkVerificationStatus(emailAddress: email);

      if (response.statusCode == 200) {
        // 验证成功，跳转到重置密码页面，并传递邮箱
        _isPolling = false;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetPasswordPage(email: email),  // 传递邮箱到 SetPasswordPage
          ),
        );
      } else {
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
    _isPolling = false;
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
              'Enter your email and username to reset your password',
              style: TextStyle(fontSize: 18, color: blackTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // 用户名输入框
            buildTextInputField(
              label: 'USERNAME',
              controller: _usernameController,
            ),
            const SizedBox(height: 20),
            // 邮箱输入框
            buildTextInputField(
              label: 'EMAIL',
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            // 发送重置链接按钮
            ElevatedButton(
              onPressed: _sendResetLink, // 点击按钮发送重置链接
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
