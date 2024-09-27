import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:foo_my_food_app/utils/helper_function.dart'; // 导入验证函数
import 'package:foo_my_food_app/utils/constants.dart'; // 导入常量
import 'package:foo_my_food_app/utils/colors.dart'; // 导入颜色常量
import 'components/text_field.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  CreateAccountState createState() => CreateAccountState();
}

class CreateAccountState extends State<CreateAccount> {
  File? _image; // 存储选中的图片
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _usernameInvalid = false;
  bool _usernameTaken = false;
  bool _emailInvalid = false;
  bool _emailTaken = false;
  bool _phoneInvalid = false;
  bool _phoneTaken = false;
  bool _passwordsDoNotMatch = false;

  // 从图库或相机选择图片
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 更新图片路径
      });
    }
  }

  // 验证用户名字段
  void _validateUsername() {
    setState(() {
      final validationResults = HelperFunctions.validateInput(
        username: _usernameController.text,
        email: _emailController.text, // 其他字段暂时保持现状
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      _usernameInvalid = validationResults['usernameInvalid'];
      _usernameTaken = validationResults['usernameTaken'];
    });
  }

  // 验证邮箱字段
  void _validateEmail() {
    setState(() {
      final validationResults = HelperFunctions.validateInput(
        username: _usernameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      _emailInvalid = validationResults['emailInvalid'];
      _emailTaken = validationResults['emailTaken'];
    });
  }

  // 验证电话号码字段
  void _validatePhoneNumber() {
    setState(() {
      final validationResults = HelperFunctions.validateInput(
        username: _usernameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      _phoneInvalid = validationResults['phoneInvalid'];
      _phoneTaken = validationResults['phoneTaken'];
    });
  }

  // 验证密码字段
  void _validatePasswords() {
    setState(() {
      final validationResults = HelperFunctions.validateInput(
        username: _usernameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      _passwordsDoNotMatch = validationResults['passwordsDoNotMatch'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // 使用 color.dart 中定义的背景颜色
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: appBarColor, // 使用 color.dart 中定义的 AppBar 颜色
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 30, bottom: 10),
                child: Text(
                  createAccountTitle, // 使用 constants.dart 中的标题常量
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: blackTextColor, // 使用 color.dart 中定义的黑色文字颜色
                  ),
                ),
              ),
            ),

            // 头像上传框
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundColor: greyBackgroundColor,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Icon(Icons.camera_alt, color: greyIconColor, size: 30)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // First Name 输入框
            buildTextInputField(label: 'FIRST NAME', controller: _firstNameController),

            // Last Name 输入框
            buildTextInputField(label: 'LAST NAME', controller: _lastNameController),

            // Username 输入框
            buildTextInputField(
              label: 'USERNAME',
              controller: _usernameController,
              onChanged: (value) => _validateUsername(),
            ),
            if (_usernameInvalid) const Text(usernameInvalidError, style: TextStyle(color: redErrorTextColor)),
            if (_usernameTaken) const Text(usernameTakenError, style: TextStyle(color: redErrorTextColor)),

            // Email 输入框
            buildTextInputField(
              label: 'EMAIL ADDRESS',
              controller: _emailController,
              onChanged: (value) => _validateEmail(),
            ),
            if (_emailInvalid) const Text(emailInvalidError, style: TextStyle(color: redErrorTextColor)),
            if (_emailTaken) const Text(emailTakenError, style: TextStyle(color: redErrorTextColor)),

            // Phone Number 输入框
            buildTextInputField(
              label: 'PHONE NUMBER',
              controller: _phoneController,
              onChanged: (value) => _validatePhoneNumber(),
              keyboardType: TextInputType.phone,
            ),
            if (_phoneInvalid) const Text(phoneInvalidError, style: TextStyle(color: redErrorTextColor)),
            if (_phoneTaken) const Text(phoneTakenError, style: TextStyle(color: redErrorTextColor)),

            // Password 输入框
            buildPasswordInputField(
              label: 'PASSWORD',
              controller: _passwordController,
              onChanged: (value) => _validatePasswords(),
            ),

            // Confirm Password 输入框
            buildPasswordInputField(
              label: 'CONFIRM PASSWORD',
              controller: _confirmPasswordController,
              isError: _passwordsDoNotMatch,
              onChanged: (value) => _validatePasswords(),
            ),
            if (_passwordsDoNotMatch) const Text(passwordMismatchError, style: TextStyle(color: redErrorTextColor)),

            const SizedBox(height: 20), // 增加一些间距
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                  backgroundColor: buttonBackgroundColor, // 使用 color.dart 中的按钮背景颜色
                ),
                // 禁用按钮的条件是用户名无效、用户名已被使用、邮箱格式错误、邮箱已被使用、电话号码无效、电话号码已被使用或密码不匹配
                onPressed: _usernameInvalid || _usernameTaken || _emailInvalid || _emailTaken || _phoneInvalid || _phoneTaken || _passwordsDoNotMatch
                    ? null
                    : () {
                        // 创建账号逻辑
                      },
                child: const Text(
                  'Create',
                  style: TextStyle(
                    color: whiteTextColor, // 使用 color.dart 中的白色文字颜色
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
