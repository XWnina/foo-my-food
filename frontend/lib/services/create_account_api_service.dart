import 'package:foo_my_food_app/utils/constants.dart'; // 引入 baseApiUrl 等常量
import 'package:http/http.dart' as http;
import 'dart:io';

class CreateAccountApiService {
  // 使用 constants.dart 中的 baseApiUrl
  static const String apiUrl = '$baseApiUrl/create-account';

  /// 发送创建账号请求到后端
  static Future<http.StreamedResponse> createAccount({
    required String firstName,
    required String lastName,
    required String userName,
    required String emailAddress,
    required String phoneNumber, // 注意字段名与后端匹配
    required String password,
    File? image, // 可选的图片文件
  }) async {
    try {
      // 创建 multipart 请求
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // 添加文本字段
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['userName'] = userName; // 与后端字段名匹配
      request.fields['emailAddress'] = emailAddress;
      request.fields['phoneNumber'] = phoneNumber; // 注意匹配后端的字段
      request.fields['password'] = password;

      // 如果用户上传了头像，添加到请求中，确保字段名为 'image'
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path), // 字段名应与后端匹配
        );
      }

      // 发送请求并返回响应
      return await request.send();
    } catch (error) {
      // 捕获错误并抛出详细异常
      throw Exception('Failed to create account: $error');
    }
  }
}
