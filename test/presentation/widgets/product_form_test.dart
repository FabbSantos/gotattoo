import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/domain/entities/product.dart';
import 'package:gotattoo/presentation/widgets/admin/product_form.dart';

const _cats = ['Tribal', 'Old School', 'Realista'];

void main() {
  Widget host(Widget child) =>
      MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

  testWidgets('does not submit when required fields are empty', (tester) async {
    Product? submitted;
    await tester.pumpWidget(
      host(ProductForm(categories: _cats, onSubmit: (p) => submitted = p)),
    );

    await tester.ensureVisible(find.text('Adicionar Produto'));
    await tester.tap(find.text('Adicionar Produto'));
    await tester.pump();

    expect(submitted, isNull);
    expect(find.text('Por favor, insira o nome do produto'), findsOneWidget);
  });

  testWidgets('submits a Product when the form is valid', (tester) async {
    Product? submitted;
    await tester.pumpWidget(
      host(ProductForm(categories: _cats, onSubmit: (p) => submitted = p)),
    );

    // TextFormField order: name, description, price, discount, imageUrl,
    // stock, duration, artistId (category is a dropdown).
    await tester.enterText(find.byType(TextFormField).at(0), 'Nova Tattoo');
    await tester.enterText(find.byType(TextFormField).at(1), 'Descrição');
    await tester.enterText(find.byType(TextFormField).at(2), '199.90');
    await tester.enterText(find.byType(TextFormField).at(3), '10'); // discount
    await tester.enterText(
      find.byType(TextFormField).at(4),
      'https://example.com/x.png',
    );
    await tester.enterText(find.byType(TextFormField).at(5), '7'); // stock
    await tester.enterText(find.byType(TextFormField).at(6), '3'); // duration
    await tester.enterText(find.byType(TextFormField).at(7), '2'); // artistId

    // Pick the category from the dropdown.
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tribal').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Adicionar Produto'));
    await tester.tap(find.text('Adicionar Produto'));
    await tester.pump();

    expect(submitted, isNotNull);
    expect(submitted!.name, 'Nova Tattoo');
    expect(submitted!.price, 199.90);
    expect(submitted!.stock, 7);
    expect(submitted!.category, 'Tribal');
    expect(submitted!.artistId, '2');
    expect(submitted!.discountPercent, 10);
    expect(submitted!.durationHours, 3);
  });

  testWidgets('shows update label when editing an existing product', (
    tester,
  ) async {
    const existing = Product(
      id: '1',
      name: 'Existente',
      description: 'd',
      price: 10,
      imageUrl: 'https://example.com/x.png',
      stock: 1,
      category: 'Tribal',
      artistId: '1',
    );

    await tester.pumpWidget(
      host(ProductForm(
        product: existing,
        categories: _cats,
        onSubmit: (_) {},
      )),
    );

    expect(find.text('Atualizar Produto'), findsOneWidget);
    expect(find.text('Existente'), findsOneWidget);
  });
}
