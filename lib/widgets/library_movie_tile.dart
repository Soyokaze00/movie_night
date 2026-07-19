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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10, spreadRadius: 0.5),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: movie.posterPath.isEmpty
                  ? Container(width: 64, height: 90, color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white38))
                  : Image.network(
                      '$imageBaseUrl${movie.posterPath}',
                      width: 64,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(width: 64, height: 90, color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white38)),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Times', fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Row(children: [
                    if (movie.year != '—') ...[
                      const Icon(Icons.calendar_today, size: 12, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(movie.year, style: const TextStyle(color: Colors.white54, fontFamily: 'Times', fontSize: 12)),
                    ],
                    if (movie.runtimeLabel.isNotEmpty) ...[
                      const Text("  •  ", style: TextStyle(color: Colors.white38)),
                      const Icon(Icons.access_time, size: 12, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(movie.runtimeLabel, style: const TextStyle(color: Colors.white54, fontFamily: 'Times', fontSize: 12)),
                    ],
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 15),
                    const SizedBox(width: 4),
                    Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white70, fontFamily: 'Times', fontSize: 13)),
                  ]),
                  if (showProgress) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: movie.watchProgress, minHeight: 5, backgroundColor: Colors.white12, color: color),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: color.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}
