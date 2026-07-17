import 'package:flutter/material.dart';
import '../data/models/movie_model.dart';
import '../screens/movie_detail_screen.dart';

class MovieMiniCard extends StatelessWidget {
  final Movie movie;
  const MovieMiniCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movieId: movie.id, mediaType: movie.mediaType)),
      ),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: movie.posterPath.isEmpty
                  ? Container(height: 170, width: 130, color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white38))
                  : Image.network(
                      '$imageBaseUrl${movie.posterPath}',
                      height: 170,
                      width: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(height: 170, width: 130, color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white38)),
                      loadingBuilder: (context, child, progress) =>
                          progress == null ? child : Container(height: 170, width: 130, color: Colors.white10),
                    ),
            ),
            const SizedBox(height: 6),
            Text(movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Times', fontWeight: FontWeight.bold)),
            Row(children: [
              const Icon(Icons.star, color: Colors.amber, size: 12),
              const SizedBox(width: 2),
              Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'Times')),
            ]),
          ],
        ),
      ),
    );
  }
}