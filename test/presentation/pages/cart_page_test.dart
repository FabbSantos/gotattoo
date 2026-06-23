import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/presentation/bloc/cart/cart_bloc.dart';
import 'package:gotattoo/presentation/bloc/cart/cart_event.dart';
import 'package:gotattoo/presentation/pages/user/cart_page.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mock_network_image.dart';
import '../../helpers/mocks.dart';

void main() {
  Future<void> pumpCart(WidgetTester tester, CartBloc cart) async {
    await tester.pumpWidget(
      BlocProvider<CartBloc>.value(
        value: cart,
        child: const MaterialApp(home: CartPage()),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the empty state when the cart has no items', (
    tester,
  ) async {
    final cart = CartBloc(repository: InMemoryCartRepository());
    await mockNetworkImages(() async {
      await pumpCart(tester, cart);
      expect(find.text('Seu carrinho está vazio'), findsOneWidget);
    });
  });

  testWidgets('renders cart lines and the total', (tester) async {
    final cart = CartBloc(repository: InMemoryCartRepository())..add(const AddToCart(tProduct, quantity: 2));
    await mockNetworkImages(() async {
      await pumpCart(tester, cart);

      expect(find.text('Dragão Oriental'), findsOneWidget);
      // 1200 * 2 subtotal and total both 2400.00
      expect(find.textContaining('2400.00'), findsWidgets);
      expect(find.text('FINALIZAR COMPRA'), findsOneWidget);
    });
  });

  testWidgets('clearing the cart shows the empty state', (tester) async {
    final cart = CartBloc(repository: InMemoryCartRepository())..add(const AddToCart(tProduct));
    await mockNetworkImages(() async {
      await pumpCart(tester, cart);
      expect(find.text('Dragão Oriental'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(find.text('Seu carrinho está vazio'), findsOneWidget);
    });
  });

  testWidgets('incrementing a line updates its quantity', (tester) async {
    final cart = CartBloc(repository: InMemoryCartRepository())..add(const AddToCart(tProduct));
    await mockNetworkImages(() async {
      await pumpCart(tester, cart);

      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();

      expect(cart.state.items.first.quantity, 2);
    });
  });
}
