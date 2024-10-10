import 'package:flutter/material.dart';
import 'set_password.dart';

class SecurityQuestionPage extends StatefulWidget {
  final String email; // 接收从之前页面传来的 email

  const SecurityQuestionPage({super.key, required this.email});

  @override
  State<SecurityQuestionPage> createState() => _SecurityQuestionPageState();
}

class _SecurityQuestionPageState extends State<SecurityQuestionPage> {
  final TextEditingController _answerController = TextEditingController();
  final String _securityQuestion = 'What is your mother\'s maiden name?'; // Example question
  final String _correctAnswer = 'Smith'; // Example correct answer

  void _verifyAnswer() {
    if (_answerController.text.trim().toLowerCase() == _correctAnswer.toLowerCase()) {
      // 显示成功提示框并导航到 ChangePasswordPage，同时传递 email
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Verification Successful'),
            content: const Text('Your answer is correct. You can now reset your password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to SetPasswordPage and pass the email
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetPasswordPage(email: widget.email), // 使用传递的 email
                    ),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // 显示失败提示框
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Verification Failed'),
            content: const Text('The answer you provided is incorrect. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF47709B),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Security Question',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // 返回到前一个页面
          },
        ),
      ),
      backgroundColor: const Color(0xFFD1E7FE),
      body: Center(
        child: Container(
          width: 360,
          height: 640,
          decoration: const BoxDecoration(
            color: Color(0xFFD1E7FE),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Security Question',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _securityQuestion,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _answerController,
                  decoration: const InputDecoration(
                    labelText: 'Your Answer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47709B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _verifyAnswer,
                    child: const Text(
                      'Verify',
                      style: TextStyle(
                        color: Color(0xFFE5E5E5),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
