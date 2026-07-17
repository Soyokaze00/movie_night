import 'package:flutter/material.dart';
import '../data/models/movie_model.dart';
import '../screens/movie_detail_screen.dart';

class PosterGridTile extends StatelessWidget {
  final Movie movie;
  const PosterGridTile({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movieId: movie.id, mediaType: movie.mediaType)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: movie.posterPath.isEmpty
                  ? Container(color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white38))
                  : Image.network(
                      '$imageBaseUrl${movie.posterPath}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white38)),
                      loadingBuilder: (context, child, progress) => progress == null ? child : Container(color: Colors.white10),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Times', fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Row(children: [
            const Icon(Icons.star, color: Colors.amber, size: 11),
            const SizedBox(width: 2),
            Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Times')),
          ]),
        ],
      ),
    );
  }
}