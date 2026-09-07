import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'twela_channel',
      'Twela Notifications',
      channelDescription: 'Notifications for Twela app',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }

  static Future<void> showBudgetWarning({
    required String title,
    required String body,
  }) async {
    await showNotification(id: 1001, title: title, body: body);
  }

  static Future<void> showDailyLimitWarning(String body) async {
    await showNotification(id: 1002, title: 'تجاوز الحد اليومي', body: body);
  }

  static Future<void> showLowBalanceWarning(String body) async {
    await showNotification(id: 1003, title: 'رصيد منخفض', body: body);
  }

  static Future<void> showRoutineSuggestion(String body) async {
    await showNotification(id: 1004, title: 'اقتراح روتين', body: body);
  }

  static Future<void> showRoutineAutoRecord(String body) async {
    await showNotification(id: 1005, title: 'تسجيل تلقائي', body: body);
  }
}
