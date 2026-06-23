import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/domain/entities/payout_account.dart';
import 'package:gotattoo/presentation/bloc/session/session_cubit.dart';
import 'package:gotattoo/presentation/bloc/session/session_state.dart';

import '../../helpers/mocks.dart';

void main() {
  test('starts with no payout account', () {
    final cubit = SessionCubit(repository: InMemorySessionRepository());
    expect(cubit.state.hasPayoutAccount, isFalse);
  });

  blocTest<SessionCubit, SessionState>(
    'load restores the persisted payout account',
    build: () => SessionCubit(
      repository: InMemorySessionRepository(
        payout: const PayoutAccount(provider: 'PayPal', identifier: 'a@b.com'),
      ),
    ),
    act: (cubit) => cubit.load(),
    expect: () => [
      const SessionState(
        payoutAccount: PayoutAccount(provider: 'PayPal', identifier: 'a@b.com'),
      ),
    ],
  );

  blocTest<SessionCubit, SessionState>(
    'savePayoutAccount stores the account',
    build: () => SessionCubit(repository: InMemorySessionRepository()),
    act: (cubit) => cubit.savePayoutAccount(
      const PayoutAccount(provider: 'PayPal', identifier: 'x@y.com'),
    ),
    expect: () => [
      const SessionState(
        payoutAccount: PayoutAccount(provider: 'PayPal', identifier: 'x@y.com'),
      ),
    ],
  );
}
