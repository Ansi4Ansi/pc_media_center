import '../../entities/item.dart';
import '../../repositories/item_repository.dart';

class UpdateItem {
  final ItemRepository _repository;

  UpdateItem(this._repository);

  Future<void> call(ItemEntity item) => _repository.updateItem(item);
}
