import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/poster_grid_tile.dart';
import '../widgets/app_drawer.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MovieProvider>(context, listen: false);
      if (provider.airingAnime.isEmpty && provider.popularAnime.isEmpty) {
        provider.fetchAnimeData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const AppDrawer(currentIndex: 2),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),
        ),
        title: const Text("Discover Anime", style: TextStyle(color: Colors.white, fontFamily: 'Times', fontWeight: FontWeight.bold)),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          if (provider.isAnimeLoading && provider.airingAnime.isEmpty && provider.popularAnime.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Colors.white54));
          }
          if (provider.animeError != null && provider.airingAnime.isEmpty && provider.popularAnime.isEmpty) {
            return Center(child: Text(provider.animeError!, style: const TextStyle(color: Colors.white70, fontFamily: 'Times')));
          }
          final Map<int, bool> seen = {};
          final unique = [...provider.airingAnime, ...provider.popularAnime].where((m) {
            if (seen.containsKey(m.id)) return false;
            seen[m.id] = true;
            return true;
          }).toList();

          if (unique.isEmpty) {
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
            itemCount: unique.length,
            itemBuilder: (context, index) => PosterGridTile(movie: unique[index]),
          );
        },
      ),
    );
  }
}