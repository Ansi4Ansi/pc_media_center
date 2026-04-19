import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String name;
  final String? icon;
  final int sortOrder;
  final bool isMovieType;
  final String? scanPaths;
  final String? fileExtensions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.icon,
    this.sortOrder = 0,
    this.isMovieType = false,
    this.scanPaths,
    this.fileExtensions,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        sortOrder,
        isMovieType,
        scanPaths,
        fileExtensions,
        createdAt,
        updatedAt,
      ];
}
