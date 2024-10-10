import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:foo_my_food_app/services/create_account_api_service.dart'; // 导入 CreateAccount API 服务
import 'dart:developer' as developer; // 使用 log 函数
import 'package:foo_my_food_app/utils/helper_function.dart'; // 导入验证函数
import 'package:foo_my_food_app/utils/constants.dart'; // 导入常量
import 'package:foo_my_food_app/utils/colors.dart'; // 导入颜色常量
import 'package:foo_my_food_app/services/account_api_service.dart'; // 导入 Account API 服务
import 'package:foo_my_food_app/Screens/choose_security_q.dart'; // 导入 Security Question 页面
import 'components/text_field.dart'; // 自定义输入框组件

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  CreateAccountState createState() => CreateAccountState();
}

class CreateAccountState extends State<CreateAccount> {
  File? _image; // 存储用户选择的头像
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
  bool _isSubmitting = false; // 新增的标志位，防止重复提交

  // 让用户从图库或相机选择图片
  Future<void> _pickImage() async {
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () async {
              Navigator.pop(context,
                  await ImagePicker().pickImage(source: ImageSource.gallery));
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a picture'),
            onTap: () async {
              Navigator.pop(context,
                  await ImagePicker().pickImage(source: ImageSource.camera));
            },
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 更新图片路径
      });
    }
  }

  // 验证用户名字段
  Future<void> _validateUsername(String username) async {
    setState(() {
      _usernameInvalid = !HelperFunctions.checkUsernameFormat(username);
    });
    if (!_usernameInvalid) {
      _usernameTaken = !await HelperFunctions.checkUsernameUnique(username);
      setState(() {}); // 更新状态
    }
  }

  // 验证邮箱字段
  Future<void> _validateEmail(String email) async {
    setState(() {
      _emailInvalid = !HelperFunctions.checkEmailFormat(email);
    });
    if (!_emailInvalid) {
      _emailTaken = !await HelperFunctions.checkEmailUnique(email);
      setState(() {}); // 更新状态
    }
  }

  // 验证电话号码字段
  Future<void> _validatePhoneNumber(String phoneNumber) async {
    setState(() {
      _phoneInvalid = !HelperFunctions.checkPhoneNumberFormat(phoneNumber);
    });
    if (!_phoneInvalid) {
      _phoneTaken = !await HelperFunctions.checkPhoneNumberUnique(phoneNumber);
      setState(() {}); // 更新状态
    }
  }

  // 验证密码字段
  void _validatePasswords() {
    setState(() {
      _passwordsDoNotMatch = !HelperFunctions.checkPasswordsMatch(
        _passwordController.text,
        _confirmPasswordController.text,
      );
    });
  }

  // 显示 SnackBar 消息
  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // 提交创建账号请求
  Future<void> _submitCreateAccount() async {
    if (_isSubmitting) return; // 防止重复提交

    setState(() {
      _isSubmitting = true; // 设置为提交状态
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordsDoNotMatch = true;
        _isSubmitting = false; // 重置提交状态
      });
      _showSnackBar('Passwords do not match.');
      return;
    }

    try {
      // 调用 CreateAccountApiService 来处理请求
      var response = await CreateAccountApiService.createAccount(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        userName: _usernameController.text, // 改为 userName
        emailAddress: _emailController.text, // 改为 emailAddress
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
        image: _image, // 用户头像
      );

      // 处理响应
      if (response.statusCode == 200) {
        developer.log('Account created successfully.', name: 'CreateAccount');
        _showSnackBar(
            'Account created successfully. Please check your email for verification.');
        _startEmailVerificationPolling(); // 开始轮询邮箱验证状态
      } else {
        // 提取响应内容
        var responseBody = await response.stream.bytesToString();
        developer.log('Failed to create account. Reason: $responseBody',
            name: 'CreateAccount');
        _showSnackBar('Failed to create account. Reason: $responseBody');
      }
    } catch (error) {
      developer.log('Error occurred: $error',
          name: 'CreateAccount', error: error);
      _showSnackBar('Error occurred: $error');
    } finally {
      setState(() {
        _isSubmitting = false; // 重置提交状态，允许再次点击
      });
    }
  }

  // 轮询检查邮箱验证状态
  Future<void> _startEmailVerificationPolling() async {
    const pollInterval = Duration(seconds: 5); // 每 5 秒检查一次
    bool isVerified = false;

    while (!isVerified) {
      // 只有验证成功后轮询才会终止
      try {
        isVerified = await AccountApiService.checkVerificationStatus(
            _emailController.text);
        if (isVerified) {
          _showSnackBar('Your account has been verified!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const SecurityQuestionSelectionPage()), // 跳转到 SecurityQuestionSelectionPage
          );
          break; // 停止轮询
        }
      } catch (error) {
        developer.log('Error checking email verification status: $error',
            name: 'CreateAccount');
      }
      await Future.delayed(pollInterval); // 等待 5 秒后再次检查
    }
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
            buildTextInputField(
                label: 'FIRST NAME', controller: _firstNameController),

            // Last Name 输入框
            buildTextInputField(
                label: 'LAST NAME', controller: _lastNameController),

            // Username 输入框
            buildTextInputField(
              label: 'USERNAME',
              controller: _usernameController,
              onChanged: (value) {
                _validateUsername(value); // 每次输入时验证用户名唯一性
              },
            ),
            if (_usernameInvalid)
              const Text(usernameInvalidError,
                  style: TextStyle(color: redErrorTextColor)),
            if (_usernameTaken)
              const Text(usernameTakenError,
                  style: TextStyle(color: redErrorTextColor)),

            // Email 输入框
            buildTextInputField(
              label: 'EMAIL ADDRESS',
              controller: _emailController,
              onChanged: (value) {
                _validateEmail(value); // 每次输入时验证邮箱唯一性
              },
            ),
            if (_emailInvalid)
              const Text(emailInvalidError,
                  style: TextStyle(color: redErrorTextColor)),
            if (_emailTaken)
              const Text(emailTakenError,
                  style: TextStyle(color: redErrorTextColor)),

            // Phone Number 输入框
            buildTextInputField(
              label: 'PHONE NUMBER',
              controller: _phoneController,
              onChanged: (value) {
                _validatePhoneNumber(value); // 每次输入时验证电话号码唯一性
              },
              keyboardType: TextInputType.phone,
            ),
            if (_phoneInvalid)
              const Text(phoneInvalidError,
                  style: TextStyle(color: redErrorTextColor)),
            if (_phoneTaken)
              const Text(phoneTakenError,
                  style: TextStyle(color: redErrorTextColor)),

            // Password 输入框
            buildPasswordInputField(
              label: 'PASSWORD',
              controller: _passwordController,
              onChanged: (value) {
                _validatePasswords(); // 每次输入时验证密码
              },
            ),

            // Confirm Password 输入框
            buildPasswordInputField(
              label: 'CONFIRM PASSWORD',
              controller: _confirmPasswordController,
              onChanged: (value) {
                _validatePasswords(); // 每次输入时验证密码匹配
              },
            ),
            if (_passwordsDoNotMatch)
              const Text(passwordMismatchError,
                  style: TextStyle(color: redErrorTextColor)),

            const SizedBox(height: 20), // 增加一些间距
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 15.0),
                  backgroundColor:
                      buttonBackgroundColor, // 使用 color.dart 中的按钮背景颜色
                ),
                onPressed: _isSubmitting ||
                        _usernameInvalid ||
                        _usernameTaken ||
                        _emailInvalid ||
                        _emailTaken ||
                        _phoneInvalid ||
                        _phoneTaken ||
                        _passwordsDoNotMatch
                    ? null
                    : () {
                        _submitCreateAccount(); // 发送创建账号的请求
                      },
                child: Text(
                  _isSubmitting ? 'Creating...' : 'Create', // 这里改为非常量
                  style: const TextStyle(
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
