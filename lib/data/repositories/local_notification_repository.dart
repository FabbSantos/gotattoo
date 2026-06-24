import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

/// Offline/test stub: no backend, so there are no notifications and the stream
/// never emits.
class LocalNotificationRepository implements NotificationRepository {
  @override
  Future<List<AppNotification>> forUser(String userId) async => const [];

  @override
  Future<void> markAllRead(String userId) async {}

  @override
  Future<void> clearAll(String userId) async {}

  @override
  Stream<AppNotification> stream(String userId) => const Stream.empty();
}
