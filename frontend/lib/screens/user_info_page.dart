import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foo_my_food_app/screens/login_page.dart';
import 'package:image_picker/image_picker.dart'; // 导入用于选择图片的包
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:foo_my_food_app/utils/helper_function.dart';
import 'package:foo_my_food_app/utils/colors.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  File? _image;
  String? _avatarUrl;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // 错误状态
  String? _usernameError;
  String? _emailError;
  String? _phoneError;

  // Save按钮是否可点击
  bool _isSaveButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found. Please log in again.')));
      return;
    }

    final url = '$baseApiUrl/user/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        if (userData.isNotEmpty) {
          setState(() {
            _firstNameController.text = userData["firstName"] ?? '';
            _lastNameController.text = userData["lastName"] ?? '';
            _usernameController.text = userData["userName"] ?? '';
            _emailController.text = userData["emailAddress"] ?? '';
            _phoneController.text = userData["phoneNumber"] ?? '';
            _avatarUrl = userData["imageURL"];
          });
        } else {
          throw Exception('User data is empty.');
        }
      } else {
        throw Exception(
            'Failed to retrieve user data, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load user data')));
    }
  }

  // 选择图片（相机或图库）
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // 打开底部菜单让用户选择图片来源
  Future<void> _showImageSourceSelection() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera); // 使用相机拍照
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery); // 从图库选择
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 验证用户名
  void _validateUsername(String username) {
    setState(() {
      if (!RegExp(instagramUsernameRegexPattern).hasMatch(username)) {
        _usernameError = 'Invalid username';
      } else {
        _usernameError = null; // 验证通过，清空错误
      }
      _checkIfFormIsValid();
    });
  }

  // 验证邮箱
  void _validateEmail(String email) {
    setState(() {
      if (!RegExp(emailRegexPattern).hasMatch(email)) {
        _emailError = 'Invalid email format';
      } else {
        _emailError = null; // 验证通过，清空错误
      }
      _checkIfFormIsValid();
    });
  }

  // 验证电话号码
  void _validatePhoneNumber(String phoneNumber) {
    setState(() {
      if (!RegExp(phoneNumberRegexPattern).hasMatch(phoneNumber)) {
        _phoneError = 'Phone number must be 10 digits';
      } else {
        _phoneError = null; // 验证通过，清空错误
      }
      _checkIfFormIsValid();
    });
  }

  // 检查所有表单是否有效
  void _checkIfFormIsValid() {
    if (_usernameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty) {
      _isSaveButtonEnabled = true;
    } else {
      _isSaveButtonEnabled = false;
    }
  }

  Future<void> _saveProfile() async {
    if (!_isSaveButtonEnabled) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      _showError('User ID not found');
      return;
    }

    final url = '$baseApiUrl/user/$userId';

    // 获取用户的原始数据
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      _showError('Failed to retrieve user data');
      return;
    }

    final originalUserData = jsonDecode(response.body);
    bool isPhoneChanged =
        originalUserData['phoneNumber'] != _phoneController.text;
    bool isEmailChanged =
        originalUserData['emailAddress'] != _emailController.text;
    bool isUsernameChanged =
        originalUserData['userName'] != _usernameController.text;

    // 验证信息
    if (isUsernameChanged &&
        !HelperFunctions.checkUsernameFormat(_usernameController.text)) {
      _showError('Invalid username');
      return;
    }

    // 提交更新数据
    final updateUrl = '$baseApiUrl/user/$userId/update';
    final request = http.MultipartRequest('POST', Uri.parse(updateUrl));

    request.fields['firstName'] = _firstNameController.text;
    request.fields['lastName'] = _lastNameController.text;
    request.fields['userName'] = _usernameController.text;
    request.fields['emailAddress'] = _emailController.text;
    request.fields['phoneNumber'] = _phoneController.text;

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('avatar', _image!.path));
    }

    try {
      final updateResponse = await request.send();

      if (updateResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile updated successfully")));
      } else if (updateResponse.statusCode == 409) {
        // 处理冲突：读取服务器返回的错误信息
        final responseBody = await updateResponse.stream.bytesToString();
        if (responseBody.contains('Username already taken')) {
          setState(() {
            _usernameError = 'Username already taken';
          });
        } else if (responseBody.contains('Email address already taken')) {
          setState(() {
            _emailError = 'Email address already taken';
          });
        } else if (responseBody.contains('Phone number already taken')) {
          setState(() {
            _phoneError = 'Phone number already taken';
          });
        } else {
          _showError('Conflict occurred while updating profile');
        }
      } else {
        _showError('Update failed');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      _showError('User ID not found');
      return;
    }

    final url = '$baseApiUrl/logout';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        await prefs.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      } else {
        _showError('Logout failed: ${response.body}');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: TextStyle(color: redErrorTextColor))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Logout"),
                    content: Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text("Logout"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _logout();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _showImageSourceSelection, // 打开图片来源选择
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundColor: greyBackgroundColor,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null),
                  child: _image == null && _avatarUrl == null
                      ? Icon(Icons.camera_alt, size: 30, color: greyIconColor)
                      : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            // First Name Input Field
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                filled: true,
                fillColor: whiteFillColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: greyBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: blueBorderColor),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Last Name Input Field
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                filled: true,
                fillColor: whiteFillColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: greyBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: blueBorderColor),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Username Input Field
            TextField(
              controller: _usernameController,
              onChanged: (value) => _validateUsername(value),
              decoration: InputDecoration(
                labelText: 'Username',
                errorText: _usernameError,
                filled: true,
                fillColor: whiteFillColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _usernameError == null ? greyBorderColor : Colors.red),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _usernameError == null ? blueBorderColor : Colors.red),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Email Input Field
            TextField(
              controller: _emailController,
              onChanged: (value) => _validateEmail(value),
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _emailError,
                filled: true,
                fillColor: whiteFillColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _emailError == null ? greyBorderColor : Colors.red),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _emailError == null ? blueBorderColor : Colors.red),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Phone Number Input Field
            TextField(
              controller: _phoneController,
              onChanged: (value) => _validatePhoneNumber(value),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                errorText: _phoneError,
                filled: true,
                fillColor: whiteFillColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _phoneError == null ? greyBorderColor : Colors.red),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _phoneError == null ? blueBorderColor : Colors.red),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaveButtonEnabled ? _saveProfile : null, // 按钮是否可点击
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSaveButtonEnabled ? buttonBackgroundColor : Colors.grey, // 动态设置颜色
                foregroundColor: whiteTextColor,
              ),
              child: Text("Save"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Logout"),
                      content: Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text("Logout"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _logout();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: whiteTextColor,
              ),
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
