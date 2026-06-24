import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/utils/avatar_image.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/components/common/owner_tag.dart';
import '../artist/artist_dashboard_page.dart';
import '../artist/artist_profile_page.dart';
import '../artist/pending_artists_page.dart';
import '../booking/my_bookings_page.dart';
import 'edit_profile_page.dart';
import 'payment_methods_page.dart';

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
              const SizedBox(height: 24),
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
              if (user?.isOwner ?? false)
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
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sair', style: TextStyle(color: Colors.red)),
                onTap: () => context.read<AuthCubit>().logout(),
              ),
            ],
          );
        },
      ),
    );
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
