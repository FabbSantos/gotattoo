import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/payout_account.dart';
import '../../../domain/repositories/session_repository.dart';
import 'session_state.dart';

/// Owns the artist's payout account, persisted via [SessionRepository].
class SessionCubit extends Cubit<SessionState> {
  final SessionRepository repository;

  SessionCubit({required this.repository}) : super(const SessionState());

  Future<void> load() async {
    final payout = await repository.getPayoutAccount();
    emit(SessionState(payoutAccount: payout));
  }

  Future<void> savePayoutAccount(PayoutAccount account) async {
    await repository.savePayoutAccount(account);
    emit(state.copyWith(payoutAccount: account));
  }
}
