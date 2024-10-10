import 'package:flutter/material.dart';
import 'package:foo_my_food_app/services/security_api_service.dart'; // 引入 API 服务
import 'login_page.dart'; // 引入登录页面

class SecurityQuestionSelectionPage extends StatefulWidget {
  final String email;

  const SecurityQuestionSelectionPage({super.key, required this.email});

  @override
  _SecurityQuestionSelectionPageState createState() =>
      _SecurityQuestionSelectionPageState();
}

class _SecurityQuestionSelectionPageState
    extends State<SecurityQuestionSelectionPage> {
  String? _selectedQuestion;
  final TextEditingController _answerController = TextEditingController();

  final List<String> _securityQuestions = [
    'What is your favorite color?',
    'What is your hobby?',
    'What is your favorite number?',
  ];

  void _submitSecurityQuestion() async {
    if (_selectedQuestion != null && _answerController.text.isNotEmpty) {
      var response = await SecurityApiService.submitSecurityQuestion(
        email: widget.email,
        securityQuestion: _selectedQuestion!,
        securityAnswer: _answerController.text.trim(),
      );

      if (response.statusCode == 200) {
        _showSuccessMessage(); // 显示成功提示
      } else {
        _showSnackBar('Failed to submit security question.');
      }
    } else {
      _showSnackBar('Please select a question and provide an answer.');
    }
  }

  void _showSuccessMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content:
              const Text('Your security question has been set successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(), // 跳转到登录页面
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

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
              const Positioned(
                top: 50,
                left: 50,
                right: 50,
                child: Text(
                  'Answer Security Question',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                left: 20, // 调整位置
                top: 150,
                child: Container(
                  width: 320, // 增加宽度以容纳完整文字
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEFFFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true, // 保证下拉框全宽度显示
                      hint: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Select a security question',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      value: _selectedQuestion,
                      items: _securityQuestions.map((String question) {
                        return DropdownMenuItem<String>(
                          value: question,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              question,
                              style: const TextStyle(fontSize: 14),
                              softWrap: true,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedQuestion = newValue;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 80,
                top: 230,
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEFFFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _answerController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your answer',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 110,
                top: 320,
                child: SizedBox(
                  width: 150,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47709B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _submitSecurityQuestion,
                    child: const Text(
                      'Submit',
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
