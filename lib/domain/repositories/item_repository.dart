import '../entities/item.dart';

abstract class ItemRepository {
  Future<List<ItemEntity>> getItemsByCategory(int categoryId);
  Stream<List<ItemEntity>> watchItemsByCategory(int categoryId);
  Future<ItemEntity> getItemById(int id);
  Future<List<ItemEntity>> searchItems(String query);
  Future<List<ItemEntity>> searchItemsInCategory(int categoryId, String query);
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
  });
  Future<void> updateItem(ItemEntity item);
  Future<void> deleteItem(int id);
  Future<bool> itemExistsByLaunchPath(String launchPath);
}
