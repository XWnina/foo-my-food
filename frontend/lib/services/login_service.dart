import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:foo_my_food_app/utils/constants.dart';

class LoginService {
  Future<http.Response> login(String usernameOrEmail, String password) async {
    final url = Uri.parse('$baseApiUrl/login');

    // 构建请求体，确保键名是 'usernameOrEmail'
    final body = jsonEncode({
      'usernameOrEmail': usernameOrEmail, // 确保这里的键名和后端一致
      'password': password,
    });

    try {
      // 发送 POST 请求
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to send login request: $e');
    }
  }
}
