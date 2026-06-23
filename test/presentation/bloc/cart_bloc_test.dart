import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/domain/entities/cart_item.dart';
import 'package:gotattoo/presentation/bloc/cart/cart_bloc.dart';
import 'package:gotattoo/presentation/bloc/cart/cart_event.dart';
import 'package:gotattoo/presentation/bloc/cart/cart_state.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

CartBloc makeCart() => CartBloc(repository: InMemoryCartRepository());

void main() {
  test('initial state is an empty cart', () {
    final state = makeCart().state;
    expect(state.isEmpty, isTrue);
    expect(state.totalItems, 0);
    expect(state.totalPrice, 0);
  });

  blocTest<CartBloc, CartState>(
    'LoadCart restores the persisted items',
    build: () => CartBloc(
      repository: InMemoryCartRepository([
        const CartItem(product: tProduct, quantity: 3),
      ]),
    ),
    act: (bloc) => bloc.add(const LoadCart()),
    expect: () => [
      const CartState(items: [CartItem(product: tProduct, quantity: 3)]),
    ],
  );

  blocTest<CartBloc, CartState>(
    'AddToCart adds a new line',
    build: makeCart,
    act: (bloc) => bloc.add(const AddToCart(tProduct, quantity: 2)),
    expect: () => [
      const CartState(items: [CartItem(product: tProduct, quantity: 2)]),
    ],
  );

  blocTest<CartBloc, CartState>(
    'AddToCart merges quantity for an existing product',
    build: makeCart,
    act: (bloc) => bloc
      ..add(const AddToCart(tProduct, quantity: 1))
      ..add(const AddToCart(tProduct, quantity: 3)),
    skip: 1,
    expect: () => [
      const CartState(items: [CartItem(product: tProduct, quantity: 4)]),
    ],
  );

  blocTest<CartBloc, CartState>(
    'IncrementCartItem raises the quantity',
    build: makeCart,
    seed: () =>
        const CartState(items: [CartItem(product: tProduct, quantity: 1)]),
    act: (bloc) => bloc.add(const IncrementCartItem('1')),
    expect: () => [
      const CartState(items: [CartItem(product: tProduct, quantity: 2)]),
    ],
  );

  blocTest<CartBloc, CartState>(
    'DecrementCartItem drops the line when it reaches zero',
    build: makeCart,
    seed: () =>
        const CartState(items: [CartItem(product: tProduct, quantity: 1)]),
    act: (bloc) => bloc.add(const DecrementCartItem('1')),
    expect: () => [const CartState(items: [])],
  );

  blocTest<CartBloc, CartState>(
    'RemoveFromCart removes only the matching product',
    build: makeCart,
    seed: () => const CartState(
      items: [
        CartItem(product: tProduct, quantity: 1),
        CartItem(product: tProductMinimalist, quantity: 2),
      ],
    ),
    act: (bloc) => bloc.add(const RemoveFromCart('1')),
    expect: () => [
      const CartState(
        items: [CartItem(product: tProductMinimalist, quantity: 2)],
      ),
    ],
  );

  blocTest<CartBloc, CartState>(
    'ClearCart empties everything',
    build: makeCart,
    seed: () =>
        const CartState(items: [CartItem(product: tProduct, quantity: 5)]),
    act: (bloc) => bloc.add(const ClearCart()),
    expect: () => [const CartState(items: [])],
  );

  test('totals aggregate quantity and price across lines', () {
    const state = CartState(
      items: [
        CartItem(product: tProduct, quantity: 2), // 1200 * 2
        CartItem(product: tProductMinimalist, quantity: 1), // 350 * 1
      ],
    );
    expect(state.totalItems, 3);
    expect(state.totalPrice, 2750.0);
  });
}
