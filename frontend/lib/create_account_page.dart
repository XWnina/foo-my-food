import 'package:flutter/material.dart';

class CreateAccount extends StatelessWidget {
  const CreateAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1E7FE), // 设置整体背景颜色
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF47709B),
      ),
      body: Column(
        children: [
          Container(
            width: 360,
            height: 640,
            clipBehavior: Clip.antiAlias,
            decoration: const ShapeDecoration(
              color: Color.fromARGB(255, 17, 18, 20),
              shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 88,
                  top: 531,
                  child: Container(
                    width: 183,
                    height: 34,
                    decoration: const ShapeDecoration(
                      color: Color(0xFF47709B),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Color(0xFFC4C4C4)),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 89,
                  top: 531,
                  child: SizedBox(
                    width: 182,
                    height: 34,
                    child: Text(
                      'Create',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE5E5E5),
                        fontSize: 13,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 22,
                  top: 66,
                  child: SizedBox(
                    width: 360,
                    height: 43,
                    child: Text(
                      'CREATE ACCOUNT ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ),
                ),
                // 可以继续添加其他控件...
              ],
            ),
          ),
        ],
      ),
    );
  }
}