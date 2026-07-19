import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/poster_grid_tile.dart';
import '../widgets/app_drawer.dart';
import 'search_screen.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<MovieProvider>(context, listen: false);
      await provider.fetchGenres();
      if (provider.discoverResults.isEmpty) {
        provider.fetchDiscover(mediaType: 'movie');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const AppDrawer(currentIndex: 1),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),
        ),
        title: const Text("Discover", style: TextStyle(color: Colors.white, fontFamily: 'Times', fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          final genres = provider.discoverMediaType == 'tv' ? provider.tvGenres : provider.movieGenres;
          return Column(
            children: [
              const SizedBox(height: 12),
              _buildMediaTypeToggle(provider, theme),
              const SizedBox(height: 12),
              _buildGenreChips(provider, genres, theme),
              const SizedBox(height: 8),
              Expanded(child: _buildResults(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMediaTypeToggle(MovieProvider provider, ThemeData theme) {
    Widget option(String label, String value) {
      final active = provider.discoverMediaType == value;
      return GestureDetector(
        onTap: () {
          if (!active) provider.fetchDiscover(mediaType: value, genreId: null);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: active ? theme.colorScheme.secondary : Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label,
              style: TextStyle(
                  color: active ? Colors.black : Colors.white70, fontFamily: 'Times', fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          option("Movies", "movie"),
          const SizedBox(width: 10),
          option("TV & Anime", "tv"),
        ],
      ),
    );
  }

  Widget _buildGenreChips(MovieProvider provider, Map<int, String> genres, ThemeData theme) {
    if (provider.isGenresLoading && genres.isEmpty) {
      return const SizedBox(
        height: 40,
        child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))),
      );
    }
    final entries = genres.entries.toList();
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: entries.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final active = provider.discoverGenreId == null;
            return _genreChip("All", active, theme, () => provider.fetchDiscover(genreId: null));
          }
          final entry = entries[index - 1];
          final active = provider.discoverGenreId == entry.key;
          return _genreChip(entry.value, active, theme, () => provider.fetchDiscover(genreId: entry.key));
        },
      ),
    );
  }

  Widget _genreChip(String label, bool active, ThemeData theme, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.secondary.withValues(alpha: 0.25) : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? theme.colorScheme.secondary : Colors.white24),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: active ? theme.colorScheme.secondary : Colors.white70, fontFamily: 'Times', fontSize: 12)),
      ),
    );
  }

  Widget _buildResults(MovieProvider provider) {
    if (provider.isDiscoverLoading && provider.discoverResults.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.white54));
    }
    if (provider.discoverError != null && provider.discoverResults.isEmpty) {
      return Center(child: Text(provider.discoverError!, style: const TextStyle(color: Colors.white70, fontFamily: 'Times')));
    }
    if (provider.discoverResults.isEmpty) {
      return const Center(child: Text("Nothing Found", style: TextStyle(color: Colors.white38, fontFamily: 'Times')));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.55,
      ),
      itemCount: provider.discoverResults.length,
      itemBuilder: (context, index) => PosterGridTile(movie: provider.discoverResults[index]),
    );
  }
}