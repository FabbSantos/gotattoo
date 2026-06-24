import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/app_notification.dart';
import '../../bloc/notification/notifications_cubit.dart';
import '../../bloc/notification/notifications_state.dart';
import '../artist/artist_bookings_page.dart';
import '../booking/my_bookings_page.dart';
import '../chat/conversations_page.dart';
import '../feed/tattoo_feed_page.dart';

/// Lists the user's booking notifications. Opening the page marks everything as
/// read; tapping a row jumps to the relevant bookings screen.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Mark read shortly after open so the badge clears.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<NotificationsCubit>().markAllRead(),
    );
  }

  void _open(AppNotification n) {
    final Widget dest;
    if (n.type == 'message') {
      dest = const ConversationsPage();
    } else if (n.type == 'request_comment') {
      dest = const TattooFeedPage();
    } else if (n.type == 'payment_charged' || n.type == 'payment_refunded') {
      dest = const MyBookingsPage();
    } else if (n.isForArtist) {
      dest = const ArtistBookingsPage();
    } else {
      dest = const MyBookingsPage();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => dest));
  }

  Future<void> _clearAll() async {
    final cubit = context.read<NotificationsCubit>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar notificações'),
        content: const Text('Apagar todas as notificações? Não dá pra desfazer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirm == true) await cubit.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) => state.items.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'Limpar todas',
                    onPressed: _clearAll,
                  ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 56, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma notificação ainda.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final n = state.items[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    _iconFor(n.type),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(
                  n.title,
                  style: TextStyle(
                    fontWeight: n.read ? FontWeight.w500 : FontWeight.bold,
                  ),
                ),
                subtitle: Text(n.body),
                trailing: Text(
                  _ago(n.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                onTap: () => _open(n),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'booking_requested':
        return Icons.event_available;
      case 'booking_confirmed':
        return Icons.check_circle_outline;
      case 'booking_rejected':
        return Icons.cancel_outlined;
      case 'booking_awaiting':
        return Icons.hourglass_bottom;
      case 'booking_completed':
        return Icons.done_all;
      case 'booking_cancelled':
        return Icons.event_busy;
      case 'message':
        return Icons.chat_bubble_outline;
      case 'request_comment':
        return Icons.lightbulb_outline;
      case 'payment_charged':
        return Icons.payments_outlined;
      case 'payment_refunded':
        return Icons.replay_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _ago(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
