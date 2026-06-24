import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/local_notifications_service.dart';
import '../../../domain/repositories/notification_repository.dart';
import 'notifications_state.dart';

/// Owns the signed-in user's notifications: loads history, listens for new ones
/// in realtime, surfaces an OS notification for each, and tracks the unread
/// badge count.
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository repository;
  final LocalNotificationsService localNotifications;

  String? _userId;
  StreamSubscription? _sub;

  NotificationsCubit({
    required this.repository,
    required this.localNotifications,
  }) : super(const NotificationsState());

  /// Start tracking notifications for [userId] (idempotent per user).
  Future<void> start(String userId) async {
    if (_userId == userId) return;
    _userId = userId;
    emit(state.copyWith(loading: true));
    final items = await repository.forUser(userId);
    emit(NotificationsState(items: items));

    _sub?.cancel();
    _sub = repository.stream(userId).listen((n) {
      emit(state.copyWith(items: [n, ...state.items]));
      localNotifications.show(n.title, n.body);
    });
  }

  Future<void> markAllRead() async {
    final userId = _userId;
    if (userId == null) return;
    await repository.markAllRead(userId);
    emit(state.copyWith(
      items: state.items.map((n) => n.copyWith(read: true)).toList(),
    ));
  }

  /// Delete all notifications for the current user.
  Future<void> clearAll() async {
    final userId = _userId;
    if (userId == null) return;
    await repository.clearAll(userId);
    emit(const NotificationsState());
  }

  /// Drop the subscription and state (e.g. on logout).
  void stop() {
    _sub?.cancel();
    _sub = null;
    _userId = null;
    emit(const NotificationsState());
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
