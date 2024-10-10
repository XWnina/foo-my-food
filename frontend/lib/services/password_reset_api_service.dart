import 'dart:convert'; // 导入 JSON 编解码库
import 'package:http/http.dart' as http; // 导入 HTTP 请求库
import 'package:foo_my_food_app/utils/constants.dart'; // 导入 constants.dart 文件

class PasswordResetApiService {
  // 定义发送重置链接的 API URL
  static const String sendLinkUrl = '$baseApiUrl/password-reset/send-link';
  // 定义检查验证状态的 API URL
  static const String checkVerificationUrl = '$baseApiUrl/password-reset/check-verification';

  /// 发送重置密码链接请求到后端，传递邮箱和用户名参数
  static Future<http.Response> sendResetLink({
    required String emailAddress, 
    required String userName,  // 新增用户名参数
  }) async {
    try {
      // 发起 POST 请求
      final response = await http.post(
        Uri.parse(sendLinkUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': emailAddress, 
          'userName': userName, // 包含用户名和邮箱
        }),
      );

      return response; // 返回响应
    } catch (error) {
      throw Exception('Failed to send password reset link: $error');
    }
  }

  /// 检查用户邮箱的验证状态
  static Future<http.Response> checkVerificationStatus({
    required String emailAddress,
  }) async {
    try {
      // 发起 GET 请求，使用邮箱地址作为查询参数
      final response = await http.get(
        Uri.parse('$checkVerificationUrl?email=$emailAddress'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      return response; // 返回响应
    } catch (error) {
      throw Exception('Failed to check verification status: $error');
    }
  }
}
