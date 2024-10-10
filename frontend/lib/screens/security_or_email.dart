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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 32, 47),
      body: Center(
        child: Container(
          width: 360,
          height: 640,
          decoration: BoxDecoration(
            color: const Color(0xFFD1E7FE),
            border: Border.all(width: 1),
          ),
          child: Stack(
            children: [
              // Title
              const Positioned(
                top: 100,
                left: 50,
                right: 50,
                child: Text(
                  'Reset Your Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Security Question Button
              Positioned(
                left: 80,
                top: 250,
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47709B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to EmailInputPage
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
                      ),
                    ),
                  ),
                ),
              ),
              // Email Link Button
              Positioned(
                left: 80,
                top: 320,
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47709B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to email link verification page
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
                      ),
                    ),
                  ),
                ),
              ),
              // Cancel Button
              Positioned(
                left: 80,
                top: 390,
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47709B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      // Navigate back to login page
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFFE5E5E5),
                        fontSize: 15,
                      ),
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

// 新增 EmailInputPage 文件
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
        backgroundColor: appBarColor, // 使用自定义的 appBar 颜色
        centerTitle: true,
        title: const Text('Enter Your Email', style: TextStyle(color: whiteTextColor)),
      ),
      backgroundColor: backgroundColor, // 背景颜色
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
                fillColor: whiteFillColor, // 文本框填充颜色
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: blueBorderColor), // 边框颜色
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: greyBorderColor, width: 2.0), // 未聚焦时的边框颜色
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: blueBorderColor, width: 2.0), // 聚焦时的边框颜色
                ),
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50, // 高度与按钮保持一致
              child: ElevatedButton(
                onPressed: _validateAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBackgroundColor, // 按钮背景颜色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 圆角边框
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
