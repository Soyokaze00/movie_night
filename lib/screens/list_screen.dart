import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../data/models/movie_model.dart';
import '../widgets/library_movie_tile.dart';

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
              LibraryMovieTile(movie: movies[index], color: _color, showProgress: type == MovieListType.watching),
          );
        },
      ),
    );
  }
}