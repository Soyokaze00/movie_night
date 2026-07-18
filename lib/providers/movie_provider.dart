import 'package:flutter/material.dart';
import '../data/models/movie_model.dart';
import '../data/services/api_service.dart';
import '../data/services/db_service.dart';

class MovieProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DbService _db = DbService.instance;

  // registry با کلید "mediaType-id" تا فیلم و سریالی که id یکسان دارن قاطی نشن
  final Map<String, Movie> _registry = {};

  // raw saved rows keyed the same way, so movies not yet fetched from TMDB
  // this session can still be shown as "has library data" once fetched
  Map<String, Map<String, Object?>> _savedEntries = {};

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

  bool _isLibraryReady = false;

  String? _profileName;
  String? _profileAvatar;
  bool _isProfileReady = false;

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
  bool get isLibraryReady => _isLibraryReady;

  String? get profileName => _profileName;
  String? get profileAvatar => _profileAvatar;
  bool get isProfileReady => _isProfileReady;
  bool get hasProfile => _profileName != null;

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
    _loadProfile();
  }

  String _key(int id, String mediaType) => '$mediaType-$id';

  Movie _register(Movie movie) {
    final key = _key(movie.id, movie.mediaType);
    final existing = _registry[key];
    if (existing != null) return existing;
    final saved = _savedEntries[key];
    if (saved != null) movie.applyEntryMap(saved);
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

  // ---------- library actions (all persisted to sqlite) ----------

  void toggleFavorite(int id, {String mediaType = 'movie'}) {
    final movie = _registry[_key(id, mediaType)];
    if (movie == null) return;
    movie.isFavorite = !movie.isFavorite;
    _saveEntry(movie);
  }

  void setStatus(int id, String status, {String mediaType = 'movie'}) {
    final movie = _registry[_key(id, mediaType)];
    if (movie == null) return;
    final wasStatus = movie.status;
    movie.status = movie.status == status ? 'none' : status;

    // convenience: track dates automatically as status changes
    final now = DateTime.now().toIso8601String();
    if (movie.status == 'watching' && movie.startDate == null) {
      movie.startDate = now;
    }
    if (movie.status == 'completed') {
      movie.finishDate = now;
      if (movie.mediaType == 'tv' && movie.totalEpisodes != null) {
        movie.episodesWatched = movie.totalEpisodes!;
      }
      if (wasStatus == 'completed') {
        // toggling completed off->on again counts as a rewatch
        movie.rewatchCount += 1;
      }
    }
    _saveEntry(movie);
  }

  /// score: 0-10 (0.5 steps), or null to clear the rating
  void setScore(int id, double? score, {String mediaType = 'movie'}) {
    final movie = _registry[_key(id, mediaType)];
    if (movie == null) return;
    movie.userScore = score;
    _saveEntry(movie);
  }

  /// Sets episode progress directly. Clamped to totalEpisodes if known.
  /// Auto-flips status to 'watching' if it was 'none' or 'planToWatch',
  /// and to 'completed' once the last episode is watched.
  void setEpisodeProgress(int id, int episodesWatched, {String mediaType = 'tv'}) {
    final movie = _registry[_key(id, mediaType)];
    if (movie == null) return;
    final total = movie.totalEpisodes;
    var value = episodesWatched < 0 ? 0 : episodesWatched;
    if (total != null && value > total) value = total;
    movie.episodesWatched = value;

    if (movie.status == 'none' || movie.status == 'planToWatch') {
      movie.status = 'watching';
      movie.startDate ??= DateTime.now().toIso8601String();
    }
    if (total != null && value >= total && total > 0) {
      movie.status = 'completed';
      movie.finishDate ??= DateTime.now().toIso8601String();
    }
    _saveEntry(movie);
  }

  void incrementEpisode(int id, {String mediaType = 'tv'}) {
    final movie = _registry[_key(id, mediaType)];
    if (movie == null) return;
    setEpisodeProgress(id, movie.episodesWatched + 1, mediaType: mediaType);
  }

  void decrementEpisode(int id, {String mediaType = 'tv'}) {
    final movie = _registry[_key(id, mediaType)];
    if (movie == null) return;
    setEpisodeProgress(id, movie.episodesWatched - 1, mediaType: mediaType);
  }

  void setNotes(int id, String notes, {String mediaType = 'movie'}) {
    final movie = _registry[_key(id, mediaType)];
    if (movie == null) return;
    movie.notes = notes;
    _saveEntry(movie);
  }

  void incrementRewatch(int id, {String mediaType = 'movie'}) {
    final movie = _registry[_key(id, mediaType)];
    if (movie == null) return;
    movie.rewatchCount += 1;
    _saveEntry(movie);
  }

  Future<void> _saveEntry(Movie movie) async {
    notifyListeners(); // update UI immediately, don't wait on disk I/O
    final key = _key(movie.id, movie.mediaType);
    if (!movie.hasLibraryData) {
      _savedEntries.remove(key);
      await _db.deleteEntry(movie.id, movie.mediaType);
      return;
    }
    final row = movie.toEntryMap();
    _savedEntries[key] = row;
    await _db.upsertEntry(row);
  }

  Future<void> _loadUserData() async {
    try {
      final rows = await _db.getAllEntries();
      _savedEntries = {
        for (final row in rows) '${row['media_type']}-${row['media_id']}': row,
      };
    } catch (e) {
      debugPrint('Failed to load library data: $e');
    } finally {
      _isLibraryReady = true;
      notifyListeners();
    }
  }

  // ---------- local profile (name + avatar, no auth/server) ----------

  Future<void> _loadProfile() async {
    try {
      final row = await _db.getProfile();
      _profileName = row?['name'] as String?;
      _profileAvatar = row?['avatar'] as String?;
    } catch (e) {
      debugPrint('Failed to load profile: $e');
    } finally {
      _isProfileReady = true;
      notifyListeners();
    }
  }

  Future<void> saveProfile(String name, String avatar) async {
    await _db.saveProfile(name, avatar);
    _profileName = name;
    _profileAvatar = avatar;
    notifyListeners();
  }

  // ---------- custom lists ----------

  Future<List<Map<String, Object?>>> getCustomLists() => _db.getLists();

  Future<int> createCustomList(String name) async {
    final id = await _db.createList(name);
    notifyListeners();
    return id;
  }

  Future<void> deleteCustomList(int listId) async {
    await _db.deleteList(listId);
    notifyListeners();
  }

  Future<void> addToCustomList(int listId, int mediaId, String mediaType) async {
    await _db.addItemToList(listId, mediaId, mediaType);
    notifyListeners();
  }

  Future<void> removeFromCustomList(int listId, int mediaId, String mediaType) async {
    await _db.removeItemFromList(listId, mediaId, mediaType);
    notifyListeners();
  }

  /// Resolves a custom list's saved (mediaId, mediaType) rows into Movie
  /// objects -- pulls from the in-memory registry if already fetched this
  /// session, otherwise fetches fresh from TMDB.
  Future<List<Movie>> getCustomListMovies(int listId) async {
    final items = await _db.getItemsForList(listId);
    final movies = <Movie>[];
    for (final item in items) {
      final id = item['media_id'] as int;
      final mediaType = item['media_type'] as String;
      final cached = getCachedMovie(id, mediaType: mediaType);
      if (cached != null) {
        movies.add(cached);
        continue;
      }
      try {
        movies.add(await fetchMovieDetail(id, mediaType: mediaType));
      } catch (_) {
        // skip titles that fail to fetch (e.g. offline)
      }
    }
    return movies;
  }
}
