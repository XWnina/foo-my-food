import 'package:flutter/material.dart';

class SecurityQuestionSelectionPage extends StatefulWidget {
  const SecurityQuestionSelectionPage({super.key});

  @override
  _SecurityQuestionSelectionPageState createState() =>
      _SecurityQuestionSelectionPageState();
}

class _SecurityQuestionSelectionPageState
    extends State<SecurityQuestionSelectionPage> {
  String? _selectedQuestion;
  final TextEditingController _answerController = TextEditingController();

  final List<String> _securityQuestions = [
    '你最喜欢的老师的firstname是什么？',
    '你的爱好是什么？',
    '你使用的第一台电脑是什么系统？',
  ];

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
              // Back Button
              Positioned(
                left: 10,
                top: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              // Security Question Dropdown
              Positioned(
                left: 40, // Expanded width
                top: 150,
                child: Container(
                  width: 280, // Increased width to show full question
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEFFFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true, // Ensure dropdown uses the full width
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
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                              softWrap: true, // Allow text to wrap within the button
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
              // Answer Input Field
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
              // Submit Button
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
                    onPressed: () {
                      if (_selectedQuestion != null &&
                          _answerController.text.isNotEmpty) {
                        // Handle submission of the selected question and answer
                        Navigator.pop(context);
                        // Perform the validation or saving of the answer here
                      } else {
                        // Show an alert if no question is selected or answer is empty
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Incomplete'),
                            content: const Text(
                                'Please select a question and provide an answer.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
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
