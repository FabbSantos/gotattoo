import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_cubit.dart';
import 'package:gotattoo/presentation/bloc/cart/cart_bloc.dart';
import 'package:gotattoo/presentation/bloc/cart/cart_event.dart';
import 'package:gotattoo/presentation/bloc/orders/orders_cubit.dart';
import 'package:gotattoo/presentation/pages/user/checkout_page.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  Future<void> pumpCheckout(WidgetTester tester, CartBloc cart) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<CartBloc>.value(value: cart),
          // Unauthenticated by default -> _confirm just clears the cart.
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(repository: MockAuthRepository()),
          ),
          BlocProvider<OrdersCubit>(
            create: (_) => OrdersCubit(repository: InMemoryOrderRepository()),
          ),
        ],
        child: const MaterialApp(home: CheckoutPage()),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows only the final total — no fee line for the customer', (
    tester,
  ) async {
    // tProduct.price = 1200, quantity 1 -> customer pays exactly 1200 (the fee
    // is embedded in the price and never shown to the customer).
    final cart = CartBloc(repository: InMemoryCartRepository())
      ..add(const AddToCart(tProduct));

    await pumpCheckout(tester, cart);

    expect(find.text('Total'), findsOneWidget);
    expect(find.textContaining('1200.00'), findsWidgets);
    expect(find.textContaining('Taxa GoTattoo'), findsNothing);
    expect(find.text('Subtotal'), findsNothing);
  });

  testWidgets('the button navigates to the payment screen', (tester) async {
    final cart = CartBloc(repository: InMemoryCartRepository())
      ..add(const AddToCart(tProduct));

    await pumpCheckout(tester, cart);

    await tester.tap(find.textContaining('IR PARA PAGAMENTO'));
    await tester.pumpAndSettle();

    expect(find.text('Forma de pagamento'), findsOneWidget);
  });
}
