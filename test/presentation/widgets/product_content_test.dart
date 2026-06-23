import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/presentation/widgets/components/product_detail/product_content.dart';

import '../../helpers/fixtures.dart';

void main() {
  testWidgets('the book button invokes onBook', (tester) async {
    var booked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductContent(
              product: tProduct,
              quantity: 1,
              slideAnimation: const AlwaysStoppedAnimation(Offset.zero),
              fadeAnimation: const AlwaysStoppedAnimation(1.0),
              onDecrement: () {},
              onIncrement: () {},
              onBook: () => booked = true,
              onViewArtist: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('AGENDAR'));
    await tester.pump();

    expect(booked, isTrue);
  });
}
