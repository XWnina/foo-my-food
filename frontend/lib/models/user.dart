import 'dart:io';

class User {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String password;
  final File? image; // 可选的图片字段

  User({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    this.image, // 头像图片可以是可选的
  });

  // 将用户数据转换为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
      // 注意：图片不会被直接包含在 JSON 数据中
    };
  }
}
