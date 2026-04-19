import '../../domain/entities/item.dart';
import '../database/app_database.dart';

extension ItemModelMapper on Item {
  ItemEntity toEntity() {
    return ItemEntity(
      id: id,
      name: title,
      categoryId: categoryId,
      title: title,
      description: description ?? '',
      posterPath: posterPath,
      posterUrl: posterUrl,
      launchPath: launchPath ?? '',
      launchArgs: launchArgs,
      itemType: _parseItemType(itemType),
      year: year ?? 0,
      rating: rating ?? 0.0,
      externalId: externalId ?? '',
      metadataJson: metadataJson ?? '{}',
      sortOrder: sortOrder,
      isFavorite: isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static ItemType _parseItemType(String type) {
    switch (type) {
      case 'tvShow':
        return ItemType.tvShow;
      case 'episode':
        return ItemType.episode;
      default:
        return ItemType.movie;
    }
  }
}

extension ItemTypeExtension on ItemType {
  String toDbString() {
    switch (this) {
      case ItemType.tvShow:
        return 'tvShow';
      case ItemType.episode:
        return 'episode';
      case ItemType.movie:
        return 'movie';
    }
  }
}
