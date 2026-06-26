import '../../domain/entities/blocked_user.dart';
import '../../domain/repositories/block_repository.dart';

/// Offline/no-op block repository.
class BlockRepositoryStub implements BlockRepository {
  @override
  Future<Set<String>> blockedIds() async => {};

  @override
  Future<void> block(String userId) async {}

  @override
  Future<void> unblock(String userId) async {}

  @override
  Future<List<BlockedUser>> blockedUsers() async => [];
}
