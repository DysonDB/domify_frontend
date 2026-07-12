// 📁 lib/services/notification_service.dart — production-ready local notifications and simulating scheduler
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// System initialization with error catching to avoid startup crashes
  static Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings();
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
      );
      _initialized = true;
    } catch (e) {
      // Safe fallback log
      print('NotificationService init error: $e');
    }
  }

  /// Instantly trigger local push alert
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'domify_channel',
        'dnb Homes Updates',
        channelDescription: 'Updates for listings, price alerts & reminders',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );
      await _notificationsPlugin.show(id, title, body, details);
    } catch (e) {
      print('showNotification error: $e');
    }
  }

  /// Schedule notification at a strict future timestamp
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) await init();
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'domify_reminders',
            'dnb Homes Reminders',
            channelDescription: 'Appointment reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print('scheduleNotification error: $e');
    }
  }
}
