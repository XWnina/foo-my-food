import 'dart:convert';
import 'dart:io';

class Api {
  // 全局变量保存 userId
  static int? _userId;

  // 获取当前的 userId
  static int? getUserId() {
    return _userId;
  }

  // 登录函数，用于获取并保存 userId
  static Future<int?> login(String username, String password) async {
    final url = 'http://localhost:8081/api/login'; // 替换为实际的后端登录 API

    try {
      final httpClient = HttpClient();
      final request = await httpClient.postUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json");
      request.write(jsonEncode({
        "username": username,
        "password": password,
      }));

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final decodedResponse = jsonDecode(responseBody);

        // 假设 userId 在返回的数据中
        _userId = decodedResponse['userId'];
        return _userId;
      } else {
        throw Exception('Failed to login. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
}
