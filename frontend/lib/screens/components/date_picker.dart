// date_picker.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用于格式化日期

class DateAndTimeCompactCollapsed extends StatefulWidget {
  const DateAndTimeCompactCollapsed({super.key});

  @override
  _DateAndTimeCompactCollapsedState createState() => _DateAndTimeCompactCollapsedState();
}

class _DateAndTimeCompactCollapsedState extends State<DateAndTimeCompactCollapsed> {
  DateTime _selectedDate = DateTime.now(); // 默认选中当前日期

  // 显示日期选择器
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;  // 获取屏幕宽度
    double screenHeight = MediaQuery.of(context).size.height; // 获取屏幕高度

    double containerWidth = screenWidth * 0.7;  // 宽度为屏幕宽度的 70%
    double containerHeight = screenHeight * 0.05;  // 高度为屏幕高度的 5%

    return GestureDetector(
      onTap: () => _selectDate(context), // 点击时弹出日期选择器
      child: Container(
        width: containerWidth, // 根据屏幕大小动态设置宽度
        height: containerHeight, // 根据屏幕大小动态设置高度
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: ShapeDecoration(
                color: const Color(0x1E787880),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMM d,').format(_selectedDate), // 显示选中的日期
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 20, // 字体大小增加
                      fontFamily: 'ABeeZee',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 10), // 调整间距
                  Text(
                    DateFormat('yyyy').format(_selectedDate), // 显示选中的年份
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 20, // 字体大小增加
                      fontFamily: 'ABeeZee',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
