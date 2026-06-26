import '../entities/blocked_user.dart';

/// Blocking users (UGC safety). The app hides blocked people's feed content.
abstract class BlockRepository {
  /// Ids the current user has blocked.
  Future<Set<String>> blockedIds();

  Future<void> block(String userId);

  Future<void> unblock(String userId);

  /// Blocked users with name/avatar, for the manage screen.
  Future<List<BlockedUser>> blockedUsers();
}
