import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/utils/avatar_image.dart';
import '../../../domain/entities/auth_user.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/components/common/owner_tag.dart';
import '../artist/artist_dashboard_page.dart';
import '../artist/artist_profile_page.dart';
import '../artist/pending_artists_page.dart';
import '../booking/my_bookings_page.dart';
import '../support/support_inbox_page.dart';
import '../support/support_thread_page.dart';
import 'blocked_users_page.dart';
import 'edit_profile_page.dart';
import 'payment_methods_page.dart';
import 'privacy_policy_page.dart';

/// Profile hub: shows the signed-in user and links to their areas.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Conta')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;
          return ListView(
            children: [
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final avatar = avatarImage(user?.avatarPath);
                  return Center(
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      backgroundImage: avatar,
                      child: avatar == null
                          ? Icon(
                              Icons.person,
                              size: 36,
                              color: Theme.of(context).primaryColor,
                            )
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user?.displayName ?? 'Visitante',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user?.isOwner ?? false) ...[
                      const SizedBox(width: 8),
                      const OwnerTag(),
                    ],
                  ],
                ),
              ),
              if (user != null)
                Center(
                  child: Text(
                    '${user.email} · ${user.role.label}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              if (user?.isArtistPending ?? false)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_top, color: Color(0xFFB8860B)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Seu cadastro de tatuador está em análise. '
                          'Você será avisado quando for aprovado.',
                          style: TextStyle(color: Colors.grey[800], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              if (user != null &&
                  !user.isArtist &&
                  user.artistStatus == 'rejected')
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              user.rejectReason.isEmpty
                                  ? 'Seu pedido de tatuador não foi aprovado.'
                                  : 'Pedido recusado: ${user.rejectReason}',
                              style: TextStyle(
                                  color: Colors.grey[800], fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _requestArtist(context, user),
                          child: const Text('Tentar de novo'),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              if (user != null &&
                  !user.isArtist &&
                  user.artistStatus == 'none')
                ListTile(
                  leading: const Icon(Icons.brush_outlined),
                  title: const Text('Quero ser tatuador'),
                  subtitle: const Text('Cadastre seu portfólio pra análise'),
                  onTap: () => _requestArtist(context, user),
                ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar Perfil'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.event_note),
                title: const Text('Meus Agendamentos'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyBookingsPage()),
                ),
              ),
              if (sl<PaymentService>().isConfigured)
                ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: const Text('Formas de pagamento'),
                  subtitle: const Text('Gerencie seus cartões salvos'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentMethodsPage(),
                    ),
                  ),
                ),
              if (user?.isArtist ?? false) ...[
                ListTile(
                  leading: const Icon(Icons.dashboard_customize),
                  title: const Text('Área do Tatuador'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ArtistDashboardPage(),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Meu perfil público'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArtistProfilePage(artistId: user!.id),
                    ),
                  ),
                ),
              ],
              if (user?.isOwner ?? false) ...[
                ListTile(
                  leading: const Icon(Icons.how_to_reg_outlined),
                  title: const Text('Pedidos de tatuador'),
                  subtitle: const Text('Aprovar quem quer ser tatuador'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PendingArtistsPage(),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.forum_outlined),
                  title: const Text('Mural de suporte'),
                  subtitle: const Text('Mensagens dos usuários'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SupportInboxPage(),
                    ),
                  ),
                ),
              ],
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: const Text('Convidar tatuadores'),
                subtitle: const Text('Chame tatuadores e amigos pro app'),
                onTap: _invite,
              ),
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Avaliar o app'),
                subtitle: const Text('Curtindo? Deixe uma nota na loja 💜'),
                onTap: _rate,
              ),
              if (user != null)
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Ajuda e suporte'),
                  subtitle: const Text('Fale com a gente pelo app'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SupportThreadPage(
                        threadUserId: user.id,
                        asOwner: false,
                        title: 'Ajuda e suporte',
                      ),
                    ),
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: const Text('Usuários bloqueados'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BlockedUsersPage(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Política de privacidade'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyPage(),
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sair', style: TextStyle(color: Colors.red)),
                onTap: () => context.read<AuthCubit>().logout(),
              ),
              if (user != null)
                ListTile(
                  leading: Icon(Icons.delete_forever_outlined,
                      color: Colors.grey[600]),
                  title: Text(
                    'Excluir minha conta',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () => _deleteAccount(context),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _requestArtist(BuildContext context, AuthUser user) async {
    final controller = TextEditingController(text: user.portfolio);
    final cubit = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quero ser tatuador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cole o link do seu portfólio (Instagram, site...). '
              'O GoTattoo analisa e te aprova.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: 'Link do portfólio',
                prefixIcon: Icon(Icons.link),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (controller.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Informe o link do seu portfólio.')),
      );
      return;
    }
    await cubit.requestArtist(controller.text.trim());
    messenger.showSnackBar(
      const SnackBar(content: Text('Pedido enviado! Você será avisado.')),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final cubit = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir minha conta'),
        content: const Text(
          'Isso apaga permanentemente sua conta e todos os seus dados '
          '(perfil, posts, comentários, mensagens e agendamentos). '
          'Não dá pra desfazer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await cubit.deleteAccount();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Não foi possível excluir agora. Tente de novo.'),
        ),
      );
    }
  }

  Future<void> _invite() async {
    await Share.share(
      'Tô no GoTattoo — pra achar tatuador, ver trabalhos e agendar. '
      'Vem também! E se você é tatuador, crie sua conta e mostre seu '
      'trabalho pra galera. 💉',
      subject: 'Vem pro GoTattoo',
    );
  }

  Future<void> _rate() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    } else {
      await review.openStoreListing();
    }
  }

}
