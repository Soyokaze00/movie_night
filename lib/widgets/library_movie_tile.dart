import 'package:flutter/material.dart';
import '../data/models/movie_model.dart';
import '../screens/movie_detail_screen.dart';

class LibraryMovieTile extends StatelessWidget {
  final Movie movie;
  final Color color;
  final bool showProgress;
  const LibraryMovieTile({super.key, required this.movie, required this.color, this.showProgress = false});

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