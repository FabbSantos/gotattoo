import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/services/payment_service.dart';
import '../../../domain/entities/artist_availability.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/booking_status.dart';
import '../../../domain/entities/product.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/booking/availability_cubit.dart';
import '../../bloc/booking/bookings_cubit.dart';

/// Lets the client request an appointment for [product]: pick a date/time
/// within the artist's availability, then send the booking (escrow simulated).
class BookingPage extends StatelessWidget {
  final Product product;

  const BookingPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AvailabilityCubit>()..load(product.artistId),
        ),
        BlocProvider(create: (_) => sl<BookingsCubit>()),
      ],
      child: _BookingView(product: product),
    );
  }
}

class _BookingView extends StatefulWidget {
  final Product product;

  const _BookingView({required this.product});

  @override
  State<_BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<_BookingView> {
  DateTime? _date;
  int? _hour;
  Set<int> _occupied = {};

  Future<void> _pickDate(AvailabilityState avail) async {
    final a = avail.availability;
    if (a == null) return;
    final bookings = context.read<BookingsCubit>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      initialDate: _firstAvailableFrom(now, a.isAvailableOn),
      selectableDayPredicate: a.isAvailableOn,
    );
    if (picked != null) {
      final occupied = await bookings.occupiedHours(
        widget.product.artistId,
        picked,
      );
      if (!mounted) return;
      setState(() {
        _date = picked;
        _hour = null;
        _occupied = occupied;
      });
    }
  }

  /// A start hour is bookable if the whole [start, start+duration) window fits
  /// the artist's hours and doesn't overlap an existing booking.
  bool _isBookable(int start, ArtistAvailability a) {
    final duration = widget.product.durationHours;
    if (start + duration > a.endHour) return false;
    for (var h = start; h < start + duration; h++) {
      if (_occupied.contains(h)) return false;
    }
    return true;
  }

  DateTime _firstAvailableFrom(DateTime from, bool Function(DateTime) ok) {
    var d = from;
    for (var i = 0; i < 14; i++) {
      if (ok(d)) return d;
      d = d.add(const Duration(days: 1));
    }
    return from;
  }

  bool _submitting = false;

  Future<void> _confirm() async {
    final user = context.read<AuthCubit>().state.user;
    if (user == null || _date == null || _hour == null) return;

    final payments = sl<PaymentService>();
    // With Stripe on, spell out the charge up front, then save a card now (no
    // charge); the artist's approval is what actually charges it.
    if (payments.isConfigured) {
      final price =
          widget.product.effectivePrice.toStringAsFixed(2).replaceAll('.', ',');
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirmar agendamento'),
          content: Text(
            'Quando o tatuador aprovar o agendamento, será cobrado '
            'R\$ $price no seu cartão. Se ele recusar ou for cancelado, '
            'você é reembolsado. Deseja agendar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Agendar'),
            ),
          ],
        ),
      );
      if (go != true) return;

      setState(() => _submitting = true);
      final saved = await payments.collectCard();
      if (!mounted) return;
      setState(() => _submitting = false);
      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('É preciso salvar um cartão para agendar.'),
          ),
        );
        return;
      }
    }

    final scheduledAt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _hour!,
    );
    final p = widget.product;
    context.read<BookingsCubit>().create(
      Booking(
        id: '',
        clientId: user.id,
        clientName: user.displayName,
        artistId: p.artistId,
        productId: p.id,
        productName: p.name,
        productImageUrl: p.imageUrl,
        price: p.effectivePrice,
        scheduledAt: scheduledAt,
        durationHours: p.durationHours,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.event_available, color: Colors.green, size: 48),
        title: const Text('Reserva enviada!'),
        content: Text(
          payments.isConfigured
              ? 'Cartão salvo. Você só será cobrado quando o tatuador aprovar a '
                  'data — e o valor é reembolsado se o agendamento for recusado '
                  'ou cancelado.'
              : 'O tatuador vai aprovar a data. O pagamento (valor e forma) é '
                  'combinado direto com ele.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar tatuagem')),
      body: BlocBuilder<AvailabilityCubit, AvailabilityState>(
        builder: (context, avail) {
          if (avail.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final a = avail.availability!;
          final canConfirm = _date != null && _hour != null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  widget.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'R\$ ${widget.product.effectivePrice.toStringAsFixed(2)}',
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _date == null
                      ? 'Escolher data'
                      : '${_date!.day.toString().padLeft(2, '0')}/'
                          '${_date!.month.toString().padLeft(2, '0')}/${_date!.year}',
                ),
                onPressed: () => _pickDate(avail),
              ),
              const SizedBox(height: 20),
              const Text(
                'Horário',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: a.hourSlots.map((h) {
                  final bookable = _date != null && _isBookable(h, a);
                  return ChoiceChip(
                    label: Text('${h.toString().padLeft(2, '0')}h'),
                    selected: _hour == h,
                    onSelected:
                        bookable ? (_) => setState(() => _hour = h) : null,
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _date == null
                      ? 'Escolha a data primeiro.'
                      : 'Sessão de ${widget.product.durationHours}h. Horários '
                          'ocupados ficam desabilitados.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (canConfirm && !_submitting) ? _confirm : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'CONFIRMAR AGENDAMENTO',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
