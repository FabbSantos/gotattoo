import '../entities/app_notification.dart';

abstract class NotificationRepository {
  /// All notifications for [userId], newest first.
  Future<List<AppNotification>> forUser(String userId);

  /// Mark every unread notification of [userId] as read.
  Future<void> markAllRead(String userId);

  /// Emits each new notification inserted for [userId] in realtime.
  Stream<AppNotification> stream(String userId);
}
