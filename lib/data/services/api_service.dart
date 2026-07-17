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

  Future<List<Movie>> searchMovies(String query) async {
    final url = _buildUrl('search/movie', extraParams: 'query=${Uri.encodeQueryComponent(query)}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['results'] != null) {
          return (data['results'] as List).map((json) => Movie.fromJson(json)).toList();
        }
        return [];
      } else {
        debugPrint("Server Error searching movies: ${response.statusCode}");
        throw Exception('Failed to search movies: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error searching movies: $e");
      throw Exception('Error searching movies: $e');
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
    final url = _buildUrl('discover/tv', extraParams: 'with_genres=16&with_origin_country=JP&sort_by=popularity.desc');
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
}