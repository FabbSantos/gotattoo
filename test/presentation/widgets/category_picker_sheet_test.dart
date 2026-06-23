import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/presentation/widgets/components/home/category_picker_sheet.dart';

void main() {
  testWidgets('lists categories and returns the tapped one', (tester) async {
    String? picked;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => CategoryPickerSheet.show(
                context,
                selectedCategory: 'Todas',
                categories: const ['Todas', 'Realista', 'Tribal'],
                onSelected: (c) => picked = c,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Selecione uma categoria'), findsOneWidget);
    expect(find.text('Realista'), findsOneWidget);

    await tester.tap(find.text('Realista'));
    await tester.pumpAndSettle();

    expect(picked, 'Realista');
  });
}
