import '../../core/constants/tattoo_categories.dart';
import '../../domain/repositories/category_repository.dart';

/// Offline fallback: the built-in category list (minus the "all" sentinel).
class LocalCategoryRepository implements CategoryRepository {
  @override
  Future<List<String>> getCategories() async => TattooCategories.values
      .where((c) => c != TattooCategories.all)
      .toList();
}
