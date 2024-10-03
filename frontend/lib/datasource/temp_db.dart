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
      "username": "fang331",
      "email": "fang331@purdue.edu",
      "password": "password123",
      "createdAt": DateTime.now(),
      "profileImage": "https://example.com/profile.jpg",
      "emailVerified": true,
      "phoneNumber": "7657670582"
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
// Sample food items
  static List<Map<String, dynamic>> foodItems = [
    {
      'id': 1,
      'name': 'Apple',
      'category': 'Fruits',
      'imageUrl': 'https://example.com/apple.jpg',
      'expirationDate': DateTime.now().add(Duration(days: 7)),
      'nutritionInfo': {'Calories': '95', 'Carbs': '25g', 'Fiber': '4g'},
      'storageMethod': 'Refrigerator',
      'quantity': 5,
    },
    {
      'id': 2,
      'name': 'Chicken Breast',
      'category': 'Meat',
      'imageUrl': 'https://example.com/chicken.jpg',
      'expirationDate': DateTime.now().add(Duration(days: 3)),
      'nutritionInfo': {'Calories': '165', 'Protein': '31g', 'Fat': '3.6g'},
      'storageMethod': 'Freezer',
      'quantity': 2,
    },
    {
      'id': 3,
      'name': 'Milk',
      'category': 'Dairy',
      'imageUrl': 'https://example.com/milk.jpg',
      'expirationDate': DateTime.now().add(Duration(days: 5)),
      'nutritionInfo': {'Calories': '103', 'Protein': '8g', 'Fat': '2.4g'},
      'storageMethod': 'Refrigerator',
      'quantity': 1,
    },
    {
      'id': 4,
      'name': 'Bread',
      'category': 'Grains',
      'imageUrl': 'https://example.com/bread.jpg',
      'expirationDate': DateTime.now().add(Duration(days: 4)),
      'nutritionInfo': {'Calories': '79', 'Carbs': '14g', 'Protein': '3g'},
      'storageMethod': 'Pantry',
      'quantity': 1,
    },
    {
      'id': 5,
      'name': 'Spinach',
      'category': 'Vegetables',
      'imageUrl': 'https://example.com/spinach.jpg',
      'expirationDate': DateTime.now().add(Duration(days: 5)),
      'nutritionInfo': {'Calories': '7', 'Carbs': '1g', 'Protein': '0.9g'},
      'storageMethod': 'Refrigerator',
      'quantity': 1,
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
  // Get all food items
  static List<Map<String, dynamic>> getAllFoodItems() {
    return foodItems;
  }

  // Get food item by id
  static Map<String, dynamic> getFoodItemById(int id) {
    return foodItems.firstWhere(
      (item) => item['id'] == id,
      orElse: () => <String, dynamic>{},
    );
  }
}
