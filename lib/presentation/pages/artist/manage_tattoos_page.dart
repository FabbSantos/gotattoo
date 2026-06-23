import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/entities/product.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/category/categories_cubit.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../widgets/admin/product_form.dart';

/// Artist-facing CRUD over the tattoo catalog. Uses its own scoped
/// [ProductBloc] and the existing Add/Update/Delete use cases.
class ManageTattoosPage extends StatelessWidget {
  const ManageTattoosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final artistId = context.read<AuthCubit>().state.user?.id;
    return BlocProvider(
      create: (_) =>
          sl<ProductBloc>()..add(GetProductsEvent(artistId: artistId)),
      child: _ManageTattoosView(artistId: artistId),
    );
  }
}

class _ManageTattoosView extends StatelessWidget {
  final String? artistId;

  const _ManageTattoosView({this.artistId});

  void _openForm(BuildContext context, {Product? product}) {
    final bloc = context.read<ProductBloc>();
    final categories = context.read<CategoriesCubit>().state;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: ProductForm(
              product: product,
              artistId: artistId,
              categories: categories,
              onSubmit: (result) {
                bloc.add(
                  product == null
                      ? AddProductEvent(result)
                      : UpdateProductEvent(result),
                );
                Navigator.pop(sheetContext);
              },
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    final bloc = context.read<ProductBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover tatuagem'),
        content: Text('Remover "${product.name}" do catálogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              bloc.add(DeleteProductEvent(product.id));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Tatuagens')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova'),
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Catálogo atualizado!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<ProductBloc>().add(
              GetProductsEvent(artistId: artistId),
            );
          } else if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return const Center(child: Text('Nenhuma tatuagem cadastrada'));
            }
            return ListView.separated(
              itemCount: state.products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = state.products[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    '${product.category} · R\$ ${product.price.toStringAsFixed(2)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openForm(context, product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, product),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
