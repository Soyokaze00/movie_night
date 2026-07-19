import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/movie_model.dart';

class ApiService {
  final String? _apiKey = dotenv.env['TMDB_API_KEY'];
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Uri _buildUrl(String endpoint, {String? extraParams}) {
    if (_apiKey == null) {
      throw Exception('TMDB API Key not found. Make sure it is set in your .env file.');
    }
    var url = '$_baseUrl/$endpoint?api_key=$_apiKey';
    if (extraParams != null) url += '&$extraParams';
    return Uri.parse(url);
  }

  Future<List<Movie>> getTrendingMovies() async {
    final url = _buildUrl('trending/movie/day');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['results'] != null) {
          return (data['results'] as List).map((json) => Movie.fromJson(json)).toList();
        }
        throw Exception('Trending movies data is null in response.');
      } else {
        debugPrint("Server Error fetching trending movies: ${response.statusCode}");
        throw Exception('Failed to load trending movies: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error fetching trending movies: $e");
      throw Exception('Error fetching trending movies: $e');
    }
  }

  Future<List<Movie>> getPopularMovies() async {
    final url = _buildUrl('movie/popular');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['results'] != null) {
          return (data['results'] as List).map((json) => Movie.fromJson(json)).toList();
        }
        throw Exception('Popular movies data is null in response.');
      } else {
        debugPrint("Server Error fetching popular movies: ${response.statusCode}");
        throw Exception('Failed to load popular movies: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error fetching popular movies: $e");
      throw Exception('Error fetching popular movies: $e');
    }
  }

  Future<Map<String, dynamic>> getMovieDetail(int id, {String mediaType = 'movie'}) async {
    final endpoint = mediaType == 'tv' ? 'tv/$id' : 'movie/$id';
    final url = _buildUrl(endpoint, extraParams: 'append_to_response=credits');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint("Server Error fetching detail: ${response.statusCode}");
        throw Exception('Failed to load detail: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error fetching detail: $e");
      throw Exception('Error fetching detail: $e');
    }
  }

  // /search/multi returns movies, tv shows, AND people all mixed together,
  // each tagged with its own media_type - we keep movie/tv and drop people
  // so anime (tv) titles are actually findable, not just movies.
  Future<List<Movie>> searchMovies(String query) async {
    final url = _buildUrl('search/multi', extraParams: 'query=${Uri.encodeQueryComponent(query)}&include_adult=false');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final results = (data['results'] as List?) ?? [];
        return results
            .where((json) => json['media_type'] == 'movie' || json['media_type'] == 'tv')
            .map((json) => Movie.fromJson(json, mediaType: json['media_type'] as String))
            .toList();
      } else {
        debugPrint("Server Error searching: ${response.statusCode}");
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error searching: $e");
      throw Exception('Error searching: $e');
    }
  }

  // tv/on_the_air لیست سریال‌های در حال پخش رو می‌ده، بعد سمت کلاینت فیلتر می‌کنیم
  // برای اونایی که ژانر Animation (16) دارن و کشورشون ژاپنه
  Future<List<Movie>> getAiringAnime() async {
    final url = _buildUrl('tv/on_the_air');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final results = (data['results'] as List?) ?? [];
        final anime = results.where((json) {
          final genreIds = (json['genre_ids'] as List?)?.cast<int>() ?? [];
          final origin = (json['origin_country'] as List?)?.cast<String>() ?? [];
          return genreIds.contains(16) && origin.contains('JP');
        });
        return anime.map((json) => Movie.fromJson(json, mediaType: 'tv')).toList();
      } else {
        throw Exception('Failed to load airing anime: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error fetching airing anime: $e");
      throw Exception('Error fetching airing anime: $e');
    }
  }

  Future<List<Movie>> getPopularAnime() async {
    final url = _buildUrl('discover/tv', extraParams: 'with_genres=16&with_origin_country=JP&sort_by=popularity.desc&include_adult=false');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final results = (data['results'] as List?) ?? [];
        return results.map((json) => Movie.fromJson(json, mediaType: 'tv')).toList();
      } else {
        throw Exception('Failed to load popular anime: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error fetching popular anime: $e");
      throw Exception('Error fetching popular anime: $e');
    }
  }


  Future<List<Movie>> getRecommendations(int id, {String mediaType = 'movie'}) async {
    final endpoint = mediaType == 'tv' ? 'tv/$id/recommendations' : 'movie/$id/recommendations';
    final url = _buildUrl(endpoint);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final results = (data['results'] as List?) ?? [];
        return results.map((json) => Movie.fromJson(json, mediaType: mediaType)).toList();
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error fetching recommendations: $e");
      throw Exception('Error fetching recommendations: $e');
    }
  }

  Future<Map<int, String>> getGenres(String mediaType) async {
    final url = _buildUrl('genre/$mediaType/list');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final list = (data['genres'] as List?) ?? [];
        return {for (final g in list) g['id'] as int: g['name'] as String};
      } else {
        throw Exception('Failed to load genres: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error fetching genres: $e");
      throw Exception('Error fetching genres: $e');
    }
  }

  Future<List<Movie>> discoverByGenre({required String mediaType, int? genreId, int page = 1}) async {
    final params = StringBuffer('sort_by=popularity.desc&page=$page&include_adult=false');
    if (genreId != null) params.write('&with_genres=$genreId');
    final url = _buildUrl('discover/$mediaType', extraParams: params.toString());
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final results = (data['results'] as List?) ?? [];
        return results.map((json) => Movie.fromJson(json, mediaType: mediaType)).toList();
      } else {
        throw Exception('Failed to discover: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error discovering: $e");
      throw Exception('Error discovering: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchPerson(String query) async {
    final url = _buildUrl('search/person', extraParams: 'query=${Uri.encodeQueryComponent(query)}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final results = (data['results'] as List?) ?? [];
        return results.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to search person: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error searching person: $e");
      throw Exception('Error searching person: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPersonCredits(int personId) async {
    final url = _buildUrl('person/$personId/combined_credits');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final cast = (data['cast'] as List?) ?? [];
        final crew = (data['crew'] as List?) ?? [];
        return [...cast, ...crew].cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load person credits: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error fetching person credits: $e");
      throw Exception('Error fetching person credits: $e');
    }
  }
}