import 'package:flutter/material.dart';
import 'main.dart';
import 'create_account_page.dart';
import 'set_password_info_varification.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
              // Logo Image
              Positioned(
                left: 81,
                top: 77,
                child: Container(
                  width: 199,
                  height: 199,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                      image: AssetImage("image/logo3.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              // Username Field
              Positioned(
                left: 82,
                top: 324,
                child: Container(
                  width: 196,
                  height: 37,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEFFFF),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Username',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              // Password Field
              Positioned(
                left: 82,
                top: 375,
                child: Container(
                  width: 196,
                  height: 37,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEFFFF),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              // LOG IN Button
              Positioned(
                left: 135,
                top: 424,
                child: SizedBox(
                  width: 110, // 增加宽度
                  height: 40, // 增加高度
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47709B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // 圆角按钮
                      ),
                    ),
                    onPressed: () {
                      // 在点击按钮时导航到 MyHomePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MyHomePage(title: 'Home Page'),
                        ),
                      );
                    },
                    child: const Text(
                      'LOG IN',
                      style: TextStyle(
                        color: Color(0xFFE5E5E5),
                        fontSize: 15, // 增加字体大小
                      ),
                    ),
                  ),
                ),
              ),
              // Forget/Reset Password Button
              Positioned(
                left: 110,
                top: 480, // 调整位置，放在 LOG IN 按钮下方
                child: SizedBox(
                  width: 150, // 增加宽度
                  height: 40, // 增加高度
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47709B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // 圆角按钮
                      ),
                    ),
                    onPressed: () {
                      // 导航到 SetPasswordInfoVarification 页面
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PasswordResetPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forget/Reset Password',
                      style: TextStyle(
                        color: Color(0xFFE5E5E5),
                        fontSize: 13, // 保持字体大小一致
                      ),
                    ),
                  ),
                ),
              ),
              // Create Account Button
              Positioned(
                left: 110,
                top: 535, // 放置在 Forget/Reset Password 按钮下方
                child: SizedBox(
                  width: 150, // 增加宽度
                  height: 40, // 增加高度
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47709B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // 圆角按钮
                      ),
                    ),
                    onPressed: () {
                      // Handle create account action here
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateAccount(),
                        ),
                      );
                    },
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Color(0xFFE5E5E5),
                        fontSize: 13, // 保持字体大小一致
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
