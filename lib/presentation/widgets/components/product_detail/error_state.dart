import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/product/product_bloc.dart';
import '../../../bloc/product/product_event.dart';

class ProductErrorState extends StatelessWidget {
  final String message;
  final String productId;

  const ProductErrorState({
    super.key,
    required this.message,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar produto: $message',
            style: TextStyle(color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<ProductBloc>().add(GetProductEvent(productId));
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
