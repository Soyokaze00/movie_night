class Movie {
  final int id;
  String title;
  String posterPath;
  String backdropPath;
  String overview;
  double voteAverage;
  String releaseDate;
  int? runtime;
  List<String> genres;
  String? director;
  List<String> cast;
  String mediaType; // 'movie' یا 'tv' (انیمه‌ها 'tv' هستن)

  bool isFavorite;
  String status; // 'none' | 'watching' | 'onHold' | 'completed' | 'dropped' | 'planToWatch'

  // --- user library fields (persisted in the local DB, not from TMDB) ---
  double? userScore; // 0-10, null = not rated
  int episodesWatched;
  int? totalEpisodes; // filled from TMDB detail for tv/anime, null for movies
  int rewatchCount;
  String? startDate; // ISO8601
  String? finishDate; // ISO8601
  String? notes;
  String? updatedAt; // ISO8601, set whenever this movie's library entry is saved

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    this.backdropPath = '',
    required this.overview,
    required this.voteAverage,
    this.releaseDate = '',
    this.runtime,
    this.genres = const [],
    this.director,
    this.cast = const [],
    this.mediaType = 'movie',
    this.isFavorite = false,
    this.status = 'none',
    this.userScore,
    this.episodesWatched = 0,
    this.totalEpisodes,
    this.rewatchCount = 0,
    this.startDate,
    this.finishDate,
    this.notes,
    this.updatedAt,
  });

  /// 0.0-1.0 progress bar value. For movies it's just watched/not-watched;
  /// for tv/anime it's episodesWatched / totalEpisodes.
  double get watchProgress {
    if (mediaType != 'tv') return status == 'completed' ? 1.0 : 0.0;
    if (totalEpisodes == null || totalEpisodes == 0) return 0.0;
    return (episodesWatched / totalEpisodes!).clamp(0.0, 1.0);
  }

  String get year => releaseDate.isNotEmpty ? releaseDate.split('-').first : '—';

  String get runtimeLabel {
    if (runtime == null || runtime == 0) return '';
    final h = runtime! ~/ 60;
    final m = runtime! % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  // برای movie از 'title'/'release_date' و برای tv از 'name'/'first_air_date' استفاده می‌شه
  factory Movie.fromJson(Map<String, dynamic> json, {String mediaType = 'movie'}) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? 'No Title',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      mediaType: mediaType,
    );
  }

  void applyDetail(Map<String, dynamic> json) {
    title = json['title'] ?? json['name'] ?? title;
    posterPath = json['poster_path'] ?? posterPath;
    backdropPath = json['backdrop_path'] ?? backdropPath;
    overview = json['overview'] ?? overview;
    voteAverage = (json['vote_average'] ?? voteAverage).toDouble();
    releaseDate = json['release_date'] ?? json['first_air_date'] ?? releaseDate;

    if (json['runtime'] != null) {
      runtime = json['runtime'];
    } else if (json['episode_run_time'] is List && (json['episode_run_time'] as List).isNotEmpty) {
      runtime = (json['episode_run_time'] as List).first as int;
    }

    if (json['number_of_episodes'] != null) {
      totalEpisodes = json['number_of_episodes'];
    }

    if (json['genres'] != null) {
      genres = (json['genres'] as List).map((g) => g['name'].toString()).toList();
    }

    final credits = json['credits'];
    if (credits != null) {
      final crew = credits['crew'] as List?;
      if (crew != null) {
        final directorEntry = crew.firstWhere((c) => c['job'] == 'Director', orElse: () => null);
        if (directorEntry != null) director = directorEntry['name'];
      }
      final castList = credits['cast'] as List?;
      if (castList != null) {
        cast = castList.take(5).map((c) => c['name'].toString()).toList();
      }
    }
  }

  Map<String, Object?> toEntryMap() {
    updatedAt = DateTime.now().toIso8601String();
    return {
      'media_id': id,
      'media_type': mediaType,
      'status': status,
      'is_favorite': isFavorite ? 1 : 0,
      'score': userScore,
      'episodes_watched': episodesWatched,
      'total_episodes': totalEpisodes,
      'rewatch_count': rewatchCount,
      'start_date': startDate,
      'finish_date': finishDate,
      'notes': notes,
      'updated_at': updatedAt,
    };
  }

  /// Applies a saved DB row onto a freshly-fetched Movie (which only has
  /// TMDB data at this point).
  void applyEntryMap(Map<String, Object?> row) {
    status = row['status'] as String? ?? 'none';
    isFavorite = (row['is_favorite'] as int? ?? 0) == 1;
    userScore = (row['score'] as num?)?.toDouble();
    episodesWatched = row['episodes_watched'] as int? ?? 0;
    totalEpisodes = row['total_episodes'] as int? ?? totalEpisodes;
    rewatchCount = row['rewatch_count'] as int? ?? 0;
    startDate = row['start_date'] as String?;
    finishDate = row['finish_date'] as String?;
    notes = row['notes'] as String?;
    updatedAt = row['updated_at'] as String?;
  }

  bool get hasLibraryData =>
      isFavorite || status != 'none' || userScore != null || episodesWatched > 0 || (notes?.isNotEmpty ?? false);
}