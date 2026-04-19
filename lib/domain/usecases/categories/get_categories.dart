import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

class GetCategories {
  final CategoryRepository _repository;

  GetCategories(this._repository);

  Future<List<CategoryEntity>> call() => _repository.getCategories();

  Stream<List<CategoryEntity>> watch() => _repository.watchCategories();
}
