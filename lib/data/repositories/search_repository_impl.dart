import 'package:dio/dio.dart';

import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../datasources/remote/tmdb_api.dart';
import '../datasources/remote/kinopoisk_api.dart';

/// Реализация SearchRepository для поиска метаданных в TMDB и Кинопоиск
class SearchRepositoryImpl implements SearchRepository {
  final TMDbApiClient _tmdbClient;
  final KinopoiskApiClient _kinopoiskClient;
  final LocalDataSource _localCache;

  SearchRepositoryImpl(
    this._tmdbClient,
    this._kinopoiskClient,
    this._localCache,
  );

  @override
  Future<List<SearchResult>> searchMovies(String query, {int page = 1}) async {
    try {
      // Поиск в TMDB
      final tmdbResponse = await _tmdbClient.searchMovies(query);
      final tmdbResults = _extractTmdbResults(tmdbResponse);

      if (tmdbResults.isNotEmpty) {
        return tmdbResults;
      }

      // Если ничего не найдено в TMDB, пробуем Кинопоиск
      final kinopoiskResponse = await _kinopoiskClient.searchMovies(query);
      final kinopoiskResults = _extractKinopoiskResults(kinopoiskResponse);

      return kinopoiskResults;
    } catch (e) {
      throw Exception('Ошибка поиска фильмов: $e');
    }
  }

  @override
  Future<List<SearchResult>> searchMetadata(String query) async {
    try {
      // Параллельный поиск в обоих источниках
      final tmdbResponse = await _tmdbClient.searchMovies(query);
      final kinopoiskResponse = await _kinopoiskClient.searchMovies(query);

      // Объединяем результаты с указанием источника
      final results = <SearchResult>[];

      // Добавляем результаты из TMDB
      results.addAll(_extractTmdbResults(tmdbResponse));

      // Добавляем результаты из Кинопоиск
      results.addAll(_extractKinopoiskResults(kinopoiskResponse));

      return results.toSorted((a, b) {
        // Сортировка: сначала по рейтингу (убывание), затем по году (убывание)
        final ratingCompare = b.rating?.compareTo(a.rating ?? 0.0);
        if (ratingCompare != 0) return ratingCompare;

        final yearCompare = (b.year ?? 0).compareTo(a.year ?? 0);
        return yearCompare;
      });
    } catch (e) {
      // Возвращаем пустой список при ошибке, а не выбрасываем исключение
      print('Ошибка поиска метаданных: $e');
      return [];
    }
  }

  /// Извлекает результаты из ответа TMDB
  List<SearchResult> _extractTmdbResults(Map<String, dynamic> response) {
    final results = <SearchResult>[];

    if (!response.containsKey('results')) return results;

    for (var item in response['results'] as List<dynamic>) {
      try {
        final title = item['title'] ?? item['name'] ?? '';
        final posterPath = item['poster_path'];
        final releaseYear = item['release_date']?.substring(0, 4);

        if (title.isEmpty) continue;

        final posterUrl = posterPath != null && posterPath.isNotEmpty
            ? 'https://image.tmdb.org/t/p/w500$posterPath'
            : null;

        results.add(SearchResult(
          title: title,
          description: item['overview'],
          posterUrl: posterUrl,
          year: int.tryParse(releaseYear ?? ''),
          rating: double.tryParse(item['vote_average']?.toString() ?? '0'),
          externalId: item['id'].toString(),
          source: 'tmdb',
        ));
      } catch (e) {
        // Пропускаем невалидные элементы
      }
    }

    return results;
  }

  /// Извлекает результаты из ответа Кинопоиск
  List<SearchResult> _extractKinopoiskResults(Map<String, dynamic> response) {
    final results = <SearchResult>[];

    if (!response.containsKey('results')) return results;

    for (var item in response['results'] as List<dynamic>) {
      try {
        final title = item['name'] ?? '';
        final posterPath = item['poster'];
        final releaseYear = item['year'].toString();

        if (title.isEmpty) continue;

        final posterUrl = posterPath != null && posterPath.isNotEmpty
            ? 'https://img.kinopoisk.ru/cover/${posterPath}'
            : null;

        results.add(SearchResult(
          title: title,
          description: item['description'],
          posterUrl: posterUrl,
          year: int.tryParse(releaseYear),
          rating: double.tryParse(item['rating']?.toString() ?? '0'),
          externalId: item['id'].toString(),
          source: 'kinopoisk',
        ));
      } catch (e) {
        // Пропускаем невалидные элементы
      }
    }

    return results;
  }
}
