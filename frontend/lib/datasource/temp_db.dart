// dummy table database, use for test

// List of food categories for add_ingrediant_manually.dart
List<String> foodCategories = [
  'Vegetables',
  'Fruits',
  'Meat',
  'Dairy',
  'Grains',
  'Spices',
  'Beverages',
];

// List of storage methods for add_ingrediant_manually.dart
List<String> storageMethods = [
  'Refrigerator',
  'Freezer',
  'Pantry',
  'Room Temperature',
];

class TempDB {
  // 模拟的用户数据列表
  static List<Map<String, dynamic>> users = [
    {
      "id": 1,
      "username": "charlie_fang",
      "email": "charlie@example.com",
      "password": "password123",
      "createdAt": DateTime.now(),
      "profileImage": "https://example.com/profile.jpg",
      "emailVerified": true,
      "phoneNumber": "1234567890"
    },
    {
      "id": 2,
      "username": "john_doe",
      "email": "john.doe@example.com",
      "password": "mySecurePass",
      "createdAt": DateTime.now(),
      "profileImage": "https://example.com/john.jpg",
      "emailVerified": false,
      "phoneNumber": "0987654321"
    },
    {
      "id": 3,
      "username": "jane_doe",
      "email": "jane.doe@example.com",
      "password": "pass456",
      "createdAt": DateTime.now(),
      "profileImage": "https://example.com/jane.jpg",
      "emailVerified": true,
      "phoneNumber": "1122334455"
    },
  ];

  // 根据用户名获取用户信息 (区分大小写)
  static Map<String, dynamic> getUserByUsername(String username) {
    return users.firstWhere(
      (user) => user['username'] == username,
      orElse: () => <String, dynamic>{}, // 返回一个空的 Map
    );
  }

  // 根据邮箱获取用户信息 (忽略大小写)
  static Map<String, dynamic> getUserByEmail(String email) {
    return users.firstWhere(
      (user) => user['email'].toLowerCase() == email.toLowerCase(), // 忽略大小写匹配
      orElse: () => <String, dynamic>{}, // 返回一个空的 Map
    );
  }

  // 根据电话号码获取用户信息
  static Map<String, dynamic> getUserByPhoneNumber(String phoneNumber) {
    return users.firstWhere(
      (user) => user['phoneNumber'] == phoneNumber,
      orElse: () => <String, dynamic>{}, // 返回一个空的 Map
    );
  }
}
