import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foo_my_food_app/screens/login_page.dart';
import 'package:image_picker/image_picker.dart';
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      _showError('User ID not found');
      return;
    }

    final url = '$baseApiUrl/user/$userId';

    // 先从后端获取当前用户的原始数据
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

    // 验证并更新信息
    if (isUsernameChanged &&
        !HelperFunctions.checkUsernameFormat(_usernameController.text)) {
      _showError('Invalid username');
      return;
    }

    // 如果验证通过，提交更新数据
    final updateUrl = '$baseApiUrl/user/$userId/update';
    final request = http.MultipartRequest('POST', Uri.parse(updateUrl));

    request.fields['firstName'] = _firstNameController.text;
    request.fields['lastName'] = _lastNameController.text;
    request.fields['userName'] = _usernameController.text;
    request.fields['emailAddress'] = _emailController.text;
    request.fields['phoneNumber'] = _phoneController.text;

    if (_image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('avatar', _image!.path));
    }

    final updateResponse = await request.send();

    if (updateResponse.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully")));
    } else {
      _showError('Update failed');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: TextStyle(color: redErrorTextColor))));
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data

    // TODO: Add any additional logout logic here, such as API calls to invalidate tokens

    // Navigate to the login screen and remove all previous routes
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
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
                onTap: _pickImage,
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
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
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
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
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
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
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
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
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
