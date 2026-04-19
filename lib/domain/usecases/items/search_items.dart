import '../../entities/item.dart';
import '../../repositories/item_repository.dart';

class SearchItems {
  final ItemRepository _repository;

  SearchItems(this._repository);

  Future<List<ItemEntity>> call(String query) =>
      _repository.searchItems(query);

  Future<List<ItemEntity>> inCategory(int categoryId, String query) =>
      _repository.searchItemsInCategory(categoryId, query);
}
