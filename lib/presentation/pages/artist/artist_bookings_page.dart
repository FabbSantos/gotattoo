import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/booking_status.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/booking/bookings_cubit.dart';
import '../../bloc/booking/bookings_state.dart';
import '../../widgets/components/booking/booking_card.dart';

/// Appointments addressed to the artist, with approve/reject/finish actions.
class ArtistBookingsPage extends StatelessWidget {
  const ArtistBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final artistId = context.read<AuthCubit>().state.user?.id;
    return BlocProvider(
      create: (_) {
        final cubit = sl<BookingsCubit>();
        if (artistId != null) cubit.loadForArtist(artistId);
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Agendamentos')),
        body: BlocBuilder<BookingsCubit, BookingsState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.bookings.isEmpty) {
              return const Center(child: Text('Nenhum agendamento ainda'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final b = state.bookings[i];
                return BookingCard(
                  booking: b,
                  subtitle: 'Cliente: ${b.clientName}',
                  actions: _actionsFor(context, b),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _actionsFor(BuildContext context, Booking b) {
    final cubit = context.read<BookingsCubit>();
    switch (b.status) {
      case BookingStatus.pending:
        return [
          OutlinedButton(
            onPressed: () => cubit.updateStatus(b.id, BookingStatus.rejected),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Recusar'),
          ),
          FilledButton(
            onPressed: () => cubit.updateStatus(b.id, BookingStatus.confirmed),
            child: const Text('Aprovar'),
          ),
        ];
      case BookingStatus.confirmed:
        return [
          OutlinedButton(
            onPressed: () => cubit.updateStatus(b.id, BookingStatus.cancelled),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => cubit.updateStatus(
              b.id,
              BookingStatus.awaitingConfirmation,
            ),
            child: const Text('Marcar finalizado'),
          ),
        ];
      case BookingStatus.awaitingConfirmation:
        return [
          Text(
            'Aguardando o cliente confirmar',
            style: TextStyle(color: Colors.orange[800], fontSize: 12),
          ),
          TextButton(
            onPressed: () => cubit.updateStatus(b.id, BookingStatus.disputed),
            style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
            child: const Text('Abrir disputa'),
          ),
        ];
      case BookingStatus.disputed:
        return [
          Text(
            'Em disputa — entre em contato com ${b.clientName}',
            style: const TextStyle(color: Colors.deepPurple, fontSize: 12),
          ),
        ];
      case BookingStatus.completed:
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
        return const [];
    }
  }
}
