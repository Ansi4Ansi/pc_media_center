import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Future<List<Category>> getAllCategories() =>
      (select(categories)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Stream<List<Category>> watchAllCategories() =>
      (select(categories)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  Future<Category> getCategoryById(int id) =>
      (select(categories)..where((t) => t.id.equals(id))).getSingle();

  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  Future<bool> updateCategory(CategoriesCompanion category) =>
      update(categories).replace(category);

  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((t) => t.id.equals(id))).go();
}
