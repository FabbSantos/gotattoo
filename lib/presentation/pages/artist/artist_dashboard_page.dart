import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../bloc/session/session_cubit.dart';
import '../../bloc/session/session_state.dart';
import '../user/edit_profile_page.dart';
import 'artist_bookings_page.dart';
import 'artist_location_page.dart';
import 'artist_profile_page.dart';
import 'availability_page.dart';
import 'manage_tattoos_page.dart';
import 'payout_account_page.dart';

/// Home for the artist experience: estimated earnings, manage tattoos and the
/// payout account.
class ArtistDashboardPage extends StatelessWidget {
  const ArtistDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final artistId = context.read<AuthCubit>().state.user?.id;
    return BlocProvider(
      create: (_) =>
          sl<ProductBloc>()..add(GetProductsEvent(artistId: artistId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Área do Tatuador')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _OnboardingChecklist(artistId: artistId),
            const _RevenueSummary(),
            const SizedBox(height: 16),
            // Builder gives a context under the BlocProvider, so we can refresh
            // the estimated-revenue list when returning from managing tattoos.
            Builder(
              builder: (ctx) => _DashboardCard(
                icon: Icons.brush,
                title: 'Minhas Tatuagens',
                subtitle: 'Cadastre, edite e remova seus desenhos',
                onTap: () async {
                  await Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => const ManageTattoosPage(),
                    ),
                  );
                  if (ctx.mounted) {
                    ctx.read<ProductBloc>().add(
                      GetProductsEvent(artistId: artistId),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            _DashboardCard(
              icon: Icons.event_note,
              title: 'Agendamentos',
              subtitle: 'Aprove, recuse e finalize seus atendimentos',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArtistBookingsPage()),
              ),
            ),
            const SizedBox(height: 12),
            if (artistId != null)
              _DashboardCard(
                icon: Icons.badge_outlined,
                title: 'Meu perfil público',
                subtitle: 'Veja como os clientes te veem (e suas avaliações)',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArtistProfilePage(artistId: artistId),
                  ),
                ),
              ),
            if (artistId != null) const SizedBox(height: 12),
            _DashboardCard(
              icon: Icons.schedule,
              title: 'Disponibilidade',
              subtitle: 'Defina os dias e horários que você atende',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AvailabilityPage()),
              ),
            ),
            const SizedBox(height: 12),
            _DashboardCard(
              icon: Icons.location_on,
              title: 'Minha localização',
              subtitle: 'Apareça no filtro "tatuadores por perto"',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArtistLocationPage()),
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<SessionCubit, SessionState>(
              builder: (context, state) {
                return _DashboardCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Conta de Recebimento',
                  subtitle: state.hasPayoutAccount
                      ? 'PayPal: ${state.payoutAccount!.identifier}'
                      : 'Cadastre como você quer receber',
                  trailing: state.hasPayoutAccount
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.warning_amber, color: Colors.orange),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PayoutAccountPage(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'O app é gratuito e você fica com 100% do valor — o '
                      'pagamento é combinado direto com o cliente.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estimated earnings card: the gross total the artist would make if every
/// listed tattoo sold once (the artist keeps 100% — payment is P2P).
class _RevenueSummary extends StatelessWidget {
  const _RevenueSummary();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final loaded = state is ProductsLoaded;
        final tattoos = loaded ? state.products : const [];
        final gross = tattoos.fold<double>(0, (sum, p) => sum + p.price);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Faturamento estimado',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              if (!loaded)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                )
              else
                Text(
                  'R\$ ${gross.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 8),
              if (loaded)
                Text(
                  '${tattoos.length} tatuagens · você fica com 100%',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Step-by-step shown to a freshly approved artist until their profile is set
/// up (photo, location, first tattoo). Disappears once all three are done.
class _OnboardingChecklist extends StatelessWidget {
  final String? artistId;

  const _OnboardingChecklist({this.artistId});

  Future<void> _open(
    BuildContext context,
    Widget page, {
    bool refreshProducts = false,
  }) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (refreshProducts && context.mounted) {
      context.read<ProductBloc>().add(GetProductsEvent(artistId: artistId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, auth) {
        final user = auth.user;
        final hasPhoto = (user?.avatarPath ?? '').isNotEmpty;
        final hasLocation = user?.hasLocation ?? false;
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, prod) {
            // Wait for products to load before judging the tattoo step.
            if (prod is! ProductsLoaded) return const SizedBox.shrink();
            final hasTattoo = prod.products.isNotEmpty;
            if (hasPhoto && hasLocation && hasTattoo) {
              return const SizedBox.shrink();
            }
            final done = [hasPhoto, hasLocation, hasTattoo]
                .where((b) => b)
                .length;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🚀', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Comece por aqui',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Text('$done/3',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Deixe seu perfil pronto pros clientes te acharem.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  _step(context, 'Adicione uma foto de perfil', hasPhoto,
                      () => _open(context, const EditProfilePage())),
                  _step(context, 'Defina sua localização', hasLocation,
                      () => _open(context, const ArtistLocationPage())),
                  _step(
                    context,
                    'Cadastre sua primeira tatuagem',
                    hasTattoo,
                    () => _open(context, const ManageTattoosPage(),
                        refreshProducts: true),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _step(
    BuildContext context,
    String label,
    bool done,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: done ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? Colors.green : Theme.of(context).primaryColor,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  decoration: done ? TextDecoration.lineThrough : null,
                  color: done ? Colors.grey[500] : Colors.black87,
                ),
              ),
            ),
            if (!done) Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
