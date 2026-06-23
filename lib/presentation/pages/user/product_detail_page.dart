import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/entities/product.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../widgets/components/product_detail/error_state.dart';
import '../../widgets/components/product_detail/product_content.dart';
import '../../widgets/components/product_detail/product_image_header.dart';
import '../artist/artist_profile_page.dart';
import '../booking/booking_page.dart';

/// Detail page. It owns a dedicated [ProductBloc] so loading a single product
/// never clobbers the catalog state held by the home page's bloc.
class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductBloc>()..add(GetProductEvent(productId)),
      child: _ProductDetailView(productId: productId),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  final String productId;

  const _ProductDetailView({required this.productId});

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      HapticFeedback.lightImpact();
      setState(() => _quantity--);
    }
  }

  void _incrementQuantity(int stock) {
    if (_quantity < stock) {
      HapticFeedback.lightImpact();
      setState(() => _quantity++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => _showSnack('Adicionado aos favoritos!'),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showSnack('Compartilhando produto...'),
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoaded) {
            return _buildProductContent(state.product);
          } else if (state is ProductError) {
            return ProductErrorState(
              message: state.message,
              productId: widget.productId,
            );
          } else if (state is ProductsLoading || state is ProductInitial) {
            return _buildLoadingState();
          }
          return const Center(child: Text('Nenhum produto encontrado'));
        },
      ),
    );
  }

  void _showSnack(String message) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _book(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookingPage(product: product)),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: TweenAnimationBuilder<double>(
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

  Widget _buildProductContent(Product product) {
    return Stack(
      children: [
        ProductImageHeader(product: product),
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
                onBook: () => _book(product),
                onViewArtist: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ArtistProfilePage(artistId: product.artistId),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
