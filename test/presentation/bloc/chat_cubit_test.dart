import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/domain/entities/chat_message.dart';
import 'package:gotattoo/domain/entities/conversation.dart';
import 'package:gotattoo/domain/repositories/chat_repository.dart';
import 'package:gotattoo/presentation/bloc/chat/chat_cubit.dart';

ChatMessage _msg(String id, String sender, String body) => ChatMessage(
      id: id,
      conversationId: 'c1',
      senderId: sender,
      body: body,
      createdAt: DateTime(2026, 1, 1),
    );

class FakeChatRepository implements ChatRepository {
  final List<ChatMessage> initial;
  final controller = StreamController<ChatMessage>.broadcast();
  int markReadCalls = 0;
  int sendSeq = 0;

  FakeChatRepository(this.initial);

  @override
  Future<List<ChatMessage>> messages(String conversationId) async => initial;

  @override
  Future<ChatMessage> send(String c, String sender, String body) async {
    return _msg('sent-${sendSeq++}', sender, body);
  }

  @override
  Future<void> markRead(String c, String userId) async => markReadCalls++;

  @override
  Stream<ChatMessage> streamMessages(String c) => controller.stream;

  @override
  Future<String> openWithArtist(String artistId) async => 'c1';

  @override
  Future<String> openWithClient(String clientId) async => 'c1';

  @override
  Future<List<Conversation>> conversations() async => const [];
}

void main() {
  late FakeChatRepository repo;
  late ChatCubit cubit;

  setUp(() {
    repo = FakeChatRepository([_msg('1', 'other', 'oi')]);
    cubit = ChatCubit(repository: repo, conversationId: 'c1', userId: 'me');
  });

  tearDown(() async {
    await cubit.close();
    await repo.controller.close();
  });

  test('load fetches history and marks read', () async {
    await cubit.load();
    expect(cubit.state.messages, hasLength(1));
    expect(repo.markReadCalls, 1);
  });

  test('send appends my message immediately', () async {
    await cubit.load();
    await cubit.send('olá');
    expect(cubit.state.messages.last.body, 'olá');
    expect(cubit.state.messages.last.senderId, 'me');
  });

  test('blank message is ignored', () async {
    await cubit.load();
    await cubit.send('   ');
    expect(cubit.state.messages, hasLength(1));
  });

  test('an incoming realtime message is appended and marked read', () async {
    await cubit.load();
    repo.controller.add(_msg('2', 'other', 'tudo bem?'));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.messages, hasLength(2));
    expect(repo.markReadCalls, 2); // once on load, once on incoming
  });

  test('a duplicate realtime echo is de-duped', () async {
    await cubit.load();
    final dup = _msg('dup', 'me', 'eco');
    repo.controller.add(dup);
    repo.controller.add(dup);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.messages.where((m) => m.id == 'dup'), hasLength(1));
  });
}
