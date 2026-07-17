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
  double watchProgress;

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
    this.watchProgress = 0.0,
  });

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
}