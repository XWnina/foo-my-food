import 'package:flutter/material.dart';
import 'package:foo_my_food_app/utils/colors.dart';
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
                  'CREATE ACCOUNT',
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
                onTap: _pickImage, // 点击时调用选择图片的方法
                child: CircleAvatar(
                  radius: 50, // 圆形头像的半径
                  backgroundColor: greyBackgroundColor, // 使用 color.dart 中的灰色背景
                  backgroundImage:
                      _image != null ? FileImage(_image!) : null, // 如果有图片则显示
                  child: _image == null
                      ? Icon(
                          Icons.camera_alt,
                          color: greyIconColor, // 使用 color.dart 中的图标颜色
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
                  style: TextStyle(color: redErrorTextColor), // 使用 color.dart 中定义的红色文字颜色
                ),
              ),

            const SizedBox(height: 20), // 增加一些间距
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: buttonBackgroundColor, // 使用 color.dart 中的按钮背景颜色
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
