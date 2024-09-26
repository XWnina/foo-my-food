import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'components/text_field.dart'; // 导入 text_field.dart，里面包含了通用的输入框函数

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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 更新图片路径
      });
    }
  }

  /// 验证两次密码是否匹配
  void _checkPasswordsMatch(String value) {
    setState(() {
      _passwordsDoNotMatch =
          _passwordController.text != _confirmPasswordController.text;
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
                  backgroundImage:
                      _image != null ? FileImage(_image!) : null, // 如果有图片则显示
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

            // 使用 buildTextInputField 构建通用文本输入框
            buildTextInputField(label: 'FIRST NAME'),
            buildTextInputField(label: 'LAST NAME'),
            buildTextInputField(label: 'EMAIL ADDRESS'),
            buildTextInputField(label: 'USERNAME'),
            buildTextInputField(label: 'PHONE NUMBER'),

            // 使用 buildPasswordInputField 构建密码输入框
            buildPasswordInputField(
              label: 'PASSWORD',
              controller: _passwordController,
            ),

            // 确认密码输入框，支持错误提示
            buildPasswordInputField(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: const Color(0xFF47709B),
                ),
                onPressed: _passwordsDoNotMatch
                    ? null // 如果密码不匹配，禁用按钮
                    : () {
                        // 如果密码匹配，继续创建账号
                        print(
                            'Passwords match, proceed with account creation.');
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
}
