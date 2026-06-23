import 'package:flutter/material.dart';

import '../../../../domain/entities/booking.dart';
import '../../../../domain/entities/booking_status.dart';

/// Shared appointment card: shows the tattoo, date/time, status + escrow state,
/// and whatever [actions] the caller passes (client vs artist differ).
class BookingCard extends StatelessWidget {
  final Booking booking;
  final String subtitle;
  final List<Widget> actions;

  const BookingCard({
    super.key,
    required this.booking,
    required this.subtitle,
    this.actions = const [],
  });

  Color _statusColor(BuildContext context) {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.awaitingConfirmation:
        return Colors.orange;
      case BookingStatus.disputed:
        return Colors.deepPurple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.pending:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = booking.scheduledAt;
    final dateLabel =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/'
        '${d.year} · ${d.hour.toString().padLeft(2, '0')}h';
    final color = _statusColor(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('R\$ ${booking.price.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(dateLabel, style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  booking.status.paymentLabel,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (final a in actions) ...[a, const SizedBox(width: 8)],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
