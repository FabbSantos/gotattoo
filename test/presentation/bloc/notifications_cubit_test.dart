import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/services/local_notifications_service.dart';
import 'package:gotattoo/domain/entities/app_notification.dart';
import 'package:gotattoo/domain/repositories/notification_repository.dart';
import 'package:gotattoo/presentation/bloc/notification/notifications_cubit.dart';

AppNotification _notif(String id, {bool read = false, String type = 'booking_confirmed'}) =>
    AppNotification(
      id: id,
      userId: 'u1',
      type: type,
      title: 'Title $id',
      body: 'Body $id',
      read: read,
      createdAt: DateTime(2026, 1, 1),
    );

/// In-memory repository with a controllable realtime stream.
class FakeNotificationRepository implements NotificationRepository {
  final List<AppNotification> initial;
  final controller = StreamController<AppNotification>.broadcast();
  bool markedRead = false;

  FakeNotificationRepository(this.initial);

  @override
  Future<List<AppNotification>> forUser(String userId) async => initial;

  @override
  Future<void> markAllRead(String userId) async => markedRead = true;

  @override
  Future<void> clearAll(String userId) async {}

  @override
  Stream<AppNotification> stream(String userId) => controller.stream;
}

void main() {
  late FakeNotificationRepository repo;
  late NotificationsCubit cubit;

  setUp(() {
    repo = FakeNotificationRepository([_notif('1', read: true)]);
    cubit = NotificationsCubit(
      repository: repo,
      localNotifications: LocalNotificationsService(),
    );
  });

  tearDown(() async {
    await cubit.close();
    await repo.controller.close();
  });

  test('start loads existing notifications', () async {
    await cubit.start('u1');
    expect(cubit.state.items, hasLength(1));
    expect(cubit.state.unread, 0);
  });

  test('a realtime notification is prepended and counts as unread', () async {
    await cubit.start('u1');
    repo.controller.add(_notif('2'));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.items.first.id, '2');
    expect(cubit.state.items, hasLength(2));
    expect(cubit.state.unread, 1);
  });

  test('markAllRead clears the unread count', () async {
    await cubit.start('u1');
    repo.controller.add(_notif('2'));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.unread, 1);

    await cubit.markAllRead();
    expect(cubit.state.unread, 0);
    expect(repo.markedRead, isTrue);
  });

  test('stop clears state', () async {
    await cubit.start('u1');
    cubit.stop();
    expect(cubit.state.items, isEmpty);
  });
}
