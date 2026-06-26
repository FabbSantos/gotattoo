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
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nenhuma tatuagem encontrada$byCategory$byArtist',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    // Still surface an ad so the screen isn't fully empty.
                    SizedBox(
                      width: 190,
                      child: AspectRatio(
                        aspectRatio: 0.62,
                        child: _shell(const NativeAdCard()),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = state.products;
          // Sprinkle a native ad (styled like a tattoo card) every few cells,
          // so the grid stays mostly content. `null` marks an ad slot.
          const adEvery = 6;
          final display = <Product?>[];
          for (var i = 0; i < products.length; i++) {
            display.add(products[i]);
            if ((i + 1) % adEvery == 0 && i != products.length - 1) {
              display.add(null);
            }
          }

          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.60,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = display[index];
                if (product == null) return _shell(const NativeAdCard());
                return _shell(
                  ProductCard(
                    product: product,
                    onTap: () => onProductTap(product),
                  ),
                );
              },
              childCount: display.length,
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
