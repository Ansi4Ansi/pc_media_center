abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {
  final String name;
  final bool isMovieType;
  final String? scanPaths;
  final String? fileExtensions;

  AddCategoryEvent({
    required this.name,
    this.isMovieType = false,
    this.scanPaths,
    this.fileExtensions,
  });
}

class UpdateCategoryEvent extends CategoryEvent {
  final int categoryId;
  final String name;
  final bool isMovieType;
  final String? scanPaths;
  final String? fileExtensions;

  UpdateCategoryEvent({
    required this.categoryId,
    required this.name,
    this.isMovieType = false,
    this.scanPaths,
    this.fileExtensions,
  });
}

class DeleteCategoryEvent extends CategoryEvent {
  final int categoryId;

  DeleteCategoryEvent(this.categoryId);
}
