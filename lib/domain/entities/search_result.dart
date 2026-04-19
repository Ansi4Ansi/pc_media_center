import 'package:equatable/equatable.dart';

class SearchResult extends Equatable {
  final String title;
  final String? description;
  final String? posterUrl;
  final int? year;
  final double? rating;
  final String? externalId;
  final String source; // 'tmdb', 'kinopoisk', 'rawg'

  const SearchResult({
    required this.title,
    this.description,
    this.posterUrl,
    this.year,
    this.rating,
    this.externalId,
    required this.source,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        posterUrl,
        year,
        rating,
        externalId,
        source,
      ];
}
