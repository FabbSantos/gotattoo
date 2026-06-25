import '../../domain/entities/support_message.dart';
import '../../domain/repositories/support_repository.dart';

/// Offline/no-op support repository (the in-app mural needs the backend).
class SupportRepositoryStub implements SupportRepository {
  @override
  Stream<List<SupportMessage>> watch(String threadUserId) =>
      Stream.value(const []);

  @override
  Future<void> send({
    required String threadUserId,
    required String body,
    required bool asOwner,
  }) async {}

  @override
  Future<List<SupportThread>> threads() async => const [];
}
