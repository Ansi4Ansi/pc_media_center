import '../entities/search_result.dart';

abstract class SearchRepository {
  Future<List<SearchResult>> searchMovies(String query, {int page = 1});
  Future<List<SearchResult>> searchMetadata(String query);
}
