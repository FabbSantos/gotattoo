import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/datasources/artist_local_data_source.dart';
import 'data/datasources/product_local_data_source.dart';
import 'data/repositories/artist_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/artist_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/usecases/get_artists.dart';
import 'domain/usecases/get_one_artist.dart';
import 'domain/usecases/get_products.dart';
import 'presentation/bloc/artist/artist_bloc.dart';
import 'presentation/bloc/product/product_bloc.dart';
import 'presentation/pages/user/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar data sources
    final ProductLocalDataSource productLocalDataSource =
        ProductLocalDataSourceImpl();
    final ArtistDataSource artistLocalDataSource = ArtistLocalDataSourceImpl();

    // Inicializar repositories
    final ProductRepository productRepository = ProductRepositoryImpl(
      localDataSource: productLocalDataSource,
    );
    final ArtistRepository artistRepository = ArtistRepositoryImpl(
      localDataSource: artistLocalDataSource,
    );

    // Inicializar use cases
    final getProductsUseCase = GetProducts(productRepository);
    final getArtistsUseCase = GetArtists(artistRepository);
    final getOneArtistUseCase = GetOneArtist(artistRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create:
              (context) => ProductBloc(
                repository: productRepository,
                getProducts: getProductsUseCase,
              ),
        ),
        BlocProvider<ArtistBloc>(
          create:
              (context) => ArtistBloc(
                repository: artistRepository,
                getArtists: getArtistsUseCase,
                getOneArtist: getOneArtistUseCase,
              ),
        ),
      ],
      child: MaterialApp(
        title: 'Marketplace',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}
