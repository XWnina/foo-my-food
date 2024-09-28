import 'package:foo_my_food_app/utils/constants.dart'; // 导入常量
import 'package:foo_my_food_app/datasource/temp_db.dart'; // 导入模拟数据库

class HelperFunctions {
  // 检查两次密码是否匹配
  static bool checkPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  // 检查用户名格式是否符合 Instagram 规则
  static bool checkUsernameFormat(String username) {
    final usernameRegex = RegExp(instagramUsernameRegexPattern); // 使用 Instagram 用户名的正则表达式
    return usernameRegex.hasMatch(username);
  }

  // 检查用户名是否唯一
  static bool checkUsernameUnique(String username) {
    final user = TempDB.getUserByUsername(username);
    return user.isEmpty; // 如果返回的 Map 为空，说明用户名是唯一的
  }

  // 检查邮箱格式是否正确
  static bool checkEmailFormat(String email) {
    final emailRegex = RegExp(emailRegexPattern); // 从 constants.dart 导入邮箱正则表达式
    return emailRegex.hasMatch(email);
  }

  // 检查邮箱是否唯一
  static bool checkEmailUnique(String email) {
    final user = TempDB.getUserByEmail(email.toLowerCase()); // 忽略邮箱的大小写
    return user.isEmpty; // 如果返回的 Map 为空，说明邮箱是唯一的
  }

  // 检查电话号码是否为 10 位数字
  static bool checkPhoneNumberFormat(String phoneNumber) {
    final phoneRegex = RegExp(phoneNumberRegexPattern); // 使用 10 位电话号码的正则表达式
    return phoneRegex.hasMatch(phoneNumber);
  }

  // 检查电话号码是否唯一
  static bool checkPhoneNumberUnique(String phoneNumber) {
    final user = TempDB.getUserByPhoneNumber(phoneNumber);
    return user.isEmpty; // 如果返回的 Map 为空，说明电话号码是唯一的
  }

  // 检查所有输入项是否合法，并返回验证结果
  static Map<String, dynamic> validateInput({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) {
    bool usernameInvalid = !checkUsernameFormat(username); // 检查用户名格式是否符合规则
    bool usernameTaken = !checkUsernameUnique(username); // 检查用户名是否唯一
    bool emailInvalid = !checkEmailFormat(email); // 检查邮箱格式是否正确
    bool emailTaken = !checkEmailUnique(email); // 检查邮箱是否唯一
    bool phoneInvalid = !checkPhoneNumberFormat(phoneNumber); // 检查电话号码格式
    bool phoneTaken = !checkPhoneNumberUnique(phoneNumber); // 检查电话号码是否唯一
    bool passwordsDoNotMatch = !checkPasswordsMatch(password, confirmPassword); // 检查两次密码是否匹配

    return {
      'usernameInvalid': usernameInvalid,
      'usernameTaken': usernameTaken,
      'emailInvalid': emailInvalid,
      'emailTaken': emailTaken,
      'phoneInvalid': phoneInvalid,
      'phoneTaken': phoneTaken,
      'passwordsDoNotMatch': passwordsDoNotMatch,
    };
  }
}
