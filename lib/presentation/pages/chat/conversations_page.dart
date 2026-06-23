import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/avatar_image.dart';
import '../../bloc/chat/conversations_cubit.dart';
import 'chat_page.dart';

/// List of the user's chat threads (priority — clients with an open booking —
/// first for artists).
class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ConversationsCubit>().refresh(),
    );
  }

  Future<void> _open(String conversationId, String title) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(conversationId: conversationId, title: title),
      ),
    );
    if (mounted) context.read<ConversationsCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Mensagens')),
      body: BlocBuilder<ConversationsCubit, ConversationsState>(
        builder: (context, state) {
          if (state.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.forum_outlined, size: 56, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma conversa ainda.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ConversationsCubit>().refresh(),
            child: ListView.separated(
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, i) {
                final c = state.items[i];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: avatarImage(c.otherAvatar),
                    child: avatarImage(c.otherAvatar) == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.otherName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (c.isPriority)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Agendado',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    c.lastMessage.isEmpty ? 'Conversa iniciada' : c.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.unread > 0 ? Colors.black87 : Colors.grey[600],
                      fontWeight:
                          c.unread > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: c.unread > 0
                      ? CircleAvatar(
                          radius: 11,
                          backgroundColor: primary,
                          child: Text(
                            c.unread > 9 ? '9+' : '${c.unread}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                  onTap: () => _open(c.id, c.otherName),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
