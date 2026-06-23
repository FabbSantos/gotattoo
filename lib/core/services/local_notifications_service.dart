import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Thin wrapper around flutter_local_notifications for showing OS notifications
/// when a realtime event arrives while the app is alive.
///
/// Every call is guarded so it's a harmless no-op in tests / on platforms where
/// the plugin isn't available.
class LocalNotificationsService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;
  int _id = 0;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'bookings',
    'Agendamentos',
    channelDescription: 'Atualizações dos seus agendamentos',
    importance: Importance.high,
    priority: Priority.high,
  );

  Future<void> init() async {
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _plugin.initialize(settings);
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  Future<void> show(String title, String body) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        _id++,
        title,
        body,
        const NotificationDetails(android: _androidDetails),
      );
    } catch (_) {
      // Ignore: notifications are best-effort.
    }
  }
}
