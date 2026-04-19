import 'package:dio/dio.dart';
import '../local/local_data_source.dart';

/// Кинопоиск API клиент для получения информации о фильмах и сериалах
class KinopoiskApiClient {
  final String apiKey;
  final String baseUrl = 'https://kinopoiskdkp.p.rapidapi.com';
  final LocalDataSource localCache;

  KinopoiskApiClient({required this.apiKey, required this.localCache});

  Future<Map<String, dynamic>> searchMovies(String query) async {
    try {
      final response = await Dio().get(
        '$baseUrl/v2/movie/search',
        queryParameters: {'q': query},
        options: Options(headers: {'X-RapidAPI-Key': apiKey}),
      );
      return _cacheResult('kp_movies_$query', response.data);
    } catch (e) {
      throw Exception('Ошибка Кинопоиск API: $e');
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final response = await Dio().get(
        '$baseUrl/v2/movie/$movieId',
        options: Options(headers: {'X-RapidAPI-Key': apiKey}),
      );
      return _cacheResult('kp_movie_$movieId', response.data);
    } catch (e) {
      throw Exception('Ошибка Кинопоиск API: $e');
    }
  }

  Future<Map<String, dynamic>> getMovieImages(int movieId) async {
    try {
      final response = await Dio().get(
        '$baseUrl/v2/movie/$movieId/images',
        options: Options(headers: {'X-RapidAPI-Key': apiKey}),
      );
      return _cacheResult('kp_images_$movieId', response.data);
    } catch (e) {
      throw Exception('Ошибка Кинопоиск API: $e');
    }
  }

  Map<String, dynamic> _cacheResult(String key, Map<String, dynamic> data) {
    localCache.cache(key, data);
    return data;
  }
}