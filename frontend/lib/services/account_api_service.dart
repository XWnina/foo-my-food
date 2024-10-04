import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:foo_my_food_app/utils/constants.dart'; // 导入常量

class AccountApiService {
  static Future<bool> checkVerificationStatus(String email) async {
    final response = await http.get(
      Uri.parse('$baseApiUrl/check-verification-status?emailAddress=$email'),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse['isVerified'] == true;
    } else {
      throw Exception('Failed to check verification status');
    }
  }
}
