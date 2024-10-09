import 'dart:convert';
import 'dart:io'; // 使用 dart:io 中的 HttpClient
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foo_my_food_app/services/userid_api_service.dart'; // 导入 api.dart 文件，用于获取 userId

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  File? _image; // 用户头像
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 从后端加载用户数据，并填充到控制器
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = Api.getUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found. Please login.')));
      return;
    }

    final url = 'http://localhost:8081/api/user/$userId'; // 替换为正确的后端API

    try {
      final uri = Uri.parse(url);
      final HttpClient client = HttpClient();
      final HttpClientRequest request = await client.getUrl(uri);

      // 添加 Accept 头部，指定接受 JSON 响应
      request.headers.set(HttpHeaders.acceptHeader, "application/json");

      final HttpClientResponse response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final userData = jsonDecode(responseBody);

        print(userData); // 打印返回的数据以进行调试

        if (userData.isNotEmpty) {
          setState(() {
            _firstNameController.text = userData["firstName"] ?? ''; // 防止为 null
            _lastNameController.text = userData["lastName"] ?? '';
            _usernameController.text = userData["username"] ?? '';
            _emailController.text = userData["email"] ?? '';
            _phoneController.text = userData["phoneNumber"] ?? '';

            // 如果用户有头像
            if (userData["avatarUrl"] != null &&
                userData["avatarUrl"].isNotEmpty) {
              _image = File(userData["avatarUrl"]!); // 确保 avatarUrl 不是 null
            }
          });
        } else {
          throw Exception('User data is empty.');
        }
      } else {
        throw Exception(
            'Failed to load user data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load user data')));
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    // 调用API更新用户数据
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Profile updated successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Icon(Icons.camera_alt, size: 30, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
