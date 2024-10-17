import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:foo_my_food_app/utils/constants.dart'; // 导入常量

class HelperFunctions {
  // 检查两次密码是否匹配
  static bool checkPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  // 检查密码是否至少5个字符并且包含一个特殊字符
  static bool checkPasswordRequirements(String password) {
    // 正则表达式要求密码至少包含一个特殊字符并且长度不少于5个字符
    final passwordRegex = RegExp(passwordRegexPsttern);
    return passwordRegex.hasMatch(password);
  }

  // 检查用户名格式是否符合规则 (使用 constants.dart 中定义的正则表达式)
  static bool checkUsernameFormat(String username) {
    final usernameRegex =
        RegExp(instagramUsernameRegexPattern); // 使用 Instagram 用户名的正则表达式
    return usernameRegex.hasMatch(username);
  }

  // 检查邮箱格式是否正确 (使用 constants.dart 中定义的正则表达式)
  static bool checkEmailFormat(String email) {
    final emailRegex = RegExp(emailRegexPattern); // 从 constants.dart 导入邮箱正则表达式
    return emailRegex.hasMatch(email);
  }

  // 检查电话号码格式是否正确 (使用 constants.dart 中定义的正则表达式)
  static bool checkPhoneNumberFormat(String phoneNumber) {
    final phoneRegex = RegExp(phoneNumberRegexPattern); // 使用 10 位电话号码的正则表达式
    return phoneRegex.hasMatch(phoneNumber);
  }

  // 构造 URI helper 函数，减少重复代码
  static Uri _buildUri(String field, String value) {
    return Uri.parse('$baseApiUrl/check-unique?$field=$value');
  }

  // 异步检查用户名是否唯一
  static Future<bool> checkUsernameUnique(String username) async {
    try {
      final response = await http.get(_buildUri('userName', username));
      if (response.statusCode == 200) {
        return true; // 用户名是唯一的
      } else if (response.statusCode == 409) {
        return false; // 用户名已被使用
      } else {
        throw Exception('Unexpected error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to check username uniqueness: $e');
    }
  }

  // 异步检查邮箱是否唯一
  static Future<bool> checkEmailUnique(String email) async {
    try {
      final response = await http.get(_buildUri('emailAddress', email));
      if (response.statusCode == 200) {
        return true; // 邮箱是唯一的
      } else if (response.statusCode == 409) {
        return false; // 邮箱已被使用
      } else {
        throw Exception('Unexpected error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to check email uniqueness: $e');
    }
  }

  // 异步检查电话号码是否唯一
  static Future<bool> checkPhoneNumberUnique(String phoneNumber) async {
    try {
      final response = await http.get(_buildUri('phoneNumber', phoneNumber));
      if (response.statusCode == 200) {
        return true; // 电话号码是唯一的
      } else if (response.statusCode == 409) {
        return false; // 电话号码已被使用
      } else {
        throw Exception('Unexpected error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to check phone number uniqueness: $e');
    }
  }

  // 异步验证所有输入项是否合法，并返回验证结果
  static Future<Map<String, dynamic>> validateInput({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      bool usernameInvalid = !checkUsernameFormat(username); // 检查用户名格式是否符合规则
      bool usernameTaken = !await checkUsernameUnique(username); // 从后端检查用户名是否唯一
      bool emailInvalid = !checkEmailFormat(email); // 检查邮箱格式是否正确
      bool emailTaken = !await checkEmailUnique(email); // 从后端检查邮箱是否唯一
      bool phoneInvalid = !checkPhoneNumberFormat(phoneNumber); // 检查电话号码格式
      bool phoneTaken =
          !await checkPhoneNumberUnique(phoneNumber); // 从后端检查电话号码是否唯一
      bool passwordsDoNotMatch =
          !checkPasswordsMatch(password, confirmPassword); // 检查两次密码是否匹配

      return {
        'usernameInvalid': usernameInvalid,
        'usernameTaken': usernameTaken,
        'emailInvalid': emailInvalid,
        'emailTaken': emailTaken,
        'phoneInvalid': phoneInvalid,
        'phoneTaken': phoneTaken,
        'passwordsDoNotMatch': passwordsDoNotMatch,
      };
    } catch (e) {
      throw Exception('Error during input validation: $e');
    }
  }
}
