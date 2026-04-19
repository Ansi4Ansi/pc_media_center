import 'package:dio/dio.dart';
import '../local/local_data_source.dart';

/// TMDB API клиент для получения информации о фильмах и сериалах
class TMDbApiClient {
  final String apiKey;
  final String baseUrl = 'https://api.themoviedb.org/3';
  final LocalDataSource localCache;

  TMDbApiClient({required this.apiKey, required this.localCache});

  Future<Map<String, dynamic>> searchMovies(String query) async {
    try {
      final response = await Dio().get(
        '$baseUrl/search/movie',
        queryParameters: {'api_key': apiKey, 'query': query},
      );
      return _cacheResult('tmdb_movies_$query', response.data);
    } catch (e) {
      throw Exception('Ошибка TMDB API: $e');
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final response = await Dio().get(
        '$baseUrl/movie/$movieId',
        queryParameters: {'api_key': apiKey},
      );
      return _cacheResult('tmdb_movie_$movieId', response.data);
    } catch (e) {
      throw Exception('Ошибка TMDB API: $e');
    }
  }

  Future<Map<String, dynamic>> getMovieImages(int movieId) async {
    try {
      final response = await Dio().get(
        '$baseUrl/movie/$movieId/images',
        queryParameters: {'api_key': apiKey},
      );
      return _cacheResult('tmdb_images_$movieId', response.data);
    } catch (e) {
      throw Exception('Ошибка TMDB API: $e');
    }
  }

  Map<String, dynamic> _cacheResult(String key, Map<String, dynamic> data) {
    localCache.cache(key, data);
    return data;
  }
}