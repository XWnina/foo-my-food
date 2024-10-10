import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:foo_my_food_app/utils/constants.dart'; // 使用 constants.dart 中的 baseApiUrl

class SecurityApiService {
  // 提交安全问题
   // 提交安全问题
  static Future<http.Response> submitSecurityQuestion({
    required String email,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    final response = await http.post(
      Uri.parse('$baseApiUrl/password-reset/submit-security-question'), // 注意此处的 URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': email,
        'securityQuestion': securityQuestion,
        'securityAnswer': securityAnswer,
      }),
    );
    return response;
  }

  // 获取安全问题
  static Future<http.Response> getSecurityQuestion(String email) async {
    final response = await http.get(
      Uri.parse('$baseApiUrl/password-reset/get-security-question?email=$email'), // 使用 baseApiUrl
    );
    return response;
  }

  // 验证安全问题答案
  static Future<http.Response> verifySecurityAnswer(String email, String answer) async {
    final response = await http.post(
      Uri.parse('$baseApiUrl/password-reset/verify-security-answer'), // 使用 baseApiUrl
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': email,
        'answer': answer,
      }),
    );
    return response;
  }
}
