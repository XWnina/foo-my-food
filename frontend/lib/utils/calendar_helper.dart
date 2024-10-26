import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class CalendarHelper {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  // 初始化时区信息
  CalendarHelper() {
    tz.initializeTimeZones();
  }

  // 检查并请求日历权限
  Future<bool> checkCalendarPermission() async {
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess == true &&
        permissionsGranted.data == true) {
      return true;
    } else {
      var result = await _deviceCalendarPlugin.requestPermissions();
      return result.isSuccess == true && result.data == true;
    }
  }

  // 创建日历事件
  Future<bool> createCalendarEvent(
      String title, DateTime expirationDate) async {
    var calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (calendarsResult.isSuccess == true &&
        (calendarsResult.data?.isNotEmpty ?? false)) {
      var selectedCalendar = calendarsResult.data!.first; // 使用第一个日历

      // 转换 DateTime 为 TZDateTime
      final tz.TZDateTime expirationTZDateTime =
          tz.TZDateTime.from(expirationDate, tz.local);

      var event = Event(selectedCalendar.id);
      event.title = title;
      event.start = expirationTZDateTime;
      event.end = expirationTZDateTime;
      event.description = "Your ingredient $title is about to expire!";
      event.allDay = true;
      event.reminders = [Reminder(minutes: 60 * 9)]; // 提前9小时，即当天早上9点提醒

      var createEventResult =
          await _deviceCalendarPlugin.createOrUpdateEvent(event);

      if (createEventResult != null &&
          createEventResult.isSuccess == true &&
          (createEventResult.data?.isNotEmpty ?? false)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
