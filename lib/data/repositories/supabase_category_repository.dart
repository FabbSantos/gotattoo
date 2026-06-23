import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../domain/repositories/category_repository.dart';

class SupabaseCategoryRepository implements CategoryRepository {
  final SupabaseClient client;

  SupabaseCategoryRepository(this.client);

  @override
  Future<List<String>> getCategories() async {
    final rows = await client
        .from('categories')
        .select('name')
        .order('sort_order')
        .order('name');
    return rows.map((r) => r['name'] as String).toList();
  }
}
