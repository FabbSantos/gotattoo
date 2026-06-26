import 'package:equatable/equatable.dart';

/// A user the current user has blocked (shown in the manage screen).
class BlockedUser extends Equatable {
  final String id;
  final String name;
  final String? avatar;

  const BlockedUser({required this.id, required this.name, this.avatar});

  @override
  List<Object?> get props => [id, name, avatar];
}
