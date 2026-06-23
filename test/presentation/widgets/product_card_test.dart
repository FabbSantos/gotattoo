import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/presentation/widgets/user/product_card.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mock_network_image.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders name, description, category and price', (tester) async {
    await mockNetworkImages(() async {
      await tester.pumpWidget(
        host(ProductCard(product: tProduct, onTap: () {})),
      );
      await tester.pump();

      expect(find.text('Dragão Oriental'), findsOneWidget);
      expect(find.text('Old School'), findsOneWidget);
      expect(find.textContaining('1200.00'), findsOneWidget);
    });
  });

  testWidgets('invokes onTap when tapped', (tester) async {
    var tapped = false;
    await mockNetworkImages(() async {
      await tester.pumpWidget(
        host(ProductCard(product: tProduct, onTap: () => tapped = true)),
      );
      await tester.pump();

      await tester.tap(find.byType(ProductCard));
      await tester.pump();
    });

    expect(tapped, isTrue);
  });
}
