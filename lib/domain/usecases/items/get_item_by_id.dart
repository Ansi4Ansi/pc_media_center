import '../../entities/item.dart';
import '../../repositories/item_repository.dart';

class GetItemById {
  final ItemRepository _repository;

  GetItemById(this._repository);

  Future<ItemEntity> call(int id) => _repository.getItemById(id);
}
