import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseClient client;

  SupabaseNotificationRepository(this.client);

  AppNotification _toNotification(Map<String, dynamic> r) => AppNotification(
        id: r['id'] as String,
        userId: r['user_id'] as String,
        type: r['type'] as String? ?? '',
        title: r['title'] as String? ?? '',
        body: r['body'] as String? ?? '',
        bookingId: r['booking_id'] as String?,
        read: r['read'] as bool? ?? false,
        createdAt: DateTime.parse(r['created_at'] as String),
      );

  @override
  Future<List<AppNotification>> forUser(String userId) async {
    final rows = await client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows.map((r) => _toNotification(r)).toList();
  }

  @override
  Future<void> markAllRead(String userId) async {
    await client
        .from('notifications')
        .update({'read': true})
        .eq('user_id', userId)
        .eq('read', false);
  }

  @override
  Stream<AppNotification> stream(String userId) {
    final controller = StreamController<AppNotification>();
    final channel = client.channel('public:notifications:$userId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) =>
              controller.add(_toNotification(payload.newRecord)),
        )
        .subscribe();

    controller.onCancel = () => client.removeChannel(channel);
    return controller.stream;
  }
}
