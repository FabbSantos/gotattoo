import 'package:equatable/equatable.dart';

import '../../../domain/entities/app_notification.dart';

class NotificationsState extends Equatable {
  final bool loading;
  final List<AppNotification> items;

  const NotificationsState({this.loading = false, this.items = const []});

  int get unread => items.where((n) => !n.read).length;

  NotificationsState copyWith({bool? loading, List<AppNotification>? items}) =>
      NotificationsState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [loading, items];
}
