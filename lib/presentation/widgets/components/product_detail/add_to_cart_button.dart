import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/product.dart';

class AddToCartButton extends StatelessWidget {
  final Product product;
  final int quantity;

  const AddToCartButton({
    super.key,
    required this.product,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} adicionado ao carrinho!'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'VER CARRINHO',
                onPressed: () {
                  // Implementação futura: navegar para o carrinho
                },
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 8,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'ADICIONAR AO CARRINHO',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
