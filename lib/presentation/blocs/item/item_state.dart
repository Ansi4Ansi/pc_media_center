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

class SingleItemLoaded extends ItemState {
  final ItemEntity item;
  const SingleItemLoaded({required this.item});

  @override
  List<Object> get props => [item];
}

class ItemEmpty extends ItemState {
  const ItemEmpty();

  @override
  List<Object> get props => [];
}

class ItemDeleted extends ItemState {
  const ItemDeleted();

  @override
  List<Object> get props => [];
}

class ItemError extends ItemState {
  final String message;
  const ItemError({required this.message});
  
  @override
  List<Object> get props => [message];
}

class ItemFormLoading extends ItemState {
  const ItemFormLoading();
  
  @override
  List<Object> get props => [];
}

class ItemFormLoaded extends ItemState {
  final ItemEntity? item;
  const ItemFormLoaded({this.item});
  
  @override
  List<Object> get props => [item ?? ''];
}

class ItemSaved extends ItemState {
  const ItemSaved();
  
  @override
  List<Object> get props => [];
}

class ItemFormError extends ItemState {
  final String message;
  const ItemFormError({required this.message});
  
  @override
  List<Object> get props => [message];
}
