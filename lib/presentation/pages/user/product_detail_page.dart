import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../widgets/components/product_detail/product_image_header.dart';
import '../../widgets/components/product_detail/product_content.dart';
import '../../widgets/components/product_detail/error_state.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Inicializar controlador de animação
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Carregar dados do produto
    context.read<ProductBloc>().add(GetProductEvent(widget.productId));

    // Iniciar animação
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      HapticFeedback.lightImpact(); // Feedback tátil
      setState(() {
        _quantity--;
      });
    }
  }

  void _incrementQuantity(int stock) {
    if (_quantity < stock) {
      HapticFeedback.lightImpact(); // Feedback tátil
      setState(() {
        _quantity++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Disparar o evento para recarregar produtos ao voltar
        context.read<ProductBloc>().add(GetProductsEvent());
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                // Implementação futura para adicionar aos favoritos
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Adicionado aos favoritos!'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Implementação futura para compartilhar
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Compartilhando produto...'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductsLoading) {
              return _buildLoadingState();
            } else if (state is ProductLoaded) {
              return _buildProductContent(state.product);
            } else if (state is ProductError) {
              return ProductErrorState(
                message: state.message,
                productId: widget.productId,
              );
            } else {
              return const Center(child: Text('Nenhum produto encontrado'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: const CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildProductContent(dynamic product) {
    return Stack(
      children: [
        // Imagem do produto com gradiente
        ProductImageHeader(product: product),

        // Conteúdo deslizante
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.36,
              ),
            ),
            SliverToBoxAdapter(
              child: ProductContent(
                product: product,
                quantity: _quantity,
                slideAnimation: _slideAnimation,
                fadeAnimation: _fadeAnimation,
                onDecrement: _decrementQuantity,
                onIncrement: () => _incrementQuantity(product.stock),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
