import '../../domain/entities/item.dart';
import '../database/app_database.dart';

extension ItemModelMapper on Item {
  ItemEntity toEntity() {
    return ItemEntity(
      id: id,
      categoryId: categoryId,
      title: title,
      description: description,
      posterPath: posterPath,
      posterUrl: posterUrl,
      launchPath: launchPath,
      launchArgs: launchArgs,
      itemType: _parseItemType(itemType),
      year: year,
      rating: rating,
      externalId: externalId,
      metadataJson: metadataJson,
      sortOrder: sortOrder,
      isFavorite: isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static ItemType _parseItemType(String type) {
    switch (type) {
      case 'app':
        return ItemType.app;
      case 'media':
        return ItemType.media;
      case 'url':
        return ItemType.url;
      default:
        return ItemType.file;
    }
  }
}

extension ItemTypeExtension on ItemType {
  String toDbString() {
    switch (this) {
      case ItemType.app:
        return 'app';
      case ItemType.file:
        return 'file';
      case ItemType.media:
        return 'media';
      case ItemType.url:
        return 'url';
    }
  }
}
