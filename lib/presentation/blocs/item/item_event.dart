import 'package:equatable/equatable.dart';
import '../../../domain/entities/item.dart';

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

class LoadItemForEditEvent extends ItemEvent {
  final int itemId;

  const LoadItemForEditEvent(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class SaveItemEvent extends ItemEvent {
  final int? itemId;
  final int categoryId;
  final String title;
  final String? description;
  final String? launchPath;
  final String? posterPath;
  final int? year;
  final ItemType itemType;

  const SaveItemEvent({
    this.itemId,
    required this.categoryId,
    required this.title,
    this.description,
    this.launchPath,
    this.posterPath,
    this.year,
    required this.itemType,
  });

  @override
  List<Object> get props => [
        itemId ?? 0,
        categoryId,
        title,
        description ?? '',
        launchPath ?? '',
        posterPath ?? '',
        year ?? 0,
        itemType,
      ];
}

/// Data class for batch item creation
class CreateItemData extends Equatable {
  final String title;
  final String launchPath;
  final int? year;
  final ItemType itemType;
  final String? description;

  const CreateItemData({
    required this.title,
    required this.launchPath,
    this.year,
    this.itemType = ItemType.movie,
    this.description,
  });

  @override
  List<Object?> get props => [title, launchPath, year, itemType, description];
}

/// Event for batch creating items from scanned files
class BatchCreateItemsEvent extends ItemEvent {
  final List<CreateItemData> items;
  final int categoryId;

  const BatchCreateItemsEvent({
    required this.items,
    required this.categoryId,
  });

  @override
  List<Object> get props => [items, categoryId];
}
