import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local notifications: used for class reminders and attendance confirmations.
/// In production the same channel receives Firebase Cloud Messaging pushes
/// from the backend; the channel id and styling are shared by both paths.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
    );
    _ready = true;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_ready) await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'campus_alerts',
        'Campus alerts',
        channelDescription: 'Class reminders and attendance confirmations',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _plugin.show(id, title, body, details);
  }
}
