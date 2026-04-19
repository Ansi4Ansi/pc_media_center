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
