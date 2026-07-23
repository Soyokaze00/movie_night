import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/movie_model.dart';

class ApiService {
  final String? _apiKey = dotenv.env['TMDB_API_KEY'];
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Set<int>? _cachedExcludedKeywordIds;

  Uri _buildUrl(String endpoint, {String? extraParams}) {
    if (_apiKey == null) {
      throw Exception('TMDB API Key not found. Make sure it is set in your .env file.');
    }
    var url = '$_baseUrl/$endpoint?api_key=$_apiKey';
    if (extraParams != null) url += '&$extraParams';
    return Uri.parse(url);
  }

  static const List<String> _blockedTextTerms = [
    'onlyfans', 'sex', 'porn star', 'pornstar', 'sex worker', 'prostitute',
    'stripper', 'erotica', 'softcore', 'sex tape', 'affair', 'seduce',
    'seduction', 'mistress', 'adultery', 'swapping', 'erotic',
  ];

  bool _hasBlockedText(dynamic json) {
    final title = ((json['title'] ?? json['name'] ?? '') as String).toLowerCase();
    final overview = ((json['overview'] ?? '') as String).toLowerCase();
    final combined = '$title $overview';
    return _blockedTextTerms.any((term) => combined.contains(term));
  }

  bool _isBlockedQuery(String query) {
    final lower = query.toLowerCase();
    return _blockedTextTerms.any((term) => lower.contains(term));
  }

  List<dynamic> _stripAdult(List<dynamic> results) {
    return results.where((json) => json is Map && json['adult'] != true && !_hasBlockedText(json)).toList();
  }

  Future<int?> _searchKeywordId(String name) async {
    final url = _buildUrl('search/keyword', extraParams: 'query=${Uri.encodeQueryComponent(name)}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = (data['results'] as List?) ?? [];
        final exact = results.firstWhere(
          (k) => (k['name'] as String).toLowerCase() == name.toLowerCase(),
          orElse: () => null,
        );
        if (exact != null) return exact['id'] as int;
        if (results.isNotEmpty) return results.first['id'] as int;
      }
    } catch (e) {
      debugPrint('Keyword lookup failed for "$name": $e');
    }
    return null;
  }

  Future<Set<int>> _resolveExcludedKeywordIds() async {
    if (_cachedExcludedKeywordIds != null) return _cachedExcludedKeywordIds!;
    final ids = <int>{161919, 198385};

    const terms = [
      'ecchi', 'hentai', 'adult animation',
      'onlyfans', 'sex worker', 'prostitute', 'pornography',
      'erotica', 'softcore', 'stripper', 'sex tape', 'nudity',
    ];

    try {
      final resolved = await Future.wait(terms.map(_searchKeywordId));
      for (final id in resolved) {
        if (id != null) ids.add(id);
      }
    } catch (e) {
      debugPrint('Failed to resolve excluded keywords: $e');
    }
    _cachedExcludedKeywordIds = ids;
    return ids;
  }

  Future<bool> _hasExcludedKeyword(int tvId, Set<int> excludedIds) async {
    final url = _buildUrl('tv/$tvId/keywords');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = (data['results'] as List?) ?? [];
        return results.any((k) => excludedIds.contains(k['id']));
      }
    } catch (_) {}
    return false;
  }

  Future<List<Movie>> getTrendingMovies() async {
    final url = _buildUrl('trending/movie/day', extraParams: 'include_adult=false');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['results'] != null) {
          final results = _stripAdult(data['results'] as List);
          return results.map((json) => Movie.fromJson(json)).toList();
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
    final url = _buildUrl('movie/popular', extraParams: 'include_adult=false');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['results'] != null) {
          final results = _stripAdult(data['results'] as List);
          return results.map((json) => Movie.fromJson(json)).toList();
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
    if (_isBlockedQuery(query)) return [];
    final url = _buildUrl('search/multi', extraParams: 'query=${Uri.encodeQueryComponent(query)}&include_adult=false');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final rawResults = (data['results'] as List?) ?? [];
        final results = _stripAdult(rawResults);
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

  Future<List<Movie>> getAiringAnime() async {
    final url = _buildUrl('tv/on_the_air', extraParams: 'include_adult=false');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final rawResults = (data['results'] as List?) ?? [];
        final safeResults = _stripAdult(rawResults);
        final candidates = safeResults.where((json) {
          final genreIds = (json['genre_ids'] as List?)?.cast<int>() ?? [];
          final origin = (json['origin_country'] as List?)?.cast<String>() ?? [];
          return genreIds.contains(16) && origin.contains('JP');
        }).toList();

        final excludedIds = await _resolveExcludedKeywordIds();
        final clean = <dynamic>[];
        await Future.wait(candidates.map((json) async {
          final flagged = await _hasExcludedKeyword(json['id'] as int, excludedIds);
          if (!flagged) clean.add(json);
        }));

        return clean.map((json) => Movie.fromJson(json, mediaType: 'tv')).toList();
      } else {
        throw Exception('Failed to load airing anime: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Connection Error fetching airing anime: $e");
      throw Exception('Error fetching airing anime: $e');
    }
  }

  Future<List<Movie>> getPopularAnime() async {
    final excludedIds = await _resolveExcludedKeywordIds();
    final url = _buildUrl(
      'discover/tv',
      extraParams:
          'with_genres=16&with_origin_country=JP&sort_by=popularity.desc&include_adult=false&without_keywords=${excludedIds.join(',')}',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final rawResults = (data['results'] as List?) ?? [];
        final results = _stripAdult(rawResults);
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
    final url = _buildUrl(endpoint, extraParams: 'include_adult=false');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final rawResults = (data['results'] as List?) ?? [];
        final results = _stripAdult(rawResults);
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
    final excludedIds = await _resolveExcludedKeywordIds();
    final params = StringBuffer('sort_by=popularity.desc&page=$page&include_adult=false&without_keywords=${excludedIds.join(',')}');
    if (genreId != null) params.write('&with_genres=$genreId');

    if (mediaType == 'movie') params.write('&certification_country=GB&certification.lte=12');
    final url = _buildUrl('discover/$mediaType', extraParams: params.toString());
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final rawResults = (data['results'] as List?) ?? [];
        final results = _stripAdult(rawResults);
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