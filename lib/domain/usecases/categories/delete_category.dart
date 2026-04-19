import '../../repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository _repository;

  DeleteCategory(this._repository);

  Future<void> call(int id) => _repository.deleteCategory(id);
}
