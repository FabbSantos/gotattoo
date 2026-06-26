import 'package:flutter/material.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/utils/avatar_image.dart';
import '../../../domain/entities/blocked_user.dart';
import '../../../domain/repositories/block_repository.dart';

/// Lists the people the user has blocked, with an unblock action.
class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  List<BlockedUser>? _users;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await sl<BlockRepository>().blockedUsers();
    if (!mounted) return;
    setState(() => _users = list);
  }

  Future<void> _unblock(BlockedUser u) async {
    await sl<BlockRepository>().unblock(u.id);
    if (!mounted) return;
    setState(() => _users?.removeWhere((x) => x.id == u.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${u.name} desbloqueado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = _users;
    return Scaffold(
      appBar: AppBar(title: const Text('Usuários bloqueados')),
      body: users == null
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? Center(
                  child: Text(
                    'Você não bloqueou ninguém.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final u = users[i];
                    final image = avatarImage(u.avatar);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        backgroundImage: image,
                        child: image == null
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                      title: Text(u.name),
                      trailing: OutlinedButton(
                        onPressed: () => _unblock(u),
                        child: const Text('Desbloquear'),
                      ),
                    );
                  },
                ),
    );
  }
}
