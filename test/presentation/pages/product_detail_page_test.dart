import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/di/injection_container.dart';
import 'package:gotattoo/presentation/bloc/product/product_bloc.dart';
import 'package:gotattoo/presentation/bloc/product/product_state.dart';
import 'package:gotattoo/presentation/pages/user/product_detail_page.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mock_network_image.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockProductBloc productBloc;

  setUp(() async {
    productBloc = MockProductBloc();
    // ProductDetailPage resolves its own bloc from the service locator.
    await sl.reset();
    sl.registerFactory<ProductBloc>(() => productBloc);
  });

  tearDown(() async => sl.reset());

  Future<void> pumpDetail(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProductDetailPage(productId: '1')),
    );
    await tester.pump();
  }

  testWidgets('renders product content when ProductLoaded', (tester) async {
    whenListen(
      productBloc,
      const Stream<ProductState>.empty(),
      initialState: const ProductLoaded(tProduct),
    );

    await mockNetworkImages(() async {
      await pumpDetail(tester);

      expect(find.text('Dragão Oriental'), findsOneWidget);
      expect(find.text('Descrição'), findsOneWidget);
      expect(find.textContaining('1200.00'), findsOneWidget);
    });
  });

  testWidgets('renders the error state when ProductError', (tester) async {
    whenListen(
      productBloc,
      const Stream<ProductState>.empty(),
      initialState: const ProductError('falha ao carregar'),
    );

    await mockNetworkImages(() async {
      await pumpDetail(tester);

      expect(find.textContaining('falha ao carregar'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });
  });

  testWidgets('shows a loader while loading', (tester) async {
    whenListen(
      productBloc,
      const Stream<ProductState>.empty(),
      initialState: const ProductsLoading(),
    );

    await mockNetworkImages(() async {
      await pumpDetail(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
