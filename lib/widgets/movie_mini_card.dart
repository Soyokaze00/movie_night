import 'package:flutter/material.dart';
import '../data/models/movie_model.dart';
import '../screens/movie_detail_screen.dart';

class MovieMiniCard extends StatelessWidget {
  final Movie movie;
  const MovieMiniCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
    final theme = Theme.of(context);
    final borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [theme.colorScheme.secondary, theme.colorScheme.primary, Colors.orangeAccent],
    );

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movieId: movie.id, mediaType: movie.mediaType)),
      ),
      child: Container(
        width: 140,
        height: 200,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: borderGradient,
          boxShadow: [
            BoxShadow(color: theme.colorScheme.secondary.withOpacity(0.25), blurRadius: 10, spreadRadius: 0.5),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              movie.posterPath.isEmpty
                  ? Container(color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white38))
                  : Image.network(
                      '$imageBaseUrl${movie.posterPath}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white38)),
                      loadingBuilder: (context, child, progress) =>
                          progress == null ? child : Container(color: Colors.white10),
                    ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.95), Colors.transparent],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Times', fontWeight: FontWeight.bold, height: 1.15)),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.star, color: Colors.amber, size: 13),
                        const SizedBox(width: 3),
                        Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Times')),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
