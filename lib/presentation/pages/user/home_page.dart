import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../bloc/artist/artist_bloc.dart';
import '../../bloc/artist/artist_event.dart';
import '../../bloc/artist/artist_state.dart';
import '../../widgets/user/product_card.dart';
import '../../widgets/components/persistent_headers/category_header_delegate.dart';
import '../../widgets/components/persistent_headers/artist_header_delegate.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedCategory;
  String? selectedArtistId;
  int _selectedIndex = 0;

  // Adicionar variável para armazenar a localização atual
  String _currentLocation = "Av. Paulista, 1000";

  final List<String> categories = [
    'Todas',
    'Old School',
    'New School',
    'Tribal',
    'Realista',
    'Geométrica',
    'Blackwork',
    'Aquarela',
    'Minimalista',
  ];

  @override
  void initState() {
    super.initState();
    selectedCategory = 'Todas';
    context.read<ProductBloc>().add(GetProductsEvent());
    context.read<ArtistBloc>().add(GetArtistsEvent());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Você pode adicionar navegação entre diferentes telas aqui
    if (index > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navegando para: ${_getPageName(index)}'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getPageName(int index) {
    switch (index) {
      case 0:
        return 'Início';
      case 1:
        return 'Categorias';
      case 2:
        return 'Minha Conta';
      case 3:
        return 'Meus Pedidos';
      default:
        return 'Página Desconhecida';
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.isCurrent == true) {
        context.read<ProductBloc>().add(GetProductsEvent());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _showLocationPicker();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Artistas por perto',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _currentLocation,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementação futura da busca
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navegar para a página do carrinho
            },
          ),
        ],
        elevation: 0,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Sliver persistente para categorias
          SliverPersistentHeader(
            pinned: true,
            delegate: CategoryHeaderDelegate(
              expandedHeight: 140.0,
              collapsedHeight: 60.0,
              expandedWidget: _buildCategoriesSlider(),
              collapsedWidget: _buildCollapsedCategoriesBar(),
            ),
          ),

          // Sliver persistente para artistas
          SliverPersistentHeader(
            pinned: true,
            delegate: ArtistHeaderDelegate(
              expandedHeight: 170.0,
              collapsedHeight: 60.0,
              expandedWidget: _buildArtistsSlider(),
              collapsedWidget: _buildCollapsedArtistsBar(),
            ),
          ),

          // Sliver para a grade de produtos
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductsLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is ProductsLoaded) {
                  final filteredProducts =
                      selectedCategory == 'Todas'
                          ? state.products
                          : state.products
                              .where((p) => p.category == selectedCategory)
                              .toList();

                  if (filteredProducts.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Nenhuma tatuagem encontrada na categoria $selectedCategory',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.60,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = filteredProducts[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProductDetailPage(
                                      productId: product.id,
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    }, childCount: filteredProducts.length),
                  );
                } else if (state is ProductError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Erro ao carregar produtos: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                return const SliverFillRemaining(
                  child: Center(child: Text('Nenhum produto encontrado')),
                );
              },
            ),
          ),
        ],
      ),
      // Adiciona a barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Minha Conta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Pedidos',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // Importante para 4+ itens
        onTap: _onItemTapped,
        elevation: 8,
      ),
    );
  }

  Widget _buildCategoriesSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 6),
            child: Text(
              'Categorias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).scaffoldBackgroundColor,
                                Theme.of(
                                  context,
                                ).scaffoldBackgroundColor.withOpacity(0.95),
                              ],
                              stops: const [0.0, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _getCategoryIcon(category),
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistsSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 6),
            child: Text(
              'Tatuadores',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ArtistBloc, ArtistState>(
              builder: (context, state) {
                if (state is ArtistsLoading) {
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                } else if (state is ArtistsLoaded) {
                  final artists = state.artists;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: artists.length,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final artist = artists[index];
                      final isSelected = artist.id == selectedArtistId;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact(); // Feedback tátil
                          setState(() {
                            selectedArtistId = isSelected ? null : artist.id;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 80,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? Theme.of(context).primaryColor
                                                : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: NetworkImage(
                                        artist.imageUrl,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              spreadRadius: 1,
                                              blurRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                artist.name.split(
                                  ' ',
                                )[0], // Apenas o primeiro nome
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color:
                                      isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    artist.rating.toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is ArtistError) {
                  return Center(
                    child: Text(
                      'Erro: ${state.message}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'Nenhum artista encontrado',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedCategoriesBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 1.0, end: 1.03),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Text(
              'Categoria:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(width: 12),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.9, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(selectedCategory ?? 'Todas'),
                    color: Theme.of(context).primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    selectedCategory ?? 'Todas',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).primaryColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              // Aqui você pode abrir um modal de seleção de categoria
              _showCategoryPicker();
            },
            icon: Icon(Icons.filter_list, size: 16),
            label: Text('Filtrar'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Adicione animações sutis para o header de artistas colapsado
  Widget _buildCollapsedArtistsBar() {
    return BlocBuilder<ArtistBloc, ArtistState>(
      builder: (context, state) {
        String artistName = "Nenhum";
        Widget artistAvatar = CircleAvatar(
          backgroundColor: Colors.grey[200],
          radius: 16,
          child: Icon(Icons.person, size: 16, color: Colors.grey),
        );

        if (state is ArtistsLoaded && selectedArtistId != null) {
          // Verificar se o artista existe na lista
          final artistExists = state.artists.any(
            (artist) => artist.id == selectedArtistId,
          );

          if (artistExists) {
            final selectedArtist = state.artists.firstWhere(
              (artist) => artist.id == selectedArtistId,
            );

            artistName = selectedArtist.name.split(' ')[0];
            artistAvatar = CircleAvatar(
              backgroundImage: NetworkImage(selectedArtist.imageUrl),
              radius: 16,
            );
          } else {
            selectedArtistId = null;
          }
        }

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Text(
                  'Tatuador:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.9, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        selectedArtistId != null
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          selectedArtistId != null
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Adicione uma animação sutil para o avatar do artista selecionado
                      selectedArtistId != null
                          ? TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.9, end: 1.0),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: artistAvatar,
                          )
                          : artistAvatar,
                      const SizedBox(width: 6),
                      Text(
                        artistName,
                        style: TextStyle(
                          color:
                              selectedArtistId != null
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_drop_down,
                        color:
                            selectedArtistId != null
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.9, end: 1.0),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: TextButton.icon(
                  onPressed: () {
                    // Aqui você pode abrir um modal de seleção de artista
                    _showArtistPicker();
                  },
                  icon: Icon(Icons.people, size: 16),
                  label: Text('Escolher'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Selecione uma categoria',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;

                    return ListTile(
                      leading: Icon(
                        _getCategoryIcon(category),
                        color:
                            isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                      ),
                      title: Text(category),
                      trailing:
                          isSelected
                              ? Icon(
                                Icons.check,
                                color: Theme.of(context).primaryColor,
                              )
                              : null,
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showArtistPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Selecione um tatuador',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              BlocBuilder<ArtistBloc, ArtistState>(
                builder: (context, state) {
                  if (state is ArtistsLoaded) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount:
                            state.artists.length +
                            1, // +1 para a opção "Nenhum"
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Opção "Nenhum"
                            final isSelected = selectedArtistId == null;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                child: Icon(
                                  Icons.person_off,
                                  color: Colors.grey,
                                ),
                              ),
                              title: Text('Nenhum'),
                              trailing:
                                  isSelected
                                      ? Icon(
                                        Icons.check,
                                        color: Theme.of(context).primaryColor,
                                      )
                                      : null,
                              onTap: () {
                                setState(() {
                                  selectedArtistId = null;
                                });
                                Navigator.pop(context);
                              },
                            );
                          }

                          final artist = state.artists[index - 1];
                          final isSelected = artist.id == selectedArtistId;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(artist.imageUrl),
                            ),
                            title: Text(artist.name),
                            subtitle: Text(artist.specialty),
                            trailing:
                                isSelected
                                    ? Icon(
                                      Icons.check,
                                      color: Theme.of(context).primaryColor,
                                    )
                                    : null,
                            onTap: () {
                              setState(() {
                                selectedArtistId = artist.id;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Todas':
        return Icons.apps;
      case 'Old School':
        return Icons.anchor;
      case 'New School':
        return Icons.palette;
      case 'Tribal':
        return Icons.architecture;
      case 'Realista':
        return Icons.face;
      case 'Geométrica':
        return Icons.shape_line;
      case 'Blackwork':
        return Icons.texture;
      case 'Aquarela':
        return Icons.water_drop;
      case 'Minimalista':
        return Icons.minimize;
      default:
        return Icons.category;
    }
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho fixo
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Selecionar localização',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Campo de busca fixo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar endereço...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Conteúdo scrollável
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Localização atual
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentLocation = "Localização atual (GPS)";
                          });
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.my_location,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Usar localização atual',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Permitir acesso à sua localização',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Divider(),

                      // Endereços recentes/salvos
                      Text(
                        'Endereços salvos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Lista de endereços
                      _buildAddressItem(
                        'Casa',
                        'Rua das Flores, 123 - Jardim Primavera',
                        Icons.home,
                      ),
                      _buildAddressItem(
                        'Trabalho',
                        'Av. Paulista, 1000 - Bela Vista',
                        Icons.work,
                      ),
                      _buildAddressItem(
                        'Academia',
                        'Rua dos Esportes, 45 - Centro',
                        Icons.fitness_center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressItem(String label, String address, IconData icon) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentLocation = address;
        });
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.grey[700]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    address,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
