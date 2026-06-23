import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/presentation/bloc/session/session_cubit.dart';
import 'package:gotattoo/presentation/pages/artist/payout_account_page.dart';

import '../../helpers/mocks.dart';

void main() {
  late SessionCubit session;

  setUp(() => session = SessionCubit(repository: InMemorySessionRepository()));

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<SessionCubit>.value(
        value: session,
        child: const MaterialApp(home: PayoutAccountPage()),
      ),
    );
    await tester.pump();
  }

  testWidgets('validates an empty PayPal email', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Salvar conta'));
    await tester.pump();

    expect(find.text('Informe o e-mail do PayPal'), findsOneWidget);
    expect(session.state.hasPayoutAccount, isFalse);
  });

  testWidgets('saves a valid payout account', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextFormField), 'artist@paypal.com');
    await tester.tap(find.text('Salvar conta'));
    await tester.pump();

    expect(session.state.hasPayoutAccount, isTrue);
    expect(session.state.payoutAccount!.identifier, 'artist@paypal.com');
    expect(session.state.payoutAccount!.provider, 'PayPal');
  });
}
