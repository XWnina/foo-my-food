import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foo_my_food_app/screens/components/text_field.dart'; // 导入 text_field.dart
import 'package:foo_my_food_app/utils/colors.dart'; // 导入 color.dart 文件
import 'package:foo_my_food_app/services/login_service.dart'; // 导入 login_service.dart 文件
import 'package:foo_my_food_app/utils/constants.dart'; // 导入 constants.dart 文件
import 'homepage.dart'; // 导入主页
import 'create_account_page.dart'; // 导入创建账户页面
import 'security_or_email.dart'; // 导入密码重置页面
import 'package:logging/logging.dart';

final Logger _logger = Logger('LoginPage');

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _emailInvalid = false; // 是否为无效的邮箱
  bool _usernameNotFound = false; // 是否未找到用户名
  bool _passwordInvalid = false; // 是否为无效的密码
  bool _emailNotVerified = false; // 是否邮箱未验证
  String errorMessage = '';

  final LoginService loginService = LoginService(); // 实例化 LoginService

  Future<void> login() async {
    String userInput = usernameController.text;
    String password = passwordController.text;

    try {
      final response = await loginService.login(userInput, password);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (!mounted) return;

        // 成功登录后跳转到主页
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MyHomePage(title: 'Home Page')),
        );
      } else if (response.statusCode == 404) {
        // 判断是邮箱错误还是用户名错误
        String errorMessage = jsonDecode(response.body)['message'];
        setState(() {
          if (errorMessage.contains("Email")) {
            _emailInvalid = true;
            _usernameNotFound = false;
          } else if (errorMessage.contains("Username")) {
            _usernameNotFound = true;
            _emailInvalid = false;
          }
          _passwordInvalid = false; // 清除密码错误状态
        });
      } else if (response.statusCode == 401) {
        // 密码错误
        setState(() {
          _passwordInvalid = true;
          _emailInvalid = false;
          _usernameNotFound = false;
        });
      } else if (response.statusCode == 403) {
        // 邮箱未验证
        setState(() {
          _emailNotVerified = true; // 设置邮箱未验证的状态
          errorMessage =
              "Email is not verified. Please verify your email to log in.";
        });
      } else {
        setState(() {
          errorMessage = "An unexpected error occurred";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error occurred during login: $e";
      });
      _logger.severe("Error occurred during login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          // 允许页面滚动
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.1), // 留出顶部空间避免被键盘遮挡
                // Logo 区域
                Container(
                  width: screenWidth * 0.6,
                  height: screenWidth * 0.6,
                  decoration: BoxDecoration(
                    color: whiteFillColor,
                    border: Border.all(width: 1, color: greyBorderColor),
                  ),
                  child: Image.asset(
                    "image/logo3.png",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20), // 间距
                // App 名字
                Text(
                  '-FOO MY FOOD-',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20), // 间距

                // 用户名或邮箱输入框
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * inputFieldWidthFactor),
                  child: buildTextInputField(
                    label: 'Email Or Username',
                    controller: usernameController,
                    isError: _emailInvalid ||
                        _usernameNotFound ||
                        _emailNotVerified, // 根据错误状态设置边框颜色
                    onChanged: (text) {
                      setState(() {
                        _emailInvalid = false;
                        _usernameNotFound = false;
                        _emailNotVerified = false; // 清除未验证状态
                      });
                    },
                  ),
                ),
                if (_emailInvalid)
                  const Text(emailInvalidError,
                      style: TextStyle(color: redErrorTextColor)),
                if (_usernameNotFound)
                  const Text(usernameNotRegisteredError,
                      style: TextStyle(color: redErrorTextColor)),
                if (_emailNotVerified)
                  const Text(
                      "Email is not verified. Please verify your email to log in.",
                      style: TextStyle(color: redErrorTextColor)),

                const SizedBox(height: 20), // 间距

                // 密码输入框
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * inputFieldWidthFactor),
                  child: buildPasswordInputField(
                    label: 'Password',
                    controller: passwordController,
                    isError: _passwordInvalid,
                    onChanged: (text) {
                      setState(() {
                        _passwordInvalid = false;
                      });
                    },
                  ),
                ),
                if (_passwordInvalid)
                  const Text(passwordIncorrectError,
                      style: TextStyle(color: redErrorTextColor)),

                const SizedBox(height: 20), // 间距

                // 登录按钮
                SizedBox(
                  width: screenWidth * buttonWidthFactor,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: login, // 点击按钮调用登录函数
                    child: const Text(
                      loginButtonText, // 从 constants.dart 引用按钮文本
                      style: TextStyle(
                        color: whiteTextColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10), // 间距

                // 忘记密码按钮
                SizedBox(
                  width: screenWidth * buttonWidthFactor,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PasswordResetChoicePage()),
                      );
                    },
                    child: const Text(
                      forgetResetPasswordText, // 从 constants.dart 引用按钮文本
                      style: TextStyle(
                        color: whiteTextColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10), // 间距

                // 创建账户按钮
                SizedBox(
                  width: screenWidth * buttonWidthFactor,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateAccount()),
                      );
                    },
                    child: const Text(
                      createAccountButtonText, // 从 constants.dart 引用按钮文本
                      style: TextStyle(
                        color: whiteTextColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // 保证内容不会被键盘完全遮挡
              ],
            ),
          ),
        ),
      ),
    );
  }
}
