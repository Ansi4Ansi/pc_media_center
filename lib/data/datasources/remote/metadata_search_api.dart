import 'tmdb_api.dart';
import 'kinopoisk_api.dart';

/// Общий API для поиска метаданных фильмов и сериалов через TMDB и Кинопоиск
class MetadataSearchApi {
  final TMDbApiClient tmdbClient;
  final KinopoiskApiClient kpClient;

  MetadataSearchApi({required this.tmdbClient, required this.kpClient});

  /// Поиск по названию — объединяет результаты из TMDB и Кинопоиска
  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      final tmdbResults = await tmdbClient.searchMovies(query);
      final kpResults = await kpClient.searchMovies(query);

      return [
        ...tmdbResults['results'] as List<dynamic>,
        ...kpResults['results'] as List<dynamic>
      ].map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Ошибка поиска метаданных: $e');
    }
  }

  /// Получение постера по ID фильма
  Future<Map<String, dynamic>> getPoster(int movieId) async {
    try {
      final tmdbImages = await tmdbClient.getMovieImages(movieId);
      return tmdbImages;
    } catch (e) {
      throw Exception('Ошибка получения постера: $e');
    }
  }

  /// Получение описания фильма из TMDB или Кинопоиска
  Future<Map<String, dynamic>> getDescription(int movieId) async {
    try {
      final tmdbDetails = await tmdbClient.getMovieDetails(movieId);
      return tmdbDetails;
    } catch (e) {
      throw Exception('Ошибка получения описания: $e');
    }
  }

  /// Поиск по TMDB только
  Future<List<Map<String, dynamic>>> searchTmdb(String query) async {
    try {
      final results = await tmdbClient.searchMovies(query);
      return (results['results'] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Ошибка поиска в TMDB: $e');
    }
  }

  /// Поиск по Кинопоиску только
  Future<List<Map<String, dynamic>>> searchKp(String query) async {
    try {
      final results = await kpClient.searchMovies(query);
      return (results['results'] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Ошибка поиска в Кинопоиске: $e');
    }
  }
}