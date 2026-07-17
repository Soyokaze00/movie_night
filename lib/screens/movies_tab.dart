import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/poster_grid_tile.dart';
import '../widgets/app_drawer.dart';
import 'search_screen.dart';

class MoviesTab extends StatelessWidget {
  const MoviesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const AppDrawer(currentIndex: 1),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),
        ),
        title: const Text("Movies", style: TextStyle(color: Colors.white, fontFamily: 'Times', fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
        ],
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.trendingMovies.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Colors.white54));
          }
          final Map<int, bool> seen = {};
          final all = [...provider.trendingMovies, ...provider.popularMovies].where((m) {
            if (seen.containsKey(m.id)) return false;
            seen[m.id] = true;
            return true;
          }).toList();

          if (all.isEmpty) {
            return const Center(child: Text("چیزی پیدا نشد", style: TextStyle(color: Colors.white38, fontFamily: 'Times')));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.55,
            ),
            itemCount: all.length,
            itemBuilder: (context, index) => PosterGridTile(movie: all[index]),
          );
        },
      ),
    );
  }
}