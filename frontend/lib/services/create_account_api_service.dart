import 'package:http/http.dart' as http;
import 'dart:io';

class CreateAccountApiService {
  static const String apiUrl = 'http://192.168.x.x:8080/create-account'; // 替换为你的后端 URL

  static Future<http.StreamedResponse> createAccount({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
    required String password,
    File? image,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    // 添加文本字段
    request.fields['firstName'] = firstName;
    request.fields['lastName'] = lastName;
    request.fields['username'] = username;
    request.fields['email'] = email;
    request.fields['phone'] = phone;
    request.fields['password'] = password;

    // 如果用户上传了头像，添加到请求中
    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', image.path),
      );
    }

    // 发送请求并返回响应
    return await request.send();
  }
}
