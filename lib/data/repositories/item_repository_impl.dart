import 'package:drift/drift.dart';

import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../database/app_database.dart';
import '../models/item_model.dart';

class ItemRepositoryImpl implements ItemRepository {
  final LocalDataSource _localDataSource;

  ItemRepositoryImpl(this._localDataSource);

  @override
  Future<List<ItemEntity>> getItemsByCategory(int categoryId) async {
    final items = await _localDataSource.getItemsByCategory(categoryId);
    return items.map((i) => i.toEntity()).toList();
  }

  @override
  Stream<List<ItemEntity>> watchItemsByCategory(int categoryId) {
    return _localDataSource
        .watchItemsByCategory(categoryId)
        .map((list) => list.map((i) => i.toEntity()).toList());
  }

  @override
  Future<ItemEntity> getItemById(int id) async {
    final item = await _localDataSource.getItemById(id);
    return item.toEntity();
  }

  @override
  Future<List<ItemEntity>> searchItems(String query) async {
    final items = await _localDataSource.searchItems(query);
    return items.map((i) => i.toEntity()).toList();
  }

  @override
  Future<List<ItemEntity>> searchItemsInCategory(
      int categoryId, String query) async {
    final items =
        await _localDataSource.searchItemsInCategory(categoryId, query);
    return items.map((i) => i.toEntity()).toList();
  }

  @override
  Future<int> addItem({
    required int categoryId,
    required String title,
    String? description,
    String? posterPath,
    String? posterUrl,
    String? launchPath,
    String? launchArgs,
    ItemType itemType = ItemType.movie,
    int? year,
    double? rating,
    String? externalId,
    String? metadataJson,
  }) {
    return _localDataSource.insertItem(
      ItemsCompanion(
        categoryId: Value(categoryId),
        title: Value(title),
        description: Value(description),
        posterPath: Value(posterPath),
        posterUrl: Value(posterUrl),
        launchPath: Value(launchPath),
        launchArgs: Value(launchArgs),
        itemType: Value(itemType.toDbString()),
        year: Value(year),
        rating: Value(rating),
        externalId: Value(externalId),
        metadataJson: Value(metadataJson),
      ),
    );
  }

  @override
  Future<void> updateItem(ItemEntity item) {
    return _localDataSource.updateItem(
      ItemsCompanion(
        id: Value(item.id),
        categoryId: Value(item.categoryId),
        title: Value(item.title),
        description: Value(item.description),
        posterPath: Value(item.posterPath),
        posterUrl: Value(item.posterUrl),
        launchPath: Value(item.launchPath),
        launchArgs: Value(item.launchArgs),
        itemType: Value(item.itemType.toDbString()),
        year: Value(item.year),
        rating: Value(item.rating),
        externalId: Value(item.externalId),
        metadataJson: Value(item.metadataJson),
        sortOrder: Value(item.sortOrder),
        isFavorite: Value(item.isFavorite),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteItem(int id) {
    return _localDataSource.deleteItem(id);
  }

  @override
  Future<bool> itemExistsByLaunchPath(String launchPath) async {
    final items = await _localDataSource.getItemsByLaunchPath(launchPath);
    return items.isNotEmpty;
  }
}
