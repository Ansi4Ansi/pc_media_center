import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../local/local_data_source.dart';

/// Кинопоиск API клиент для получения информации о фильмах и сериалах
class KinopoiskApiClient {
  final String apiKey;
  final String baseUrl = 'https://kinopoiskdkp.p.rapidapi.com';
  final LocalDataSource localCache;
  final Dio _dio;

  KinopoiskApiClient({
    required this.apiKey,
    required this.localCache,
    required Dio dio,
  }) : _dio = dio;

  Future<Map<String, dynamic>> searchMovies(String query) async {
    try {
      final response = await _dio.get(
        '$baseUrl/v2/movie/search',
        queryParameters: {'q': query},
        options: Options(headers: {'X-RapidAPI-Key': apiKey}),
      );
      return _cacheResult('kp_movies_$query', response.data);
    } on DioException catch (e, stackTrace) {
      throw _mapDioException(e, 'Kinopoisk searchMovies', stackTrace);
    } catch (e, stackTrace) {
      throw ApiException(
        'Failed to search movies in Kinopoisk: $e',
        stackTrace: stackTrace,
      );
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/v2/movie/$movieId',
        options: Options(headers: {'X-RapidAPI-Key': apiKey}),
      );
      return _cacheResult('kp_movie_$movieId', response.data);
    } on DioException catch (e, stackTrace) {
      throw _mapDioException(e, 'Kinopoisk getMovieDetails', stackTrace);
    } catch (e, stackTrace) {
      throw ApiException(
        'Failed to get movie details from Kinopoisk: $e',
        stackTrace: stackTrace,
      );
    }
  }

  Future<Map<String, dynamic>> getMovieImages(int movieId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/v2/movie/$movieId/images',
        options: Options(headers: {'X-RapidAPI-Key': apiKey}),
      );
      return _cacheResult('kp_images_$movieId', response.data);
    } on DioException catch (e, stackTrace) {
      throw _mapDioException(e, 'Kinopoisk getMovieImages', stackTrace);
    } catch (e, stackTrace) {
      throw ApiException(
        'Failed to get movie images from Kinopoisk: $e',
        stackTrace: stackTrace,
      );
    }
  }

  Map<String, dynamic> _cacheResult(String key, Map<String, dynamic> data) {
    // TODO: Implement caching when LocalDataSource supports it
    // localCache.cache(key, data);
    return data;
  }

  ApiException _mapDioException(
    DioException e,
    String operation,
    StackTrace stackTrace,
  ) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'Timeout during $operation: ${e.message}',
          stackTrace: stackTrace,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          'Network error during $operation: ${e.message}',
          stackTrace: stackTrace,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          'API error during $operation: ${e.message}',
          statusCode: e.response?.statusCode,
          isRetryable: _isRetryableStatusCode(e.response?.statusCode),
          stackTrace: stackTrace,
        );
      default:
        return ApiException(
          'Dio error during $operation: ${e.message}',
          stackTrace: stackTrace,
        );
    }
  }

  bool _isRetryableStatusCode(int? statusCode) {
    if (statusCode == null) return false;
    // Retry on 429 (rate limit), 502, 503, 504 (server errors)
    return statusCode == 429 || (statusCode >= 502 && statusCode <= 504);
  }
}
