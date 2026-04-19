import 'package:drift/drift.dart';

import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../database/app_database.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final LocalDataSource _localDataSource;

  CategoryRepositoryImpl(this._localDataSource);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final categories = await _localDataSource.getAllCategories();
    return categories.map((c) => c.toEntity()).toList();
  }

  @override
  Stream<List<CategoryEntity>> watchCategories() {
    return _localDataSource
        .watchAllCategories()
        .map((list) => list.map((c) => c.toEntity()).toList());
  }

  @override
  Future<CategoryEntity> getCategoryById(int id) async {
    final category = await _localDataSource.getCategoryById(id);
    return category.toEntity();
  }

  @override
  Future<int> addCategory({
    required String name,
    String? icon,
    int sortOrder = 0,
    bool isMovieType = false,
    String? scanPaths,
    String? fileExtensions,
  }) {
    return _localDataSource.insertCategory(
      CategoriesCompanion(
        name: Value(name),
        icon: Value(icon),
        sortOrder: Value(sortOrder),
        isMovieType: Value(isMovieType),
        scanPaths: Value(scanPaths),
        fileExtensions: Value(fileExtensions),
      ),
    );
  }

  @override
  Future<void> updateCategory(CategoryEntity category) {
    return _localDataSource.updateCategory(
      CategoriesCompanion(
        id: Value(category.id),
        name: Value(category.name),
        icon: Value(category.icon),
        sortOrder: Value(category.sortOrder),
        isMovieType: Value(category.isMovieType),
        scanPaths: Value(category.scanPaths),
        fileExtensions: Value(category.fileExtensions),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteCategory(int id) {
    return _localDataSource.deleteCategory(id);
  }
}
