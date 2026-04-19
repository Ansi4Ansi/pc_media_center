import '../../repositories/item_repository.dart';

class DeleteItem {
  final ItemRepository _repository;

  DeleteItem(this._repository);

  Future<void> call(int id) => _repository.deleteItem(id);
}
