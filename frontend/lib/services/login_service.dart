import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:foo_my_food_app/utils/constants.dart';

class LoginService {
  // 登录服务方法
  Future<http.Response> login(String usernameOrEmail, String password) async {
    final url = Uri.parse('$baseApiUrl/login'); // 这里的 baseApiUrl 应该包含 '/api'

    // 构建请求体，确保键名是 'usernameOrEmail' 和 'password'
    final body = jsonEncode({
      'usernameOrEmail': usernameOrEmail,
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

      // 根据不同状态码返回相应结果
      return response;
    } catch (e) {
      throw Exception('Failed to send login request: $e');
    }
  }


  // 检查邮箱验证状态的方法
  Future<http.Response> checkVerificationStatus(String emailAddress) async {
    final url = Uri.parse('$baseApiUrl/check-verification-status?emailAddress=$emailAddress');

    try {
      final response = await http.get(url);
      return response;
    } catch (e) {
      throw Exception('Failed to check verification status: $e');
    }
  }
}
