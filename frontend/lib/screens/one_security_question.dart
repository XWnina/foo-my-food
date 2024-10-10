import 'package:flutter/material.dart';
import 'dart:convert';
import 'set_password.dart';
import 'package:foo_my_food_app/services/security_api_service.dart'; // 引入API服务

class SecurityQuestionPage extends StatefulWidget {
  final String email;

  const SecurityQuestionPage({super.key, required this.email});

  @override
  State<SecurityQuestionPage> createState() => _SecurityQuestionPageState();
}

class _SecurityQuestionPageState extends State<SecurityQuestionPage> {
  final TextEditingController _answerController = TextEditingController();
  String? _securityQuestion;
  bool _loading = true; // 用于显示加载进度

  @override
  void initState() {
    super.initState();
    _fetchSecurityQuestion();
  }

  Future<void> _fetchSecurityQuestion() async {
    var response = await SecurityApiService.getSecurityQuestion(widget.email);
    if (response.statusCode == 200) {
      setState(() {
        _securityQuestion = jsonDecode(response.body)['securityQuestion'];
        _loading = false;
      });
    } else {
      _showSnackBar('Failed to retrieve security question.');
    }
  }

  void _verifyAnswer() async {
    if (_answerController.text.isNotEmpty) {
      var response = await SecurityApiService.verifySecurityAnswer(
        widget.email,
        _answerController.text.trim(),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SetPasswordPage(email: widget.email)),
        );
      } else {
        _showSnackBar('Incorrect answer. Please try again.');
      }
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xFFD1E7FE),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator() // 显示加载进度
            : Container(
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
                        _securityQuestion ?? 'Loading...',
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
