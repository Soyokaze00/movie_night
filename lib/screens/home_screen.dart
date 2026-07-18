import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../data/models/movie_model.dart';
import '../widgets/movie_mini_card.dart';
import '../widgets/app_drawer.dart';
import 'list_screen.dart';
import 'movie_detail_screen.dart';
import 'see_all_screen.dart';
import 'search_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MovieProvider>(context, listen: false);
      provider.fetchHomeData();
      // provider.fetchAnimeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      drawer: const AppDrawer(currentIndex: 0),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 226, 8, 8),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: 'Movie', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Times')),
              TextSpan(text: 'Night', style: TextStyle(color: theme.colorScheme.secondary, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Times')),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.secondary));
          }
          if (movieProvider.errorMessage != null) {
            return Center(child: Text(movieProvider.errorMessage!, style: const TextStyle(color: Colors.white70)));
          }

          final trending = movieProvider.trendingMovies;
          if (trending.isEmpty) return const Center(child: Text("No Movies Found", style: TextStyle(color: Colors.white)));

          return RefreshIndicator(
            onRefresh: () async {
              await movieProvider.fetchHomeData();
              // await movieProvider.fetchAnimeData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeaturedSection(trending[0], theme),
                  _buildMovieRow("Trending Now", trending),
                  _buildMovieRow("Popular Movies", movieProvider.popularMovies),
                  // if (movieProvider.isAnimeLoading && movieProvider.airingAnime.isEmpty)
                  //   const Padding(
                  //     padding: EdgeInsets.symmetric(vertical: 20),
                  //     child: Center(child: CircularProgressIndicator(color: Colors.white54)),
                  //   )
                  // else ...[
                  //   _buildMovieRow("Airing Anime", movieProvider.airingAnime),
                  //   _buildMovieRow("All Time Popular Anime", movieProvider.popularAnime),
                  // ],
                  _buildMyLists(theme, movieProvider),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

Widget _buildFeaturedSection(Movie movie, ThemeData theme) {
    const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movieId: movie.id, mediaType: movie.mediaType))),
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white10,
          image: movie.posterPath.isEmpty
              ? null
              : DecorationImage(image: NetworkImage('$imageBaseUrl${movie.posterPath}'), fit: BoxFit.cover, onError: (_, __) {}),
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
              Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Times')),
              const SizedBox(height: 8),
              if (movie.overview.isNotEmpty)
                Text(
                  movie.overview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Times', height: 1.3),
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMovieRow(String title, List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Times', fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SeeAllScreen(title: title, movies: movies))),
                child: Text("See All >", style: TextStyle(color: const Color.fromARGB(255, 251, 92, 224).withOpacity(0.8), fontSize: 14, fontFamily: 'Times')),
              ),
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

  Widget _buildMyLists(ThemeData theme, MovieProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text("My Lists", style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Times', fontWeight: FontWeight.bold)),
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
            _listTile("Favorites", provider.favoriteMovies.length, Colors.pinkAccent, Icons.favorite, MovieListType.favorites),
            _listTile("Watching", provider.watchingMovies.length, Colors.purple, Icons.play_circle_fill, MovieListType.watching),
            _listTile("On Hold", provider.onHoldMovies.length, Colors.orange, Icons.pause_circle_filled, MovieListType.onHold),
            _listTile("Completed", provider.completedMovies.length, Colors.teal, Icons.check_circle, MovieListType.completed),
            _listTile("Plan to Watch", provider.planToWatchMovies.length, Colors.blue, Icons.bookmark, MovieListType.planToWatch),
            _listTile("Dropped", provider.droppedMovies.length, Colors.red, Icons.cancel, MovieListType.dropped),
          ],
        ),
      ],
    );
  }

  Widget _listTile(String label, int count, Color color, IconData icon, MovieListType type) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieListScreen(type: type))),
      child: Container(
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
                Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'Times', fontSize: 15, fontWeight: FontWeight.bold)),
                Text('$count', style: const TextStyle(color: Colors.white70, fontFamily: 'Times', fontSize: 13)),
              ],
            )
          ],
        ),
      ),
    );
  }
}