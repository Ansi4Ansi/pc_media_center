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

  ItemEntity copyWith({
    int? id,
    String? name,
    String? posterPath,
    String? posterUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? categoryId,
    String? title,
    String? description,
    String? launchPath,
    String? launchArgs,
    ItemType? itemType,
    int? year,
    double? rating,
    String? externalId,
    String? metadataJson,
    int? sortOrder,
    bool? isFavorite,
  }) {
    return ItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      posterPath: posterPath ?? this.posterPath,
      posterUrl: posterUrl ?? this.posterUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      launchPath: launchPath ?? this.launchPath,
      launchArgs: launchArgs ?? this.launchArgs,
      itemType: itemType ?? this.itemType,
      year: year ?? this.year,
      rating: rating ?? this.rating,
      externalId: externalId ?? this.externalId,
      metadataJson: metadataJson ?? this.metadataJson,
      sortOrder: sortOrder ?? this.sortOrder,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
