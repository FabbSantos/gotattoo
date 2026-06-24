import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/product.dart';
import '../../../bloc/product/product_bloc.dart';
import '../../../bloc/product/product_state.dart';
import '../../user/product_card.dart';
import '../common/native_ad_card.dart';

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

          final products = state.products;
          // Drop one ad into the grid as a regular-looking card (the native ad
          // is styled like a tattoo card), so it's seen mid-feed.
          const adAt = 4; // cell index the ad occupies
          final showAd = products.length > adAt;
          final count = products.length + (showAd ? 1 : 0);

          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.60,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (showAd && index == adAt) return _shell(const NativeAdCard());
                final product =
                    products[showAd && index > adAt ? index - 1 : index];
                return _shell(
                  ProductCard(
                    product: product,
                    onTap: () => onProductTap(product),
                  ),
                );
              },
              childCount: count,
            ),
          );
        }

        return const SliverFillRemaining(
          child: Center(child: Text('Nenhum produto encontrado')),
        );
      },
    );
  }

  /// Card shell (rounded shadow) shared by product cards and the ad cell.
  Widget _shell(Widget child) {
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
      child: child,
    );
  }
}
