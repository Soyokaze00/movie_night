import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import '../models/movie_model.dart'; 


class ApiService {
  final String? _apiKey = dotenv.env['TMDB_API_KEY'];
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Uri _buildUrl(String endpoint) {
    if (_apiKey == null) {
      throw Exception('TMDB API Key not found. Make sure it is set in your .env file.');
    }
    return Uri.parse('$_baseUrl/$endpoint?api_key=$_apiKey');
  }

  Future<List<Movie>> getTrendingMovies() async {
    final url = _buildUrl('trending/movie/day'); 

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['results'] != null) {
          List<Movie> movies = (data['results'] as List)
              .map((json) => Movie.fromJson(json))
              .toList();
          return movies;
        } else {
          throw Exception('Trending movies data is null in response.');
        }
      } else {
        debugPrint("Server Error fetching trending movies: ${response.statusCode}");
        debugPrint("Server Response: ${response.body}");
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
          List<Movie> movies = (data['results'] as List)
              .map((json) => Movie.fromJson(json))
              .toList();
          return movies;
        } else {
          throw Exception('Popular movies data is null in response.');
        }
      } else {
        debugPrint("Server Error fetching popular movies: ${response.statusCode}");
        debugPrint("Server Response: ${response.body}");
        throw Exception('Failed to load popular movies: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error fetching popular movies: $e");
      throw Exception('Error fetching popular movies: $e');
    }
  }
}
