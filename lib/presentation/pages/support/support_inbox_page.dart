import 'package:flutter/material.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/utils/avatar_image.dart';
import '../../../domain/entities/support_message.dart';
import '../../../domain/repositories/support_repository.dart';
import 'support_thread_page.dart';

/// Owner-only: all support conversations, newest first.
class SupportInboxPage extends StatefulWidget {
  const SupportInboxPage({super.key});

  @override
  State<SupportInboxPage> createState() => _SupportInboxPageState();
}

class _SupportInboxPageState extends State<SupportInboxPage> {
  List<SupportThread>? _threads;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await sl<SupportRepository>().threads();
    if (!mounted) return;
    setState(() => _threads = t);
  }

  @override
  Widget build(BuildContext context) {
    final threads = _threads;
    return Scaffold(
      appBar: AppBar(title: const Text('Suporte')),
      body: threads == null
          ? const Center(child: CircularProgressIndicator())
          : threads.isEmpty
              ? RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    children: [
                      const SizedBox(height: 120),
                      Icon(Icons.forum_outlined,
                          size: 56, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Center(
                        child: Text('Nenhuma conversa ainda.',
                            style: TextStyle(color: Colors.grey[600])),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    itemCount: threads.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) => _tile(threads[i]),
                  ),
                ),
    );
  }

  Widget _tile(SupportThread t) {
    final image = avatarImage(t.userAvatar);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        backgroundImage: image,
        child: image == null ? const Icon(Icons.person) : null,
      ),
      title: Text(t.userName,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        '${t.lastFromOwner ? 'Você: ' : ''}${t.lastBody}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SupportThreadPage(
              threadUserId: t.userId,
              asOwner: true,
              title: t.userName,
            ),
          ),
        );
        _load();
      },
    );
  }
}
