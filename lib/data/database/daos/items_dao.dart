import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/items_table.dart';

part 'items_dao.g.dart';

@DriftAccessor(tables: [Items])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(super.db);

  Future<List<Item>> getItemsByCategory(int categoryId) =>
      (select(items)
            ..where((t) => t.categoryId.equals(categoryId))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Stream<List<Item>> watchItemsByCategory(int categoryId) =>
      (select(items)
            ..where((t) => t.categoryId.equals(categoryId))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  Future<Item> getItemById(int id) =>
      (select(items)..where((t) => t.id.equals(id))).getSingle();

  Future<List<Item>> searchItems(String query) =>
      (select(items)..where((t) => t.title.like('%$query%'))).get();

  Future<List<Item>> searchItemsInCategory(int categoryId, String query) =>
      (select(items)
            ..where(
                (t) => t.categoryId.equals(categoryId) & t.title.like('%$query%')))
          .get();

  Future<int> insertItem(ItemsCompanion item) => into(items).insert(item);

  Future<bool> updateItem(ItemsCompanion item) =>
      update(items).replace(item);

  Future<int> deleteItem(int id) =>
      (delete(items)..where((t) => t.id.equals(id))).go();

  Future<List<Item>> getItemsByLaunchPath(String launchPath) =>
      (select(items)..where((t) => t.launchPath.equals(launchPath))).get();
}
