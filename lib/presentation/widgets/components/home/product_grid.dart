import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/product.dart';
import '../../../bloc/product/product_bloc.dart';
import '../../../bloc/product/product_state.dart';
import '../../user/product_card.dart';

/// Sliver grid bound to [ProductBloc]. Filtering already happens in the bloc,
/// so this widget only renders whatever [ProductsLoaded] exposes.
class ProductGrid extends StatelessWidget {
  final ValueChanged<Product> onProductTap;

  const ProductGrid({super.key, required this.onProductTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductsLoading || state is ProductInitial) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProductError) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'Erro ao carregar produtos: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (state is ProductsLoaded) {
          if (state.products.isEmpty) {
            final byArtist = state.selectedArtistId != null
                ? ' deste tatuador'
                : '';
            final byCategory =
                state.selectedCategory != 'Todas'
                    ? ' na categoria ${state.selectedCategory}'
                    : '';
            return SliverFillRemaining(
              child: Center(
                child: Text(
                  'Nenhuma tatuagem encontrada$byCategory$byArtist',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.60,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = state.products[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ProductCard(
                  product: product,
                  onTap: () => onProductTap(product),
                ),
              );
            }, childCount: state.products.length),
          );
        }

        return const SliverFillRemaining(
          child: Center(child: Text('Nenhum produto encontrado')),
        );
      },
    );
  }
}
