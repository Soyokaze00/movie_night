import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/app_drawer.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const AppDrawer(currentIndex: 4),
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
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 32, backgroundColor: theme.colorScheme.secondary.withOpacity(0.3), child: const Icon(Icons.person, color: Colors.white, size: 32)),
                    const SizedBox(width: 16),
                    const Text("Movie Fan", style: TextStyle(color: Colors.white, fontFamily: 'Times', fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text("Your Stats", style: TextStyle(color: Colors.white, fontFamily: 'Times', fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _statTile("Favorites", provider.favoriteMovies.length, Colors.pinkAccent),
                    _statTile("Watching", provider.watchingMovies.length, Colors.purpleAccent),
                    _statTile("Completed", provider.completedMovies.length, Colors.teal),
                  ],
                ),
              ],
            ),
          );
        },
      ),
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
}