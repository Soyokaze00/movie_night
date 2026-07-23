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
  final PageController _heroController = PageController();
  int _heroPage = 0;

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
  void dispose() {
    _heroController.dispose();
    super.dispose();
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
                  _buildHeroCarousel(trending.take(5).toList(), theme),
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

  Widget _buildHeroCarousel(List<Movie> movies, ThemeData theme) {
    if (movies.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: _heroController,
            itemCount: movies.length,
            onPageChanged: (i) => setState(() => _heroPage = i),
            itemBuilder: (context, i) => _buildHeroCard(movies[i], theme),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(movies.length, (i) {
            final active = i == _heroPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? theme.colorScheme.secondary : Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeroCard(Movie movie, ThemeData theme) {
    const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
    final badge = movie.genres.isNotEmpty ? movie.genres.first : (movie.mediaType == 'tv' ? 'Anime' : 'Featured');
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movieId: movie.id, mediaType: movie.mediaType))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.secondary, theme.colorScheme.primary, Colors.orangeAccent],
          ),
          boxShadow: [
            BoxShadow(color: theme.colorScheme.secondary.withOpacity(0.3), blurRadius: 16, spreadRadius: 1),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              movie.posterPath.isEmpty
                  ? Container(color: Colors.white10)
                  : Image.network(
                      '$imageBaseUrl${movie.backdropPath.isNotEmpty ? movie.backdropPath : movie.posterPath}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.white10),
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.92), Colors.black.withOpacity(0.4), Colors.transparent],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.6)),
                      ),
                      child: Text(badge, style: TextStyle(color: theme.colorScheme.secondary, fontSize: 11, fontFamily: 'Times', fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    Text(movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Times')),
                    const SizedBox(height: 8),
                    if (movie.overview.isNotEmpty)
                      Text(
                        movie.overview,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Times', height: 1.35),
                      ),
                  ],
                ),
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
                child: Row(
                  children: [
                    Text("See All", style: TextStyle(color: const Color.fromARGB(255, 251, 92, 224).withValues(alpha: 0.9), fontSize: 14, fontFamily: 'Times')),
                    Icon(Icons.chevron_right, size: 16, color: const Color.fromARGB(255, 251, 92, 224).withValues(alpha: 0.9)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 210,
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
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.55)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.25), blurRadius: 10),
          ],
        ),
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