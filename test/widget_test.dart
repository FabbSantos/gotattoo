// Smoke test: the app boots, wires its dependencies and renders the home shell.

import 'package:flutter_test/flutter_test.dart';

import 'package:gotattoo/core/di/injection_container.dart';
import 'package:gotattoo/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/mock_network_image.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    await sl.reset();
    await initDependencies();
  });

  testWidgets('boots into the login screen when no user is signed in', (
    tester,
  ) async {
    await mockNetworkImages(() async {
      await tester.pumpWidget(const MyApp());
      // Let checkAuth resolve (no stored user -> unauthenticated -> login).
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('GoTattoo'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });
  });
}
