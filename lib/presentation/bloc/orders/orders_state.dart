import 'package:equatable/equatable.dart';

import '../../../domain/entities/order.dart';

class OrdersState extends Equatable {
  final bool loading;
  final List<Order> orders;

  const OrdersState({this.loading = false, this.orders = const []});

  OrdersState copyWith({bool? loading, List<Order>? orders}) {
    return OrdersState(
      loading: loading ?? this.loading,
      orders: orders ?? this.orders,
    );
  }

  @override
  List<Object?> get props => [loading, orders];
}
