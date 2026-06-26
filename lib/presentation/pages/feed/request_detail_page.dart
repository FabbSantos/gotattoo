import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/utils/avatar_image.dart';
import '../../../domain/entities/request_comment.dart';
import '../../../domain/entities/tattoo_request.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/block_repository.dart';
import '../../../domain/repositories/tattoo_request_repository.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/feed/request_comments_cubit.dart';
import '../../widgets/components/common/artist_tag.dart';
import '../../widgets/components/common/owner_tag.dart';
import '../../widgets/components/common/sensitive_image.dart';
import '../chat/chat_page.dart';
import 'create_request_page.dart';

/// A tattoo request with its comments. Artists can comment and open a chat to
/// negotiate with the author.
class RequestDetailPage extends StatelessWidget {
  final TattooRequest request;

  const RequestDetailPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RequestCommentsCubit(
        repository: sl(),
        requestId: request.id,
      )..load(),
      child: _DetailView(request: request),
    );
  }
}

class _DetailView extends StatefulWidget {
  final TattooRequest request;

  const _DetailView({required this.request});

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _send() {
    final text = _comment.text.trim();
    if (text.isEmpty) return;
    final user = context.read<AuthCubit>().state.user;
    if (user == null) return;
    context.read<RequestCommentsCubit>().add(
          RequestComment(
            id: '',
            requestId: widget.request.id,
            authorId: user.id,
            authorName: user.displayName,
            authorAvatar: user.avatarPath,
            body: text,
            createdAt: DateTime.now(),
          ),
        );
    _comment.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _edit() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateRequestPage(existing: widget.request),
      ),
    );
    // The detail holds an immutable copy; pop back so the feed reloads fresh.
    if (changed == true && mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir pedido?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await sl<TattooRequestRepository>().deleteRequest(widget.request.id);
    } catch (_) {}
    if (mounted) navigator.pop();
  }

  Future<void> _block() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = widget.request.authorName.isEmpty
        ? 'esse usuário'
        : widget.request.authorName;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bloquear usuário?'),
        content: Text(
          'Você não verá mais posts e comentários de $name no mural.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await sl<BlockRepository>().block(widget.request.authorId);
    } catch (_) {}
    messenger.showSnackBar(
      const SnackBar(content: Text('Usuário bloqueado.')),
    );
    navigator.pop();
  }

  Future<void> _report() async {
    const reasons = [
      'Conteúdo sexual explícito',
      'Conteúdo ofensivo ou ilegal',
      'Spam ou propaganda',
      'Outro',
    ];
    final messenger = ScaffoldMessenger.of(context);
    final reason = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Denunciar pedido',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            for (final r in reasons)
              ListTile(
                title: Text(r),
                onTap: () => Navigator.pop(ctx, r),
              ),
          ],
        ),
      ),
    );
    if (reason == null) return;
    try {
      await sl<TattooRequestRepository>()
          .report('request', widget.request.id, reason);
    } catch (_) {}
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Denúncia enviada. Obrigado — vamos revisar.'),
      ),
    );
  }

  Future<void> _negotiate() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final id = await sl<ChatRepository>().openWithClient(widget.request.authorId);
      navigator.push(
        MaterialPageRoute(
          builder: (_) => ChatPage(
            conversationId: id,
            title: widget.request.authorName.isEmpty
                ? 'Conversa'
                : widget.request.authorName,
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir a conversa.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final user = context.read<AuthCubit>().state.user;
    final canNegotiate = (user?.isArtist ?? false) && user?.id != r.authorId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedido'),
        actions: [
          Builder(
            builder: (context) {
              final isAuthor = user?.id == r.authorId;
              return PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') _edit();
                  if (v == 'delete') _delete();
                  if (v == 'report') _report();
                  if (v == 'block') _block();
                },
                itemBuilder: (_) => isAuthor
                    ? const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir'),
                          ]),
                        ),
                      ]
                    : const [
                        PopupMenuItem(
                          value: 'report',
                          child: Row(children: [
                            Icon(Icons.flag_outlined, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Denunciar'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'block',
                          child: Row(children: [
                            Icon(Icons.block, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Bloquear usuário'),
                          ]),
                        ),
                      ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  r.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'por ${r.authorName.isEmpty ? 'alguém' : r.authorName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ),
                    if (r.authorIsOwner) ...[
                      const SizedBox(width: 6),
                      const OwnerTag(),
                    ],
                    if (r.authorIsArtist) ...[
                      const SizedBox(width: 6),
                      const ArtistTag(),
                    ],
                  ],
                ),
                if (r.imageUrl != null && r.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SensitiveImage(url: r.imageUrl!, sensitive: r.sensitive),
                ],
                if (r.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(r.description, style: const TextStyle(fontSize: 14)),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (r.placement != null && r.placement!.isNotEmpty)
                      Chip(
                        avatar: const Icon(Icons.place_outlined, size: 16),
                        label: Text(r.placement!),
                      ),
                    if (r.budget != null)
                      Chip(
                        avatar: const Icon(Icons.attach_money, size: 16),
                        label: Text('até R\$ ${r.budget!.toStringAsFixed(0)}'),
                      ),
                  ],
                ),
                if (canNegotiate) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _negotiate,
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Negociar'),
                    ),
                  ),
                ],
                const Divider(height: 32),
                const Text(
                  'Comentários',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                BlocBuilder<RequestCommentsCubit, RequestCommentsState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state.items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Seja o primeiro a comentar.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }
                    return Column(
                      children: state.items
                          .map((c) => _CommentTile(comment: c))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _comment,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Comentar...',
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final RequestComment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[200],
            backgroundImage: avatarImage(comment.authorAvatar),
            child: avatarImage(comment.authorAvatar) == null
                ? const Icon(Icons.person, size: 18, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.authorName.isEmpty
                            ? 'Usuário'
                            : comment.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (comment.authorIsOwner) ...[
                      const SizedBox(width: 6),
                      const OwnerTag(),
                    ],
                    if (comment.authorIsArtist) ...[
                      const SizedBox(width: 6),
                      const ArtistTag(),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.body, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
