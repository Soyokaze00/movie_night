import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/app_drawer.dart';
import 'list_screen.dart';

class ListsTab extends StatelessWidget {
  const ListsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const AppDrawer(currentIndex: 3),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),
        ),
        title: const Text("My Lists", style: TextStyle(color: Colors.white, fontFamily: 'Times', fontWeight: FontWeight.bold)),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          final items = [
            _ListInfo("Favorites", provider.favoriteMovies.length, Colors.pinkAccent, Icons.favorite, MovieListType.favorites),
            _ListInfo("Watching", provider.watchingMovies.length, Colors.purpleAccent, Icons.play_circle_fill, MovieListType.watching),
            _ListInfo("On Hold", provider.onHoldMovies.length, Colors.orange, Icons.pause_circle_filled, MovieListType.onHold),
            _ListInfo("Completed", provider.completedMovies.length, Colors.teal, Icons.check_circle, MovieListType.completed),
            _ListInfo("Plan to Watch", provider.planToWatchMovies.length, Colors.blueAccent, Icons.bookmark, MovieListType.planToWatch),
            _ListInfo("Dropped", provider.droppedMovies.length, Colors.redAccent, Icons.cancel, MovieListType.dropped),
          ];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final info = items[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieListScreen(type: info.type))),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: info.color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Icon(info.icon, color: info.color, size: 28),
                      const SizedBox(width: 14),
                      Expanded(child: Text(info.label, style: const TextStyle(color: Colors.white, fontFamily: 'Times', fontSize: 16, fontWeight: FontWeight.bold))),
                      Text('${info.count}', style: TextStyle(color: info.color, fontFamily: 'Times', fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, color: Colors.white24),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ListInfo {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final MovieListType type;
  _ListInfo(this.label, this.count, this.color, this.icon, this.type);
}