import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/services/payment_service.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/booking_status.dart';
import '../../../domain/entities/review.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/booking/bookings_cubit.dart';
import '../../bloc/booking/bookings_state.dart';
import '../../bloc/review/reviews_cubit.dart';
import '../../widgets/components/booking/booking_card.dart';
import '../../widgets/components/review/review_dialog.dart';

/// The client's appointments.
class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = sl<BookingsCubit>();
            if (userId != null) cubit.loadForClient(userId);
            return cubit;
          },
        ),
        BlocProvider(create: (_) => sl<ReviewsCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Meus Agendamentos')),
        body: BlocBuilder<BookingsCubit, BookingsState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.bookings.isEmpty) {
              return const Center(child: Text('Você ainda não agendou nada'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final b = state.bookings[i];
                return BookingCard(
                  booking: b,
                  subtitle: b.productName,
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
    if (b.status == BookingStatus.awaitingConfirmation ||
        b.status == BookingStatus.disputed) {
      return [
        FilledButton(
          onPressed: () =>
              cubit.updateStatus(b.id, BookingStatus.completed),
          child: const Text('Confirmar conclusão'),
        ),
      ];
    }
    if (b.status.isCancellable) {
      return [
        OutlinedButton(
          onPressed: () async {
            // Refund if it was already charged (no-op otherwise).
            await sl<PaymentService>().refundBooking(b.id);
            await cubit.updateStatus(b.id, BookingStatus.cancelled);
          },
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Cancelar'),
        ),
      ];
    }
    if (b.status == BookingStatus.completed) {
      return [
        OutlinedButton.icon(
          icon: const Icon(Icons.star_border, size: 18),
          label: const Text('Avaliar'),
          onPressed: () => _review(context, b),
        ),
      ];
    }
    return const [];
  }

  void _review(BuildContext context, Booking b) {
    final reviews = context.read<ReviewsCubit>();
    final user = context.read<AuthCubit>().state.user;
    showReviewDialog(
      context,
      onSubmit: (rating, comment) {
        reviews.add(
          Review(
            id: '',
            artistId: b.artistId,
            clientId: user?.id ?? '',
            clientName: user?.displayName ?? '',
            rating: rating,
            comment: comment,
            createdAt: DateTime.now(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avaliação enviada! Obrigado.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}
