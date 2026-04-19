abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {
  final String name;
  final bool isMovieType;
  final List<String> scanPaths;
  final List<String> fileExtensions;

  AddCategoryEvent({
    required this.name,
    this.isMovieType = false,
    this.scanPaths = const [],
    this.fileExtensions = const [],
  });
}

class UpdateCategoryEvent extends CategoryEvent {
  final int categoryId;
  final String name;
  final bool isMovieType;
  final List<String> scanPaths;
  final List<String> fileExtensions;

  UpdateCategoryEvent({
    required this.categoryId,
    required this.name,
    this.isMovieType = false,
    this.scanPaths = const [],
    this.fileExtensions = const [],
  });
}

class DeleteCategoryEvent extends CategoryEvent {
  final int categoryId;

  DeleteCategoryEvent(this.categoryId);
}
