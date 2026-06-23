/// Source of the tattoo categories. Backed by the database so categories can
/// be added/removed without releasing a new app version.
abstract class CategoryRepository {
  /// Category names (without the "Todas"/all sentinel).
  Future<List<String>> getCategories();
}
