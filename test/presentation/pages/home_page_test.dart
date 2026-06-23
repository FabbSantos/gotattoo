import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/services/local_notifications_service.dart';
import 'package:gotattoo/data/repositories/local_chat_repository.dart';
import 'package:gotattoo/data/repositories/local_notification_repository.dart';
import 'package:gotattoo/presentation/bloc/artist/artist_bloc.dart';
import 'package:gotattoo/presentation/bloc/artist/artist_state.dart';
import 'package:gotattoo/presentation/bloc/category/categories_cubit.dart';
import 'package:gotattoo/presentation/bloc/chat/conversations_cubit.dart';
import 'package:gotattoo/presentation/bloc/notification/notifications_cubit.dart';
import 'package:gotattoo/presentation/bloc/product/product_bloc.dart';
import 'package:gotattoo/presentation/bloc/product/product_event.dart';
import 'package:gotattoo/presentation/bloc/product/product_state.dart';
import 'package:gotattoo/presentation/pages/user/home_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mock_network_image.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockProductBloc productBloc;
  late MockArtistBloc artistBloc;
  late MockCategoriesCubit categoriesCubit;

  final catalog = [tProduct, tProductMinimalist];

  setUpAll(() {
    registerFallbackValue(const GetProductsEvent());
    registerFallbackValue(const FilterProductsByCategoryEvent('Todas'));
  });

  setUp(() {
    productBloc = MockProductBloc();
    artistBloc = MockArtistBloc();
    whenListen(
      productBloc,
      const Stream<ProductState>.empty(),
      initialState: ProductsLoaded(catalog, selectedCategory: 'Todas'),
    );
    whenListen(
      artistBloc,
      const Stream<ArtistState>.empty(),
      initialState: const ArtistsLoaded([tArtist]),
    );
    categoriesCubit = MockCategoriesCubit();
    whenListen(
      categoriesCubit,
      const Stream<List<String>>.empty(),
      initialState: const ['Old School', 'Tribal', 'Realista'],
    );
  });

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ProductBloc>.value(value: productBloc),
          BlocProvider<ArtistBloc>.value(value: artistBloc),
          BlocProvider<CategoriesCubit>.value(value: categoriesCubit),
          BlocProvider<NotificationsCubit>(
            create: (_) => NotificationsCubit(
              repository: LocalNotificationRepository(),
              localNotifications: LocalNotificationsService(),
            ),
          ),
          BlocProvider<ConversationsCubit>(
            create: (_) => ConversationsCubit(repository: LocalChatRepository()),
          ),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders the loaded catalog and the artist section', (
    tester,
  ) async {
    await mockNetworkImages(() async {
      await pumpHome(tester);

      expect(find.text('Dragão Oriental'), findsOneWidget);
      expect(find.text('Linhas Minimalistas'), findsOneWidget);
      expect(find.text('Tatuadores'), findsOneWidget);
      expect(find.text('João'), findsOneWidget); // first name only
    });
  });

  testWidgets('tapping a category dispatches FilterProductsByCategoryEvent', (
    tester,
  ) async {
    await mockNetworkImages(() async {
      await pumpHome(tester);

      await tester.tap(find.text('Tribal'));
      await tester.pump();
    });

    verify(
      () => productBloc.add(const FilterProductsByCategoryEvent('Tribal')),
    ).called(1);
  });

  testWidgets('shows empty message when the filtered list is empty', (
    tester,
  ) async {
    whenListen(
      productBloc,
      const Stream<ProductState>.empty(),
      initialState: const ProductsLoaded([], selectedCategory: 'Aquarela'),
    );

    await mockNetworkImages(() async {
      await pumpHome(tester);

      expect(
        find.textContaining('Nenhuma tatuagem encontrada'),
        findsOneWidget,
      );
    });
  });
}
