import 'package:equatable/equatable.dart';

abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object> get props => [];
}

class GetItemsByCategory extends ItemEvent {
  final String categoryId;
  final int offset;
  final int limit;

  const GetItemsByCategory({
    required this.categoryId,
    this.offset = 0,
    this.limit = 50,
  });

  @override
  List<Object> get props => [categoryId, offset, limit];
}
