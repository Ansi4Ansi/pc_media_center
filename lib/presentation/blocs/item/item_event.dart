import 'package:equatable/equatable.dart';

abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object> get props => [];
}

class GetItemsByCategoryEvent extends ItemEvent {
  final int categoryId;
  final int? offset;
  final int? limit;

  const GetItemsByCategoryEvent({
    required this.categoryId,
    this.offset,
    this.limit,
  });

  @override
  List<Object> get props => [categoryId, offset ?? 0, limit ?? 50];
}

class GetItemByIdEvent extends ItemEvent {
  final int itemId;

  const GetItemByIdEvent({required this.itemId});

  @override
  List<Object> get props => [itemId];
}

class DeleteItemEvent extends ItemEvent {
  final int itemId;

  const DeleteItemEvent({required this.itemId});

  @override
  List<Object> get props => [itemId];
}
