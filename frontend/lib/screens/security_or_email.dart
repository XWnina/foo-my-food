import 'package:flutter/material.dart';
import 'one_security_question.dart';
import 'set_password_info_varification.dart';
import 'package:foo_my_food_app/utils/helper_function.dart'; // 导入邮箱格式验证方法
import 'package:foo_my_food_app/utils/constants.dart'; // 导入常量
import 'package:foo_my_food_app/utils/colors.dart'; // 导入颜色常量

class PasswordResetChoicePage extends StatelessWidget {
  const PasswordResetChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 MediaQuery 获取屏幕宽高
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Password Reset',
          style: TextStyle(color: whiteTextColor),
        ),
        backgroundColor: appBarColor,
      ),
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
          width: screenWidth * 0.9, // 调整为屏幕宽度的 90%
          height: screenHeight * 0.8, // 调整为屏幕高度的 80%
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          child: Stack(
            children: [
              // Title
              const Positioned(
                top: 100,
                left: 50,
                right: 50,
                child: Text(
                  'Please select the verification method for resetting your password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: blackTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Security Question Button
              Positioned(
                left: screenWidth * 0.2, // 相对于屏幕宽度动态调整位置
                top: screenHeight * 0.35, // 相对于屏幕高度动态调整位置
                child: SizedBox(
                  width: screenWidth * 0.5, // 根据屏幕宽度动态调整按钮宽度
                  height: screenHeight * 0.07, // 根据屏幕高度动态调整按钮高度
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
                          builder: (context) => const EmailInputPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Use Security Question',
                      style: TextStyle(
                        color: Color(0xFFE5E5E5),
                        fontSize: 15,
                        height: 1.5, // 调整行高使文字居中
                      ),
                      textAlign: TextAlign.center, // 确保文字居中对齐
                      maxLines: 2, // 确保文字最多两行显示
                    ),
                  ),
                ),
              ),
              // Email Link Button
              Positioned(
                left: screenWidth * 0.2,
                top: screenHeight * 0.45,
                child: SizedBox(
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.07,
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
                          builder: (context) => const PasswordResetPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Send Email Link',
                      style: TextStyle(
                        color: Color(0xFFE5E5E5),
                        fontSize: 15,
                        height: 1.5, // 调整行高使文字居中
                      ),
                      textAlign: TextAlign.center, // 确保文字居中对齐
                      maxLines: 2, // 确保文字最多两行显示
                    ),
                  ),
                ),
              ),
              // Cancel Button
              Positioned(
                left: screenWidth * 0.2,
                top: screenHeight * 0.55,
                child: SizedBox(
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.07,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFFE5E5E5),
                        fontSize: 15,
                        height: 1.5, // 调整行高使文字居中
                      ),
                      textAlign: TextAlign.center, // 确保文字居中对齐
                      maxLines: 2, // 确保文字最多两行显示
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailInputPage extends StatefulWidget {
  const EmailInputPage({super.key});

  @override
  State<EmailInputPage> createState() => _EmailInputPageState();
}

class _EmailInputPageState extends State<EmailInputPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;

  void _validateAndProceed() {
    String email = _emailController.text.trim();

    if (!HelperFunctions.checkEmailFormat(email)) {
      setState(() {
        _errorMessage = emailInvalidError;
      });
    } else {
      // 邮箱格式正确，跳转到 SecurityQuestionPage，并传递 email
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecurityQuestionPage(email: email),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        centerTitle: true,
        title: const Text('Enter Your Email', style: TextStyle(color: whiteTextColor)),
      ),
      backgroundColor: backgroundColor,
      body: Padding(
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
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: whiteFillColor,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: blueBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: greyBorderColor, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: blueBorderColor, width: 2.0),
                ),
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _validateAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(color: whiteTextColor, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
