import 'package:flutter/material.dart';
import '../data/models/movie_model.dart';
import '../widgets/poster_grid_tile.dart';

class SeeAllScreen extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  const SeeAllScreen({super.key, required this.title, required this.movies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'Times', fontWeight: FontWeight.bold)),
      ),
      body: movies.isEmpty
          ? const Center(child: Text("Nothing was found", style: TextStyle(color: Colors.white38, fontFamily: 'Times')))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.55,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) => PosterGridTile(movie: movies[index]),
            ),
    );
  }
}