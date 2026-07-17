import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/movie_model.dart';
import '../data/services/api_service.dart';

class MovieProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // registry با کلید "mediaType-id" تا فیلم و سریالی که id یکسان دارن قاطی نشن
  final Map<String, Movie> _registry = {};

  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _airingAnime = [];
  List<Movie> _popularAnime = [];

  bool _isLoading = false;
  String? _errorMessage;

  bool _isAnimeLoading = false;
  String? _animeError;

  bool _isDetailLoading = false;
  String? _detailError;

  List<Movie> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  Set<String> _savedFavoriteKeys = {};
  Map<String, String> _savedStatusMap = {};

  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get airingAnime => _airingAnime;
  List<Movie> get popularAnime => _popularAnime;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAnimeLoading => _isAnimeLoading;
  String? get animeError => _animeError;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;

  List<Movie> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;

  List<Movie> get favoriteMovies => _registry.values.where((m) => m.isFavorite).toList();
  List<Movie> get watchingMovies => _byStatus('watching');
  List<Movie> get onHoldMovies => _byStatus('onHold');
  List<Movie> get completedMovies => _byStatus('completed');
  List<Movie> get droppedMovies => _byStatus('dropped');
  List<Movie> get planToWatchMovies => _byStatus('planToWatch');

  List<Movie> _byStatus(String status) => _registry.values.where((m) => m.status == status).toList();

  MovieProvider() {
    _loadUserData();
  }

  String _key(int id, String mediaType) => '$mediaType-$id';

  Movie _register(Movie movie) {
    final key = _key(movie.id, movie.mediaType);
    final existing = _registry[key];
    if (existing != null) return existing;
    if (_savedFavoriteKeys.contains(key)) movie.isFavorite = true;
    if (_savedStatusMap.containsKey(key)) movie.status = _savedStatusMap[key]!;
    _registry[key] = movie;
    return movie;
  }

  Movie? getCachedMovie(int id, {String mediaType = 'movie'}) => _registry[_key(id, mediaType)];

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _apiService.getTrendingMovies(),
        _apiService.getPopularMovies(),
      ]);
      _trendingMovies = results[0].map(_register).toList();
      _popularMovies = results[1].map(_register).toList();
    } catch (e) {
      _errorMessage = 'Failed to load movies: ${e.toString()}';
      _trendingMovies = [];
      _popularMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnimeData() async {
    _isAnimeLoading = true;
    _animeError = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _apiService.getAiringAnime(),
        _apiService.getPopularAnime(),
      ]);
      _airingAnime = results[0].map(_register).toList();
      _popularAnime = results[1].map(_register).toList();
    } catch (e) {
      _animeError = 'Failed to load anime: ${e.toString()}';
    } finally {
      _isAnimeLoading = false;
      notifyListeners();
    }
  }

  Future<Movie> fetchMovieDetail(int id, {String mediaType = 'movie'}) async {
    _isDetailLoading = true;
    _detailError = null;
    notifyListeners();
    try {
      final existing = _registry[_key(id, mediaType)];
      final json = await _apiService.getMovieDetail(id, mediaType: mediaType);
      final movie = existing ?? _register(Movie.fromJson(json, mediaType: mediaType));
      movie.applyDetail(json);
      return movie;
    } catch (e) {
      _detailError = 'فیلم لود نشد: ${e.toString()}';
      rethrow;
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchError = null;
      notifyListeners();
      return;
    }
    _isSearching = true;
    _searchError = null;
    notifyListeners();
    try {
      final results = await _apiService.searchMovies(query);
      _searchResults = results.map(_register).toList();
    } catch (e) {
      _searchError = 'جستجو ناموفق بود: ${e.toString()}';
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchError = null;
    notifyListeners();
  }

  void toggleFavorite(int id, {String mediaType = 'movie'}) {
    final movie = _registry[_key(id, mediaType)];
    if (movie == null) return;
    movie.isFavorite = !movie.isFavorite;
    _saveUserData();
    notifyListeners();
  }

  void setStatus(int id, String status, {String mediaType = 'movie'}) {
    final movie = _registry[_key(id, mediaType)];
    if (movie == null) return;
    movie.status = movie.status == status ? 'none' : status;
    _saveUserData();
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final favJson = prefs.getString('favorite_keys');
    final statusJson = prefs.getString('status_map_v2');
    if (favJson != null) {
      _savedFavoriteKeys = (jsonDecode(favJson) as List).map((e) => e.toString()).toSet();
    }
    if (statusJson != null) {
      final map = jsonDecode(statusJson) as Map<String, dynamic>;
      _savedStatusMap = map.map((k, v) => MapEntry(k, v.toString()));
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _savedFavoriteKeys = _registry.values.where((m) => m.isFavorite).map((m) => _key(m.id, m.mediaType)).toSet();
    _savedStatusMap = {
      for (final m in _registry.values.where((m) => m.status != 'none')) _key(m.id, m.mediaType): m.status,
    };
    await prefs.setString('favorite_keys', jsonEncode(_savedFavoriteKeys.toList()));
    await prefs.setString('status_map_v2', jsonEncode(_savedStatusMap));
  }
}