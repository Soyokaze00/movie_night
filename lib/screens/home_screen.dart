import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../data/models/movie_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).fetchTrendingMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF02020A), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: 'Movie', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              TextSpan(text: 'Night', style: TextStyle(color: theme.colorScheme.secondary, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        centerTitle: true,
        actions: const [Icon(Icons.search, color: Colors.white), SizedBox(width: 15)],
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.secondary));
          }

          final movies = movieProvider.trendingMovies;
          if (movies.isEmpty) return const Center(child: Text("No Movies Found"));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeaturedSection(movies[0], theme),
                _buildMovieRow("Trending Now", movies),
                _buildMovieRow("Popular Movies", movies.reversed.toList()),
                _buildMyLists(theme),
                
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  Widget _buildFeaturedSection(Movie movie, ThemeData theme) {
    const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
    return Container(
      margin: const EdgeInsets.all(16),
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage('$imageBaseUrl${movie.posterPath}'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.9), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: theme.colorScheme.secondary, borderRadius: BorderRadius.circular(8)),
              child: const Text("Featured", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text("Watch Trailer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMovieRow(String title, List<Movie> movies) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("See All >", style: TextStyle(color: Colors.blueAccent.withOpacity(0.8), fontSize: 14)),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) => MovieMiniCard(movie: movies[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildMyLists(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text("My Lists", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          childAspectRatio: 2.5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _listTile("Watching", "12", Colors.purple, Icons.play_circle_fill),
            _listTile("On Hold", "7", Colors.orange, Icons.pause_circle_filled),
            _listTile("Plan to Watch", "24", Colors.blue, Icons.bookmark),
            _listTile("Dropped", "5", Colors.red, Icons.cancel),
          ],
        ),
      ],
    );
  }

  Widget _listTile(String label, String count, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(count, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF02020A),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.secondary,
      unselectedItemColor: Colors.white54,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movies"),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Discover"),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: "Lists"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}

class MovieMiniCard extends StatelessWidget {
  final Movie movie;
  const MovieMiniCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network('$imageBaseUrl${movie.posterPath}', fit: BoxFit.cover),
      ),
    );
  }
}
