import 'package:equatable/equatable.dart';

enum ItemType { movie, tvShow, episode }

class ItemEntity extends Equatable {
  final int id;
  final String name;
  final String? posterPath;
  final String? posterUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int categoryId;
  final String title;
  final String description;
  final String launchPath;
  final String? launchArgs;
  final ItemType itemType;
  final int year;
  final double rating;
  final String externalId;
  final String metadataJson;
  final int sortOrder;
  final bool isFavorite;

  const ItemEntity({
    required this.id,
    required this.name,
    this.posterPath,
    this.posterUrl,
    required this.createdAt,
    this.updatedAt,
    this.categoryId = 0,
    this.title = '',
    this.description = '',
    this.launchPath = '',
    this.launchArgs,
    this.itemType = ItemType.movie,
    this.year = 0,
    this.rating = 0.0,
    this.externalId = '',
    this.metadataJson = '',
    this.sortOrder = 0,
    this.isFavorite = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    posterPath,
    posterUrl,
    createdAt,
    updatedAt,
    categoryId,
    title,
    description,
    launchPath,
    launchArgs,
    itemType,
    year,
    rating,
    externalId,
    metadataJson,
    sortOrder,
    isFavorite,
  ];
}
