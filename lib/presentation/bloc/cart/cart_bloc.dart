import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/cart_item.dart';
import '../../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

/// Holds the shopping cart. Registered as a singleton so it is shared across
/// screens, and persisted via [CartRepository] so it survives app restarts.
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;

  CartBloc({required this.repository}) : super(const CartState()) {
    on<LoadCart>(_onLoad);
    on<AddToCart>(_onAdd);
    on<RemoveFromCart>(_onRemove);
    on<IncrementCartItem>(_onIncrement);
    on<DecrementCartItem>(_onDecrement);
    on<ClearCart>(_onClear);
  }

  Future<void> _onLoad(LoadCart event, Emitter<CartState> emit) async {
    final items = await repository.load();
    emit(state.copyWith(items: items));
  }

  void _onAdd(AddToCart event, Emitter<CartState> emit) {
    final items = [...state.items];
    final index = items.indexWhere((i) => i.product.id == event.product.id);
    if (index == -1) {
      items.add(CartItem(product: event.product, quantity: event.quantity));
    } else {
      final merged = items[index].quantity + event.quantity;
      items[index] = items[index].copyWith(quantity: merged);
    }
    _emitAndPersist(emit, items);
  }

  void _onRemove(RemoveFromCart event, Emitter<CartState> emit) {
    final items = state.items
        .where((i) => i.product.id != event.productId)
        .toList();
    _emitAndPersist(emit, items);
  }

  void _onIncrement(IncrementCartItem event, Emitter<CartState> emit) {
    final items = state.items.map((i) {
      if (i.product.id != event.productId) return i;
      return i.copyWith(quantity: i.quantity + 1);
    }).toList();
    _emitAndPersist(emit, items);
  }

  void _onDecrement(DecrementCartItem event, Emitter<CartState> emit) {
    final items = <CartItem>[];
    for (final i in state.items) {
      if (i.product.id != event.productId) {
        items.add(i);
      } else if (i.quantity > 1) {
        items.add(i.copyWith(quantity: i.quantity - 1));
      }
      // quantity == 1 and decremented -> drop the line.
    }
    _emitAndPersist(emit, items);
  }

  void _onClear(ClearCart event, Emitter<CartState> emit) {
    _emitAndPersist(emit, const []);
  }

  void _emitAndPersist(Emitter<CartState> emit, List<CartItem> items) {
    emit(state.copyWith(items: items));
    repository.save(items); // fire-and-forget persistence
  }
}
