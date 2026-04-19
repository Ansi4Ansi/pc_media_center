import 'package:equatable/equatable.dart';
import '../../../domain/entities/category.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();
  
  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
  
  @override
  List<Object> get props => [];
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
  
  @override
  List<Object> get props => [];
}

class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories;
  const CategoryLoaded({required this.categories});
  
  @override
  List<Object> get props => [categories];
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError({required this.message});
  
  @override
  List<Object> get props => [message];
}
