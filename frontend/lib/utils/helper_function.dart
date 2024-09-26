import 'package:foo_my_food_app/datasource/temp_db.dart';
// helper_function.dart
class HelperFunctions {
  // 检查两次密码是否匹配
  static bool checkPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  // 检查用户名是否唯一
  static bool checkUsernameUnique(String username) {
    final user = TempDB.getUserByUsername(username);
    return user.isNotEmpty; // 如果返回的 Map 不为空，说明用户名已被使用
  }

  // 检查邮箱格式是否正确
  static bool checkEmailFormat(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email); // 返回邮箱格式是否匹配
  }

  // 检查电话号码是否为 10 位数字
  static bool checkPhoneNumberFormat(String phoneNumber) {
    final phoneRegex = RegExp(r"^\d{10}$"); // 正则表达式检测 10 位数字
    return phoneRegex.hasMatch(phoneNumber); // 返回电话号码格式是否正确
  }
}
