import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gotattoo/presentation/bloc/artist/artist_bloc.dart';
import 'package:gotattoo/presentation/bloc/artist/artist_event.dart';
import 'package:gotattoo/presentation/bloc/artist/artist_state.dart';
import 'package:gotattoo/presentation/bloc/product/product_bloc.dart';
import 'package:gotattoo/presentation/bloc/product/product_event.dart';
import 'package:gotattoo/presentation/bloc/product/product_state.dart';
import 'package:gotattoo/domain/entities/cart_item.dart';
import 'package:gotattoo/domain/entities/order.dart';
import 'package:gotattoo/domain/entities/payout_account.dart';
import 'package:gotattoo/domain/repositories/auth_repository.dart';
import 'package:gotattoo/domain/repositories/cart_repository.dart';
import 'package:gotattoo/domain/repositories/order_repository.dart';
import 'package:gotattoo/domain/repositories/session_repository.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_cubit.dart';
import 'package:gotattoo/presentation/bloc/auth/auth_state.dart';
import 'package:gotattoo/presentation/bloc/orders/orders_cubit.dart';
import 'package:gotattoo/presentation/bloc/orders/orders_state.dart';
import 'package:gotattoo/presentation/bloc/category/categories_cubit.dart';
import 'package:gotattoo/data/datasources/artist_local_data_source.dart';
import 'package:gotattoo/data/datasources/product_local_data_source.dart';
import 'package:gotattoo/domain/repositories/artist_repository.dart';
import 'package:gotattoo/domain/repositories/product_repository.dart';
import 'package:gotattoo/domain/usecases/add_product.dart';
import 'package:gotattoo/domain/usecases/delete_product.dart';
import 'package:gotattoo/domain/usecases/get_artists.dart';
import 'package:gotattoo/domain/usecases/get_one_artist.dart';
import 'package:gotattoo/domain/usecases/get_product.dart';
import 'package:gotattoo/domain/usecases/get_products.dart';
import 'package:gotattoo/domain/usecases/update_product.dart';

// Data sources
class MockProductLocalDataSource extends Mock
    implements ProductLocalDataSource {}

class MockArtistDataSource extends Mock implements ArtistDataSource {}

// Repositories
class MockProductRepository extends Mock implements ProductRepository {}

class MockArtistRepository extends Mock implements ArtistRepository {}

// Use cases
class MockGetProducts extends Mock implements GetProducts {}

class MockGetProduct extends Mock implements GetProduct {}

class MockAddProduct extends Mock implements AddProduct {}

class MockUpdateProduct extends Mock implements UpdateProduct {}

class MockDeleteProduct extends Mock implements DeleteProduct {}

class MockGetArtists extends Mock implements GetArtists {}

class MockGetOneArtist extends Mock implements GetOneArtist {}

/// In-memory cart persistence for tests (no shared_preferences needed).
class InMemoryCartRepository implements CartRepository {
  List<CartItem> _items;

  InMemoryCartRepository([this._items = const []]);

  @override
  Future<List<CartItem>> load() async => _items;

  @override
  Future<void> save(List<CartItem> items) async => _items = items;
}

/// In-memory session persistence for tests (artist payout account only).
class InMemorySessionRepository implements SessionRepository {
  PayoutAccount? _payout;

  InMemorySessionRepository({PayoutAccount? payout}) : _payout = payout;

  @override
  Future<PayoutAccount?> getPayoutAccount() async => _payout;

  @override
  Future<void> savePayoutAccount(PayoutAccount account) async =>
      _payout = account;
}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

/// In-memory order persistence for tests.
class InMemoryOrderRepository implements OrderRepository {
  final List<Order> _orders;

  InMemoryOrderRepository([List<Order>? seed]) : _orders = [...?seed];

  @override
  Future<List<Order>> ordersFor(String userId) async {
    final list = _orders.where((o) => o.userId == userId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<Order>> salesFor(String artistId) async {
    final list = _orders
        .where((o) => o.items.any((i) => i.product.artistId == artistId))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> placeOrder(Order order) async => _orders.add(order);
}

// Blocs / cubits (for widget tests)
class MockProductBloc extends MockBloc<ProductEvent, ProductState>
    implements ProductBloc {}

class MockArtistBloc extends MockBloc<ArtistEvent, ArtistState>
    implements ArtistBloc {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockOrdersCubit extends MockCubit<OrdersState> implements OrdersCubit {}

class MockCategoriesCubit extends MockCubit<List<String>>
    implements CategoriesCubit {}

