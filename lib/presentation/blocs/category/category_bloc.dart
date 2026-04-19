import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc(this.categoryRepository) : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) async {
    try {
      emit(const CategoryLoading());
      final categories = await categoryRepository.getCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onAddCategory(AddCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      if (event.name.isEmpty) {
        emit(CategoryError(message: 'Название категории обязательно'));
        return;
      }
      await categoryRepository.addCategory(
        name: event.name,
        isMovieType: event.isMovieType,
        scanPaths: event.scanPaths,
        fileExtensions: event.fileExtensions,
      );
      // Reload categories to get the updated list
      final categories = await categoryRepository.getCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      // Fetch the existing category from repository
      final existingCategory = await categoryRepository.getCategoryById(event.categoryId);

      final updatedCategory = CategoryEntity(
        id: event.categoryId,
        name: event.name,
        icon: existingCategory.icon,
        sortOrder: existingCategory.sortOrder,
        isMovieType: event.isMovieType,
        scanPaths: event.scanPaths,
        fileExtensions: event.fileExtensions,
        createdAt: existingCategory.createdAt,
        updatedAt: DateTime.now(),
      );

      await categoryRepository.updateCategory(updatedCategory);

      // Reload categories to get the updated list
      final categories = await categoryRepository.getCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.deleteCategory(event.categoryId);
      // Reload categories to get the updated list
      final categories = await categoryRepository.getCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }
}
