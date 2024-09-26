import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  CreateAccountState createState() => CreateAccountState();
}

class CreateAccountState extends State<CreateAccount> {
  File? _image; // 存储选中的图片
  final _passwordController = TextEditingController(); // 用于第一个密码输入框
  final _confirmPasswordController = TextEditingController(); // 用于确认密码输入框
  bool _passwordsDoNotMatch = false; // 用于检测密码是否匹配

  // 从图库或相机选择图片
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 更新图片路径
      });
    }
  }

  /// 验证两次密码是否匹配
void _checkPasswordsMatch(String value) {
  setState(() {
    _passwordsDoNotMatch = _passwordController.text != _confirmPasswordController.text;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1E7FE),
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF47709B),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 30, bottom: 10),
                child: Text(
                  'CREATE ACCOUNT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // 头像上传框
            Center(
              child: GestureDetector(
                onTap: _pickImage, // 点击时调用选择图片的方法
                child: CircleAvatar(
                  radius: 50, // 圆形头像的半径
                  backgroundColor: Colors.grey[300], // 默认背景颜色
                  backgroundImage: _image != null ? FileImage(_image!) : null, // 如果有图片则显示
                  child: _image == null
                      ? Icon(
                          Icons.camera_alt,
                          color: Colors.grey[700], // 上传图标
                          size: 30,
                        )
                      : null, // 如果没有图片则显示图标
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 输入框: First Name
            _buildTextInputField(label: 'FIRST NAME'),

            // 输入框: Last Name
            _buildTextInputField(label: 'LAST NAME'),

            // 输入框: Email Address
            _buildTextInputField(label: 'EMAIL ADDRESS'),

            // 输入框: Username
            _buildTextInputField(label: 'USERNAME'),

            // 输入框: Phone Number
            _buildTextInputField(label: 'PHONE NUMBER'),

            // 输入框: Password
            _buildPasswordInputField(label: 'PASSWORD', controller: _passwordController),

            // 输入框: Confirm Password
            _buildPasswordInputField(
              label: 'CONFIRM PASSWORD',
              controller: _confirmPasswordController,
              isError: _passwordsDoNotMatch, // 密码不匹配时设置错误
              onChanged: _checkPasswordsMatch, // 每次输入时都检查密码是否匹配
            ),

            if (_passwordsDoNotMatch) // 如果密码不一致，显示错误信息
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Passwords do not match',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 20), // 增加一些间距
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), backgroundColor: const Color(0xFF47709B),
                ),
                onPressed: _passwordsDoNotMatch
                    ? null // 如果密码不匹配，禁用按钮
                    : () {
                        // 如果密码匹配，继续创建账号
                        print('Passwords match, proceed with account creation.');
                      },
                child: const Text(
                  'Create',
                  style: TextStyle(
                    color: Colors.white,
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

  // 创建输入框的通用方法
  Widget _buildTextInputField({required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: Colors.blue,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  // 创建密码输入框的通用方法，支持错误提示
  Widget _buildPasswordInputField({
    required String label,
    required TextEditingController controller,
    bool isError = false,
    void Function(String)? onChanged, // 增加 onChanged 回调
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: true, // 隐藏密码
        onChanged: onChanged, // 当输入改变时调用回调
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: isError ? Colors.red : Colors.grey, // 如果有错误，边框变红
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: isError ? Colors.red : Colors.blue, // 焦点状态下变红
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
