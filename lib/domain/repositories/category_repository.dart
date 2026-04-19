import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories();
  Stream<List<CategoryEntity>> watchCategories();
  Future<CategoryEntity> getCategoryById(int id);
  Future<int> addCategory({
    required String name,
    String? icon,
    int sortOrder = 0,
    bool isMovieType = false,
    String? scanPaths,
    String? fileExtensions,
  });
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(int id);
}
