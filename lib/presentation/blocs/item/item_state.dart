import 'package:equatable/equatable.dart';
import '../../../domain/entities/item.dart';

abstract class ItemState extends Equatable {
  const ItemState();
  
  @override
  List<Object> get props => [];
}

class ItemInitial extends ItemState {
  const ItemInitial();
  
  @override
  List<Object> get props => [];
}

class ItemLoaded extends ItemState {
  final List<ItemEntity> items;
  const ItemLoaded({required this.items});
  
  @override
  List<Object> get props => [items];
}

class ItemEmpty extends ItemState {
  const ItemEmpty();
  
  @override
  List<Object> get props => [];
}

class ItemError extends ItemState {
  final String message;
  const ItemError({required this.message});
  
  @override
  List<Object> get props => [message];
}
