import 'package:flutter/material.dart';
import 'main.dart';
import 'create_account_page.dart';

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
                left: 136,
                top: 424,
                child: SizedBox(
                  width: 89,
                  height: 29,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47709B),
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
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              // Create Account Button
              Positioned(
                left: 116,
                top: 535,
                child: SizedBox(
                  width: 129,
                  height: 29,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47709B),
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
                        fontSize: 13,
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
