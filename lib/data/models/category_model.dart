import '../../domain/entities/category.dart';
import '../database/app_database.dart';

extension CategoryModelMapper on Category {
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      icon: icon,
      sortOrder: sortOrder,
      isMovieType: isMovieType,
      scanPaths: scanPaths,
      fileExtensions: fileExtensions,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
