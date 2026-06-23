import 'package:equatable/equatable.dart';

import '../../../domain/entities/payout_account.dart';

/// Artist-only session data. The user's role/identity lives in AuthCubit; this
/// holds the payout account the artist registers.
class SessionState extends Equatable {
  final PayoutAccount? payoutAccount;

  const SessionState({this.payoutAccount});

  bool get hasPayoutAccount => payoutAccount != null;

  SessionState copyWith({PayoutAccount? payoutAccount}) {
    return SessionState(payoutAccount: payoutAccount ?? this.payoutAccount);
  }

  @override
  List<Object?> get props => [payoutAccount];
}
