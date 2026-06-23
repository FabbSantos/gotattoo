import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/tattoo_categories.dart';
import '../../../core/route_observer.dart';
import '../../bloc/artist/artist_bloc.dart';
import '../../bloc/artist/artist_event.dart';
import '../../bloc/category/categories_cubit.dart';
import '../../bloc/chat/conversations_cubit.dart';
import '../../bloc/notification/notifications_cubit.dart';
import '../../bloc/notification/notifications_state.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../booking/my_bookings_page.dart';
import '../chat/conversations_page.dart';
import '../notifications/notifications_page.dart';
import '../../widgets/components/home/artist_picker_sheet.dart';
import '../../widgets/components/home/artist_selector.dart';
import '../../widgets/components/home/category_picker_sheet.dart';
import '../../widgets/components/home/category_selector.dart';
import '../../widgets/components/home/collapsed_artist_bar.dart';
import '../../widgets/components/home/collapsed_category_bar.dart';
import '../../widgets/components/home/location_picker_sheet.dart';
import '../../widgets/components/home/product_grid.dart';
import '../../widgets/components/persistent_headers/collapsing_header_delegate.dart';
import 'account_page.dart';
import 'product_detail_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  String _selectedCategory = TattooCategories.all;
  String? _selectedArtistId;
  int _selectedIndex = 0;
  String _currentLocation = 'Rio de Janeiro';

  /// Client coordinates from GPS/address; null means "show all artists".
  double? _clientLat;
  double? _clientLng;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) appRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Returned to the home — refresh the catalog/artists so edits made in the
    // artist area show up without restarting the app.
    context.read<ProductBloc>().add(
      GetProductsEvent(category: _selectedCategory),
    );
    context.read<ArtistBloc>().add(const GetArtistsEvent());
    context.read<ConversationsCubit>().refresh();
  }

  void _selectCategory(String category) {
    setState(() => _selectedCategory = category);
    context.read<ProductBloc>().add(FilterProductsByCategoryEvent(category));
  }

  void _selectArtist(String? artistId) {
    setState(() => _selectedArtistId = artistId);
    context.read<ProductBloc>().add(FilterProductsByArtistEvent(artistId));
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 1: // Categorias
        _showCategoryPicker();
        break;
      case 2: // Minha Conta
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AccountPage()),
        );
        break;
      case 3: // Agendamentos
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyBookingsPage()),
        );
        break;
      default: // Início
        setState(() => _selectedIndex = 0);
    }
  }

  void _openProduct(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(productId: productId),
      ),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      TattooCategories.all,
      ...context.watch<CategoriesCubit>().state,
    ];
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap:
              () => LocationPickerSheet.show(
                context,
                onSelected: (place) => setState(() {
                  _currentLocation = place.label;
                  _clientLat = place.lat;
                  _clientLng = place.lng;
                }),
              ),
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
          IconButton(icon: const Icon(Icons.search), onPressed: _openSearch),
          const _MessagesIcon(),
          const _NotificationsBell(),
        ],
        elevation: 0,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: CollapsingHeaderDelegate(
              expandedHeight: 142.0,
              collapsedHeight: 54.0,
              expandedWidget: ArtistSelector(
                selectedArtistId: _selectedArtistId,
                clientLat: _clientLat,
                clientLng: _clientLng,
                onSelected: _selectArtist,
              ),
              collapsedWidget: CollapsedArtistBar(
                selectedArtistId: _selectedArtistId,
                onChooseTap: _showArtistPicker,
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: CollapsingHeaderDelegate(
              expandedHeight: 88.0,
              collapsedHeight: 54.0,
              expandedWidget: CategorySelector(
                selectedCategory: _selectedCategory,
                categories: categories,
                onSelected: _selectCategory,
              ),
              collapsedWidget: CollapsedCategoryBar(
                selectedCategory: _selectedCategory,
                onFilterTap: _showCategoryPicker,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: ProductGrid(
              onProductTap: (product) => _openProduct(product.id),
            ),
          ),
        ],
      ),
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
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        elevation: 8,
      ),
    );
  }

  void _showCategoryPicker() {
    CategoryPickerSheet.show(
      context,
      selectedCategory: _selectedCategory,
      categories: [
        TattooCategories.all,
        ...context.read<CategoriesCubit>().state,
      ],
      onSelected: _selectCategory,
    );
  }

  void _showArtistPicker() {
    ArtistPickerSheet.show(
      context,
      selectedArtistId: _selectedArtistId,
      onSelected: _selectArtist,
    );
  }
}

/// Chat icon with an unread badge that opens the conversations list.
class _MessagesIcon extends StatelessWidget {
  const _MessagesIcon();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationsCubit, ConversationsState>(
      builder: (context, state) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.forum_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConversationsPage()),
              ),
            ),
            if (state.totalUnread > 0)
              Positioned(
                top: 8,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    state.totalUnread > 9 ? '9+' : '${state.totalUnread}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Bell icon with an unread badge that opens the notifications list.
class _NotificationsBell extends StatelessWidget {
  const _NotificationsBell();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              ),
            ),
            if (state.unread > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    state.unread > 9 ? '9+' : '${state.unread}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
