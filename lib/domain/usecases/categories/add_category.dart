import '../../repositories/category_repository.dart';

class AddCategory {
  final CategoryRepository _repository;

  AddCategory(this._repository);

  Future<int> call({
    required String name,
    String? icon,
    int sortOrder = 0,
    bool isMovieType = false,
    String? scanPaths,
    String? fileExtensions,
  }) {
    return _repository.addCategory(
      name: name,
      icon: icon,
      sortOrder: sortOrder,
      isMovieType: isMovieType,
      scanPaths: scanPaths,
      fileExtensions: fileExtensions,
    );
  }
}
