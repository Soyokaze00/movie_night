import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../data/models/movie_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/library_movie_tile.dart';

class ListsTab extends StatefulWidget {
  const ListsTab({super.key});

  @override
  State<ListsTab> createState() => _ListsTabState();
}

class _ListsTabState extends State<ListsTab> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<_TabInfo> _tabs = [
    _TabInfo("Favorites", Icons.favorite, Colors.pinkAccent),
    _TabInfo("Watching", Icons.play_circle_fill, Colors.purpleAccent),
    _TabInfo("On Hold", Icons.pause_circle_filled, Colors.orange),
    _TabInfo("Completed", Icons.check_circle, Colors.teal),
    _TabInfo("Plan to Watch", Icons.bookmark, Colors.blueAccent),
    _TabInfo("Dropped", Icons.cancel, Colors.redAccent),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _tabController.previousIndex) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Movie> _moviesFor(int index, MovieProvider provider) {
    switch (index) {
      case 0: return provider.favoriteMovies;
      case 1: return provider.watchingMovies;
      case 2: return provider.onHoldMovies;
      case 3: return provider.completedMovies;
      case 4: return provider.planToWatchMovies;
      case 5: return provider.droppedMovies;
    }
    return const [];
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
        title: const Text("My Lists", style: TextStyle(color: Colors.white, fontFamily: 'Times', fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            tooltip: "Custom lists",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Custom lists are coming soon"), backgroundColor: Color(0xFF1E1E1E)),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: _tabs[_tabController.index].color,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontFamily: 'Times', fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _tabs
              .map((t) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.icon, size: 16, color: t.color),
                        const SizedBox(width: 6),
                        Text(t.label),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: List.generate(_tabs.length, (index) {
              final movies = _moviesFor(index, provider);
              final info = _tabs[index];
              if (movies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(info.icon, color: Colors.white24, size: 48),
                      const SizedBox(height: 12),
                      const Text("Nothing added yet", style: TextStyle(color: Colors.white38, fontFamily: 'Times')),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) =>
                    LibraryMovieTile(movie: movies[i], color: info.color, showProgress: info.label == "Watching"),
              );
            }),
          );
        },
      ),
    );
  }
}

class _TabInfo {
  final String label;
  final IconData icon;
  final Color color;
  const _TabInfo(this.label, this.icon, this.color);
}