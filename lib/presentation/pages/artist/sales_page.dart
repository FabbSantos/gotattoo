import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/platform_fee.dart';
import '../../../domain/entities/order.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/orders/orders_cubit.dart';
import '../../bloc/orders/orders_state.dart';

/// The artist's sales: orders that include their tattoos, with the net amount
/// (after the platform fee) they earned from each.
class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late final String? _artistId;

  @override
  void initState() {
    super.initState();
    final id = context.read<AuthCubit>().state.user?.id;
    _artistId = id;
    if (id != null) {
      context.read<OrdersCubit>().loadSales(id);
    }
  }

  /// Net the artist earned from [order] (only their items, minus the fee).
  double _netFrom(Order order) {
    final gross = order.items
        .where((i) => i.product.artistId == _artistId)
        .fold<double>(0, (sum, i) => sum + i.subtotal);
    return PlatformFee.artistPayout(gross);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Vendas')),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.orders.isEmpty) {
            return const Center(child: Text('Você ainda não vendeu tatuagens'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = state.orders[index];
              final mine = order.items
                  .where((i) => i.product.artistId == _artistId)
                  .toList();
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Venda em ${_date(order)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '+ R\$ ${_netFrom(order).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...mine.map(
                        (i) => Text(
                          '${i.quantity}x ${i.product.name}',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _date(Order order) {
    final d = order.createdAt;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
