import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/movie_mini_card.dart';
import 'profile_setup_screen.dart';
import 'movie_detail_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const AppDrawer(currentIndex: 3),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),
        ),
        title: const Text("Profile", style: TextStyle(color: Colors.white, fontFamily: 'Times', fontWeight: FontWeight.bold)),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider, theme),
                const SizedBox(height: 28),
                const Text("Your Library", style: TextStyle(color: Colors.white, fontFamily: 'Times', fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildLibraryGrid(provider),
                const SizedBox(height: 28),
                const Text("Activity", style: TextStyle(color: Colors.white, fontFamily: 'Times', fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildActivityRow(provider, theme),
                if (provider.recentlyUpdated.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const Text("Recently Updated", style: TextStyle(color: Colors.white, fontFamily: 'Times', fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildRecentlyUpdatedRow(provider),
                ],
                if (provider.topRatedByUser.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const Text("Top Rated by You", style: TextStyle(color: Colors.white, fontFamily: 'Times', fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTopRatedRow(context, provider),
                ],
                if (provider.libraryMovies.isEmpty) ...[
                  const SizedBox(height: 28),
                  _buildEmptyHint(theme),
                ],
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MovieProvider provider, ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: theme.colorScheme.secondary.withOpacity(0.3),
          child: provider.profileAvatar != null
              ? Text(provider.profileAvatar!, style: const TextStyle(fontSize: 28))
              : const Icon(Icons.person, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(provider.profileName ?? "Movie Fan",
              style: const TextStyle(color: Colors.white, fontFamily: 'Times', fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white54),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupScreen())),
        ),
      ],
    );
  }

  Widget _buildLibraryGrid(MovieProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _statTile("Favorites", provider.favoriteMovies.length, Colors.pinkAccent),
        _statTile("Watching", provider.watchingMovies.length, Colors.purpleAccent),
        _statTile("On Hold", provider.onHoldMovies.length, Colors.orange),
        _statTile("Completed", provider.completedMovies.length, Colors.teal),
        _statTile("Plan to Watch", provider.planToWatchMovies.length, Colors.blueAccent),
        _statTile("Dropped", provider.droppedMovies.length, Colors.redAccent),
      ],
    );
  }

  Widget _statTile(String label, int count, Color color) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count', style: TextStyle(color: color, fontFamily: 'Times', fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontFamily: 'Times', fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActivityRow(MovieProvider provider, ThemeData theme) {
    final avg = provider.averageScore;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _activityChip(Icons.collections_bookmark, "${provider.libraryMovies.length}", "Titles Tracked", theme.colorScheme.secondary),
        _activityChip(Icons.tv, "${provider.totalEpisodesWatched}", "Episodes Watched", Colors.cyanAccent),
        _activityChip(Icons.star, avg != null ? avg.toStringAsFixed(1) : "—", "Avg. Rating", Colors.amber),
        _activityChip(Icons.replay, "${provider.totalRewatches}", "Rewatches", Colors.lightGreenAccent),
      ],
    );
  }

  Widget _activityChip(IconData icon, String value, String label, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: TextStyle(color: color, fontFamily: 'Times', fontSize: 17, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(color: Colors.white54, fontFamily: 'Times', fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyUpdatedRow(MovieProvider provider) {
    return SizedBox(
      height: 215,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.recentlyUpdated.length,
        itemBuilder: (context, index) => MovieMiniCard(movie: provider.recentlyUpdated[index]),
      ),
    );
  }

  Widget _buildTopRatedRow(BuildContext context, MovieProvider provider) {
    const imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.topRatedByUser.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final movie = provider.topRatedByUser[index];
          return GestureDetector(
            onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movieId: movie.id, mediaType: movie.mediaType))),
            child: SizedBox(
              width: 120,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: movie.posterPath.isEmpty
                        ? Container(height: 170, width: 120, color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white38))
                        : Image.network(
                            '$imageBaseUrl${movie.posterPath}',
                            height: 170,
                            width: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(height: 170, width: 120, color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white38)),
                          ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(6)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(movie.userScore!.toStringAsFixed(0),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Times', fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyHint(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(Icons.explore, color: theme.colorScheme.secondary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "You haven't tracked anything yet. Add movies to your lists or rate them to see your stats here.",
              style: TextStyle(color: Colors.white70, fontFamily: 'Times', fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}