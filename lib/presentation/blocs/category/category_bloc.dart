import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
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

  @override
  CategoryState get initialState => const CategoryInitial();

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
      final newCategory = await categoryRepository.addCategory(
        name: event.name,
        isMovieType: event.isMovieType,
        scanPaths: event.scanPaths,
        fileExtensions: event.fileExtensions,
      );
      emit(CategoryLoaded(categories: [...state.categories, newCategory]));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      if (event.categoryId == null) {
        emit(CategoryError(message: 'Не указана категория для обновления'));
        return;
      }
      final updatedCategory = await categoryRepository.updateCategory(
        categoryId: event.categoryId!,
        name: event.name,
        isMovieType: event.isMovieType,
        scanPaths: event.scanPaths,
        fileExtensions: event.fileExtensions,
      );
      emit(CategoryLoaded(categories: state.categories.map((c) => c.id == event.categoryId ? updatedCategory : c).toList()));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      if (event.categoryId == null) {
        emit(CategoryError(message: 'Не указана категория для удаления'));
        return;
      }
      await categoryRepository.deleteCategory(categoryId: event.categoryId!);
      emit(CategoryLoaded(categories: state.categories.where((c) => c.id != event.categoryId).toList()));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }
}
