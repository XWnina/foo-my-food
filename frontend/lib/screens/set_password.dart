import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({Key? key}) : super(key: key);

  @override
  _SetPasswordPageState createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _resetPassword() async {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password == confirmPassword) {
      try {
        // 将新密码发送给后端 API（不再传递 token）
        final response = await http.post(
          Uri.parse('http://localhost:8081/api/password-reset/reset'),
          body: {
            'newPassword': password,
          },
        );

        if (response.statusCode == 200) {
          _showDialog('Success', 'Password has been reset successfully.');
        } else if (response.statusCode == 400) {
          _showDialog('Error', 'Invalid request.');
        } else if (response.statusCode == 500) {
          _showDialog('Error', 'Server error. Please try again later.');
        } else {
          _showDialog('Error', 'Failed to reset password.');
        }
      } catch (error) {
        _showDialog('Error', 'An error occurred: $error');
      }
    } else {
      _showDialog('Error', 'Passwords do not match.');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter your new password:'),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
