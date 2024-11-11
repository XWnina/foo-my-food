import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foo_my_food_app/providers/theme_provider.dart';
import 'package:foo_my_food_app/screens/components/text_field.dart'; // 导入 text_field.dart
import 'package:foo_my_food_app/services/user_theme_service.dart';
import 'package:foo_my_food_app/utils/colors.dart'; // 导入 color.dart 文件
import 'package:foo_my_food_app/services/login_service.dart'; // 导入 login_service.dart
import 'package:foo_my_food_app/services/account_api_service.dart'; // 导入 account_api_service.dart
import 'package:foo_my_food_app/utils/constants.dart'; // 导入 constants.dart 文件
import 'package:provider/provider.dart';
import 'homepage.dart'; // 导入主页
import 'create_account_page.dart'; // 导入创建账户页面
import 'security_or_email.dart'; // 导入密码重置页面
import 'package:foo_my_food_app/Screens/choose_security_q.dart'; // 导入 Security Question 页面
import 'package:shared_preferences/shared_preferences.dart'; // 导入 SharedPreferences
import 'package:logging/logging.dart';

final Logger _logger = Logger('LoginPage');

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _emailNotVerified = false; // 是否邮箱未验证
  bool _isEmailVerificationSent = false; // 是否已经发送验证邮件
  bool _isProcessing = false; // 防止重复提交标记
  String errorMessage = '';

  final LoginService loginService = LoginService(); // 实例化 LoginService

  Future<void> login() async {
    if (_isProcessing) return; // 防止重复点击
    _isProcessing = true;

    String userInput = _emailController.text;
    String password = _passwordController.text;

    try {
      // 调用登录 API
      final response = await loginService.login(userInput, password);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        String userId = jsonResponse['userId']; // 从响应中获取 userId

        // 保存 userId 到 SharedPreferences
        await saveUserId(userId);

        // 获取用户的主题并应用到 ThemeProvider
        String? userTheme = await UserThemeService.fetchUserTheme(userId);
        if (userTheme != null) {
          final themeProvider =
              Provider.of<ThemeProvider>(context, listen: false);
          switch (userTheme) {
            case "yellowGreenTheme":
              themeProvider.switchTheme(ThemeProvider.yellowGreenTheme);
              break;
            case "blueTheme":
              themeProvider.switchTheme(ThemeProvider.blueTheme);
              break;
            default:
              themeProvider
                  .switchTheme(ThemeProvider.yellowGreenTheme); // 设置默认主题
          }
        }

        if (!mounted) return;

        // 成功登录后跳转到主页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'My Food'),
          ),
        );
      } else if (response.statusCode == 403) {
        // 邮箱未验证，显示重新发送验证邮件的提示
        setState(() {
          _emailNotVerified = true;
          _isEmailVerificationSent = true;
          errorMessage =
              "Email not verified. Please check your inbox for the verification email.";
        });
      } else if (response.statusCode == 404) {
        // 用户名或邮箱未找到
        setState(() {
          errorMessage = jsonDecode(response.body)['message'];
        });
      } else if (response.statusCode == 401) {
        // 密码错误
        setState(() {
          errorMessage = jsonDecode(response.body)['message'];
        });
      } else {
        setState(() {
          errorMessage = 'An unexpected error occurred.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error occurred during login: $e";
      });
    } finally {
      _isProcessing = false; // 重置防抖状态
    }
  }

  // 保存 userId 到 SharedPreferences
  Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    print('保存的 userId: $userId');
  }

  // 检查邮箱验证状态
  Future<void> checkVerificationStatus() async {
    if (_isProcessing) return; // 防止重复点击
    _isProcessing = true;

    String userInput = _emailController.text;
    String password = _passwordController.text;

    try {
      // 调用登录 API
      final response = await loginService.login(userInput, password);

      if (response.statusCode == 200) {
        if (!mounted) return;

        // 成功登录后跳转到安全问题选择页面
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SecurityQuestionSelectionPage(email: _emailController.text)),
        );
      } else if (response.statusCode == 403) {
        // 邮箱未验证，显示重新发送验证邮件的提示
        setState(() {
          _emailNotVerified = true;
          _isEmailVerificationSent = true;
          errorMessage =
              "Email not verified. Please check your inbox for the verification email.";
        });
      } else if (response.statusCode == 404) {
        // 用户名或邮箱未找到
        setState(() {
          errorMessage = jsonDecode(response.body)['message'];
        });
      } else if (response.statusCode == 401) {
        // 密码错误
        setState(() {
          errorMessage = jsonDecode(response.body)['message'];
        });
      } else {
        setState(() {
          errorMessage = 'An unexpected error occurred.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error occurred during login: $e";
      });
    } finally {
      _isProcessing = false; // 重置防抖状态
    }
  }

  // 错误提示展示
  Widget buildErrorMessage() {
    if (errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    return const SizedBox(); // 如果没有错误，返回一个空的占位
  }

  // 清除错误状态
  void clearErrorState() {
    setState(() {
      errorMessage = '';
      _emailNotVerified = false;
      _isEmailVerificationSent = false;
    });
  }

  static const underlineStyle = TextStyle(
    decoration: TextDecoration.underline, // 添加下划线样式
    color: buttonBackgroundColor, // 设置文字颜色
    fontSize: 13,
  );

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag, // 拖动时隐藏键盘
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.05), // 留出顶部空间避免被键盘遮挡
                // Logo 区域
                Container(
                  width: screenWidth * 0.8,
                  height: screenWidth * 0.8,
                  decoration: const BoxDecoration(
                    color: Colors.transparent, // 将背景色设置为透明
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.0),
                    child: Image.asset(
                      "image/logo1.png",
                      fit: BoxFit.cover, // 确保图片填充整个容器
                    ),
                  ),
                ),

                const SizedBox(height: 20), // 间距
                // App 名字
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '-',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF265F60), // 其余部分的颜色
                        ),
                      ),
                      TextSpan(
                        text: 'FOO',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF598F83), // FOO 部分的颜色
                        ),
                      ),
                      TextSpan(
                        text: ' MY FOOD-',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF265F60), // 其余部分的颜色
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20), // 间距

                // 用户名或邮箱输入框
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * inputFieldWidthFactor),
                  child: buildTextInputField(
                    label: 'Email Or Username',
                    controller: _emailController,
                    isError: _emailNotVerified,
                    onChanged: (text) => clearErrorState(),
                  ),
                ),

                // 错误提示
                buildErrorMessage(),

                const SizedBox(height: 20), // 间距

                // 密码输入框
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * inputFieldWidthFactor),
                  child: buildPasswordInputField(
                    label: 'Password',
                    controller: _passwordController,
                    onChanged: (text) => clearErrorState(),
                  ),
                ),

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

                const SizedBox(height: 20), // 间距

                // 忘记密码和创建账户放在同一行
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * inputFieldWidthFactor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 左右对齐
                    children: [
                      // 忘记密码
                      TextButton(
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
                            color: buttonBackgroundColor, // 设置文字颜色
                            fontSize: 13,
                          ),
                        ),
                      ),
                      // 创建账户
                      TextButton(
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
                            color: buttonBackgroundColor, // 设置文字颜色
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
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
