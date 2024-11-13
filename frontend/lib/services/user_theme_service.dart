import 'package:foo_my_food_app/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserThemeService {
  // 获取用户主题
  static Future<String> fetchUserTheme(String userId) async {
    final url = Uri.parse('$baseApiUrl/user-theme/$userId');
    try {
      final response = await http.get(url);
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        String? userTheme = jsonResponse['userTheme'];

        // 如果 userTheme 为空或为 null，则返回默认主题
        return userTheme ?? "yellowGreenTheme";
      } else {
        print("Failed to fetch user theme: ${response.statusCode}");
        return "yellowGreenTheme"; // 请求失败时返回默认主题
      }
    } catch (e) {
      print("Error fetching user theme: $e");
      return "yellowGreenTheme"; // 捕获异常时返回默认主题
    }
  }

  // 更新用户主题
  static Future<void> updateUserTheme(
      String userId, String selectedTheme) async {
    final url = Uri.parse('$baseApiUrl/user-theme/$userId');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userTheme": selectedTheme}), // 确保使用 JSON 对象格式
      );

      if (response.statusCode == 200) {
        print("Theme updated successfully");
      } else {
        print("Failed to update theme: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating user theme: $e");
    }
  }
}
