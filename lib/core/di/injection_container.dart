import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../cache/cache_store.dart';
import '../config/supabase_config.dart';
import '../services/local_notifications_service.dart';
import '../services/location_service.dart';
import '../services/push_service.dart';
import '../utils/credential_store.dart';
import '../../data/repositories/local_notification_repository.dart';
import '../../data/repositories/supabase_notification_repository.dart';
import '../../data/repositories/local_chat_repository.dart';
import '../../data/repositories/supabase_chat_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../presentation/bloc/notification/notifications_cubit.dart';
import '../../presentation/bloc/chat/conversations_cubit.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../data/repositories/supabase_artist_repository.dart';
import '../../data/repositories/supabase_availability_repository.dart';
import '../../data/repositories/supabase_booking_repository.dart';
import '../../data/repositories/supabase_order_repository.dart';
import '../../data/repositories/supabase_product_repository.dart';
import '../../data/repositories/local_availability_repository.dart';
import '../../data/repositories/local_booking_repository.dart';
import '../../data/repositories/local_category_repository.dart';
import '../../data/repositories/supabase_category_repository.dart';
import '../../data/repositories/local_review_repository.dart';
import '../../data/repositories/supabase_review_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/review_repository.dart';
import '../../presentation/bloc/category/categories_cubit.dart';
import '../../presentation/bloc/review/reviews_cubit.dart';

import '../../data/datasources/artist_local_data_source.dart';
import '../../data/datasources/product_local_data_source.dart';
import '../../data/repositories/artist_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/session_repository_impl.dart';
import '../../domain/repositories/artist_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/availability_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_artists.dart';
import '../../domain/usecases/get_one_artist.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/update_product.dart';
import '../../presentation/bloc/artist/artist_bloc.dart';
import '../../presentation/bloc/booking/availability_cubit.dart';
import '../../presentation/bloc/booking/bookings_cubit.dart';
import '../../presentation/bloc/cart/cart_bloc.dart';
import '../../presentation/bloc/auth/auth_cubit.dart';
import '../../presentation/bloc/orders/orders_cubit.dart';
import '../../presentation/bloc/product/product_bloc.dart';
import '../../presentation/bloc/session/session_cubit.dart';

/// Application service locator.
///
/// This is the composition root: it's the only place that knows how concrete
/// implementations are wired together. The rest of the app depends on
/// abstractions and resolves them from here.
final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // External.
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton(() => CacheStore(sl()));
  sl.registerLazySingleton(() => CredentialStore(sl()));
  sl.registerLazySingleton(() => LocationService());
  sl.registerLazySingleton(() => LocalNotificationsService());
  sl.registerLazySingleton(() => PushService(sl()));

  // Blocs — new instance per injection (UI owns their lifecycle).
  sl.registerFactory(
    () => ProductBloc(
      getProducts: sl(),
      getProduct: sl(),
      addProduct: sl(),
      updateProduct: sl(),
      deleteProduct: sl(),
      cache: sl(),
    ),
  );
  sl.registerFactory(
    () => ArtistBloc(getArtists: sl(), getOneArtist: sl(), cache: sl()),
  );
  sl.registerFactory(() => BookingsCubit(repository: sl()));
  sl.registerFactory(() => AvailabilityCubit(repository: sl()));
  sl.registerLazySingleton(() => CategoriesCubit(repository: sl()));
  sl.registerFactory(() => ReviewsCubit(repository: sl()));

  // Auth, cart and session are shared across screens for the whole session.
  sl.registerLazySingleton(() => AuthCubit(repository: sl()));
  sl.registerLazySingleton(() => CartBloc(repository: sl()));
  sl.registerLazySingleton(() => SessionCubit(repository: sl()));
  sl.registerLazySingleton(() => OrdersCubit(repository: sl()));
  sl.registerLazySingleton(
    () => NotificationsCubit(repository: sl(), localNotifications: sl()),
  );
  sl.registerLazySingleton(
    () => ConversationsCubit(repository: sl(), cache: sl()),
  );

  // Use cases.
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => GetProduct(sl()));
  sl.registerLazySingleton(() => AddProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));
  sl.registerLazySingleton(() => GetArtists(sl()));
  sl.registerLazySingleton(() => GetOneArtist(sl()));

  // Repositories. Cart stays device-local in both modes.
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(prefs: sl()),
  );
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(prefs: sl()),
  );

  if (SupabaseConfig.isConfigured) {
    // Real backend: Supabase Auth + profiles + catalog + orders.
    final client = Supabase.instance.client;
    sl.registerLazySingleton<AuthRepository>(
      () => SupabaseAuthRepository(client),
    );
    sl.registerLazySingleton<ProductRepository>(
      () => SupabaseProductRepository(client),
    );
    sl.registerLazySingleton<ArtistRepository>(
      () => SupabaseArtistRepository(client),
    );
    sl.registerLazySingleton<OrderRepository>(
      () => SupabaseOrderRepository(client),
    );
    sl.registerLazySingleton<BookingRepository>(
      () => SupabaseBookingRepository(client),
    );
    sl.registerLazySingleton<AvailabilityRepository>(
      () => SupabaseAvailabilityRepository(client),
    );
    sl.registerLazySingleton<CategoryRepository>(
      () => SupabaseCategoryRepository(client),
    );
    sl.registerLazySingleton<ReviewRepository>(
      () => SupabaseReviewRepository(client),
    );
    sl.registerLazySingleton<NotificationRepository>(
      () => SupabaseNotificationRepository(client),
    );
    sl.registerLazySingleton<ChatRepository>(
      () => SupabaseChatRepository(client),
    );
  } else {
    // Offline mode: local mock data + auth seeded with demo artist accounts.
    final authRepository = AuthRepositoryImpl(prefs: prefs);
    await authRepository.seedDemoArtistsIfEmpty();
    sl.registerLazySingleton<AuthRepository>(() => authRepository);
    sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(localDataSource: sl()),
    );
    sl.registerLazySingleton<ArtistRepository>(
      () => ArtistRepositoryImpl(localDataSource: sl()),
    );
    sl.registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(prefs: sl()),
    );
    sl.registerLazySingleton<BookingRepository>(
      () => LocalBookingRepository(),
    );
    sl.registerLazySingleton<AvailabilityRepository>(
      () => LocalAvailabilityRepository(),
    );
    sl.registerLazySingleton<CategoryRepository>(
      () => LocalCategoryRepository(),
    );
    sl.registerLazySingleton<ReviewRepository>(
      () => LocalReviewRepository(),
    );
    sl.registerLazySingleton<NotificationRepository>(
      () => LocalNotificationRepository(),
    );
    sl.registerLazySingleton<ChatRepository>(
      () => LocalChatRepository(),
    );
  }

  // Data sources.
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ArtistDataSource>(
    () => ArtistLocalDataSourceImpl(),
  );
}
