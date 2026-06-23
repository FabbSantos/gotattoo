/// Lifecycle of a tattoo appointment, with mutual completion confirmation.
///
/// pending → confirmed → awaitingConfirmation → completed   (both confirmed; artist paid)
///   (artist approves)   (artist marks done)   (client confirms)
/// pending → rejected                          (artist declined; client refunded)
/// pending/confirmed → cancelled               (cancelled; client refunded)
enum BookingStatus {
  pending,
  confirmed,
  awaitingConfirmation,
  disputed,
  completed,
  rejected,
  cancelled;

  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Aguardando aprovação';
      case BookingStatus.confirmed:
        return 'Confirmado';
      case BookingStatus.awaitingConfirmation:
        return 'Aguardando confirmação de conclusão';
      case BookingStatus.disputed:
        return 'Em disputa';
      case BookingStatus.completed:
        return 'Concluído';
      case BookingStatus.rejected:
        return 'Recusado';
      case BookingStatus.cancelled:
        return 'Cancelado';
    }
  }

  /// User-facing state of the (simulated) escrow payment.
  String get paymentLabel {
    switch (this) {
      case BookingStatus.pending:
      case BookingStatus.confirmed:
      case BookingStatus.awaitingConfirmation:
      case BookingStatus.disputed:
        return 'Pagamento retido';
      case BookingStatus.completed:
        return 'Pago ao tatuador';
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
        return 'Reembolsado';
    }
  }

  /// Not a terminal state (still holds money / needs action).
  bool get isOpen =>
      this == BookingStatus.pending ||
      this == BookingStatus.confirmed ||
      this == BookingStatus.awaitingConfirmation ||
      this == BookingStatus.disputed;

  /// Can still be cancelled (before the artist marks it finished).
  bool get isCancellable =>
      this == BookingStatus.pending || this == BookingStatus.confirmed;

  static BookingStatus fromName(String? name) {
    return BookingStatus.values.firstWhere(
      (s) => s.name == name,
      orElse: () => BookingStatus.pending,
    );
  }
}
