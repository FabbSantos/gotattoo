import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/order.dart';
import '../../../domain/repositories/order_repository.dart';
import 'orders_state.dart';

/// Lists a user's order history and records new orders at checkout.
class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository repository;

  OrdersCubit({required this.repository}) : super(const OrdersState());

  Future<void> load(String userId) async {
    emit(state.copyWith(loading: true));
    final orders = await repository.ordersFor(userId);
    emit(OrdersState(loading: false, orders: orders));
  }

  /// Loads the artist's sales (orders containing their tattoos).
  Future<void> loadSales(String artistId) async {
    emit(state.copyWith(loading: true));
    final orders = await repository.salesFor(artistId);
    emit(OrdersState(loading: false, orders: orders));
  }

  Future<void> place(Order order) async {
    await repository.placeOrder(order);
    final orders = await repository.ordersFor(order.userId);
    emit(OrdersState(loading: false, orders: orders));
  }
}
