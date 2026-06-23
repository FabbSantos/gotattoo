import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/category_repository.dart';

/// Holds the catalog categories (names, without the "Todas" sentinel), loaded
/// from the database so they can change without an app release.
class CategoriesCubit extends Cubit<List<String>> {
  final CategoryRepository repository;

  CategoriesCubit({required this.repository}) : super(const []);

  Future<void> load() async {
    try {
      emit(await repository.getCategories());
    } catch (_) {
      // Keep whatever we have (possibly empty) on failure.
    }
  }
}
