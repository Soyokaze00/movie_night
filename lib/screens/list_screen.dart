import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../data/models/movie_model.dart';
import 'movie_detail_screen.dart';

enum MovieListType { favorites, watching, onHold, completed, dropped, planToWatch }

class MovieListScreen extends StatelessWidget {
  final MovieListType type;
  const MovieListScreen({super.key, required this.type});

  String get _title {
    switch (type) {
      case MovieListType.favorites: return "Favorites";
      case MovieListType.watching: return "Watching";
      case MovieListType.onHold: return "On Hold";
      case MovieListType.completed: return "Completed";
      case MovieListType.dropped: return "Dropped";
      case MovieListType.planToWatch: return "Plan to Watch";
    }
  }

  Color get _color {
    switch (type) {
      case MovieListType.favorites: return Colors.pinkAccent;
      case MovieListType.watching: return Colors.purpleAccent;
      case MovieListType.onHold: return Colors.orange;
      case MovieListType.completed: return Colors.teal;
      case MovieListType.dropped: return Colors.redAccent;
      case MovieListType.planToWatch: return Colors.blueAccent;
    }
  }

  IconData get _icon {
    switch (type) {
      case MovieListType.favorites: return Icons.favorite;
      case MovieListType.watching: return Icons.play_circle_fill;
      case MovieListType.onHold: return Icons.pause_circle_filled;
      case MovieListType.completed: return Icons.check_circle;
      case MovieListType.dropped: return Icons.cancel;
      case MovieListType.planToWatch: return Icons.bookmark;
    }
  }

  List<Movie> _moviesFor(MovieProvider provider) {
    switch (type) {
      case MovieListType.favorites: return provider.favoriteMovies;
      case MovieListType.watching: return provider.watchingMovies;
      case MovieListType.onHold: return provider.onHoldMovies;
      case MovieListType.completed: return provider.completedMovies;
      case MovieListType.dropped: return provider.droppedMovies;
      case MovieListType.planToWatch: return provider.planToWatchMovies;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(_title, style: TextStyle(color: _color, fontFamily: 'Times', fontWeight: FontWeight.bold)),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          final movies = _moviesFor(provider);
          if (movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_icon, color: Colors.white24, size: 48),
                  const SizedBox(height: 12),
                  const Text("Nothing added yet", style: TextStyle(color: Colors.white38, fontFamily: 'Times')),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: movies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _MovieListTile(movie: movies[index], color: _color, showProgress: type == MovieListType.watching),
          );
        },
      ),
    );
  }
}

class _MovieListTile extends StatelessWidget {
  final Movie movie;
  final Color color;
  final bool showProgress;
  const _MovieListTile({required this.movie, required this.color, this.showProgress = false});

  @override
  Widget build(BuildContext context) {
    const imageBaseUrl = 'https://image.tmdb.org/t/p/w200';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movieId: movie.id, mediaType: movie.mediaType))),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: movie.posterPath.isEmpty
                ? Container(width: 60, height: 85, color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white38))
                : Image.network(
                    '$imageBaseUrl${movie.posterPath}',
                    width: 60,
                    height: 85,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(width: 60, height: 85, color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white38)),
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Times', fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(children: [
                    if (movie.year != '—') Text(movie.year, style: const TextStyle(color: Colors.white54, fontFamily: 'Times', fontSize: 12)),
                    if (movie.runtimeLabel.isNotEmpty) ...[
                      const Text(" • ", style: TextStyle(color: Colors.white54)),
                      Text(movie.runtimeLabel, style: const TextStyle(color: Colors.white54, fontFamily: 'Times', fontSize: 12)),
                    ],
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 3),
                    Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white70, fontFamily: 'Times', fontSize: 12)),
                  ]),
                  if (showProgress) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: movie.watchProgress, minHeight: 5, backgroundColor: Colors.white12, color: color),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}