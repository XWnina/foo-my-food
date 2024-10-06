import 'package:foo_my_food_app/utils/constants.dart'; // 引入 baseApiUrl 等常量
import 'package:http/http.dart' as http;

class PasswordResetApiService {
  // 使用 constants.dart 中的 baseApiUrl 拼接 API 地址
  static const String sendLinkUrl = '$baseApiUrl/password-reset/send-link';
  static const String checkVerificationUrl = '$baseApiUrl/password-reset/check-verification';

  /// 发送重置密码请求到后端
  static Future<http.Response> sendResetLink({required String emailAddress}) async {
    try {
      // 创建请求，使用 JSON 格式发送数据
      final response = await http.post(
        Uri.parse(sendLinkUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: '{"email": "$emailAddress"}', // 将 email 转换为 JSON 格式
      );

      return response;
    } catch (error) {
      // 捕获错误并抛出详细异常
      throw Exception('Failed to send password reset link: $error');
    }
  }

  /// 检查验证状态
  static Future<http.Response> checkVerificationStatus({required String emailAddress}) async {
    try {
      final response = await http.get(
        Uri.parse('$checkVerificationUrl?email=$emailAddress'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      return response;
    } catch (error) {
      throw Exception('Failed to check verification status: $error');
    }
  }
}
