import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../data/models/movie_model.dart';
import '../widgets/movie_mini_card.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;
  final String mediaType;
  const MovieDetailScreen({super.key, required this.movieId, this.mediaType = 'movie'});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false)
          .fetchMovieDetail(widget.movieId, mediaType: widget.mediaType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          final movie = provider.getCachedMovie(widget.movieId, mediaType: widget.mediaType);

          if (movie == null && provider.isDetailLoading) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.secondary));
          }
          if (movie == null) {
            return Center(child: Text(provider.detailError ?? "فیلم پیدا نشد", style: const TextStyle(color: Colors.white)));
          }

          final recommendations = provider.recommendations.where((m) => m.id != movie.id).toList();

          return CustomScrollView(
            slivers: [
              _buildAppBar(movie),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.title,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Times')),
                      const SizedBox(height: 8),
                      _buildMetaRow(movie),
                      const SizedBox(height: 16),
                      if (movie.overview.isNotEmpty) ...[
                        Text(movie.overview, style: const TextStyle(color: Colors.white70, fontFamily: 'Times', height: 1.4)),
                        const SizedBox(height: 16),
                      ],
                      if (movie.director != null) ...[
                        Text("Director",
                            style: TextStyle(color: theme.colorScheme.secondary, fontFamily: 'Times', fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(movie.director!, style: const TextStyle(color: Colors.white70, fontFamily: 'Times')),
                        const SizedBox(height: 16),
                      ],
                      if (movie.cast.isNotEmpty) ...[
                        Text("Cast",
                            style: TextStyle(color: theme.colorScheme.secondary, fontFamily: 'Times', fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(movie.cast.join(', '), style: const TextStyle(color: Colors.white70, fontFamily: 'Times')),
                        const SizedBox(height: 20),
                      ],
                      Text("Add to List",
                          style: TextStyle(color: theme.colorScheme.secondary, fontFamily: 'Times', fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _buildAddToListRow(movie, provider),
                      const SizedBox(height: 20),
                      Text("Your Score",
                          style: TextStyle(color: theme.colorScheme.secondary, fontFamily: 'Times', fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _buildScoreRow(movie, provider),
                      if (movie.mediaType == 'tv') ...[
                        const SizedBox(height: 20),
                        Text("Episode Progress",
                            style: TextStyle(color: theme.colorScheme.secondary, fontFamily: 'Times', fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildEpisodeProgress(movie, provider, theme),
                      ],
                      if (recommendations.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text("You May Also Like",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Times', fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                ),
              ),
              if (recommendations.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 210,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: recommendations.length,
                      itemBuilder: (context, index) => MovieMiniCard(movie: recommendations[index]),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(Movie movie) {
    const imageBaseUrl = 'https://image.tmdb.org/t/p/w780';
    final backdrop = movie.backdropPath.isNotEmpty ? movie.backdropPath : movie.posterPath;
    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: 320,
      pinned: true,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      // actions: const [Icon(Icons.share, color: Colors.white), SizedBox(width: 16)],
      flexibleSpace: FlexibleSpaceBar(
        background: backdrop.isEmpty
            ? Container(color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white24, size: 64))
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    '$imageBaseUrl$backdrop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.white10, child: const Icon(Icons.movie, color: Colors.white24, size: 64)),
                    loadingBuilder: (context, child, progress) => progress == null ? child : Container(color: Colors.white10),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMetaRow(Movie movie) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 4),
          Text(movie.voteAverage.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white, fontFamily: 'Times', fontWeight: FontWeight.bold)),
        ]),
        if (movie.year != '—') Text(movie.year, style: const TextStyle(color: Colors.white70, fontFamily: 'Times')),
        if (movie.runtimeLabel.isNotEmpty) Text(movie.runtimeLabel, style: const TextStyle(color: Colors.white70, fontFamily: 'Times')),
        if (movie.genres.isNotEmpty) Text(movie.genres.join(', '), style: const TextStyle(color: Colors.white70, fontFamily: 'Times')),
        if (movie.mediaType == 'tv')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
            child: const Text("Anime/TV", style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'Times')),
          ),
      ],
    );
  }

  Widget _buildAddToListRow(Movie movie, MovieProvider provider) {
    Widget chip(String label, IconData icon, bool active, VoidCallback onTap, Color color) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.25) : Colors.white10,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? color : Colors.white24),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: active ? color : Colors.white70),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: active ? color : Colors.white70, fontFamily: 'Times', fontSize: 12)),
          ]),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        chip("Favorite", Icons.favorite, movie.isFavorite,
            () => provider.toggleFavorite(movie.id, mediaType: movie.mediaType), Colors.pinkAccent),
        chip("Watching", Icons.play_circle_fill, movie.status == 'watching',
            () => provider.setStatus(movie.id, 'watching', mediaType: movie.mediaType), Colors.purpleAccent),
        chip("On Hold", Icons.pause_circle_filled, movie.status == 'onHold',
            () => provider.setStatus(movie.id, 'onHold', mediaType: movie.mediaType), Colors.orange),
        chip("Completed", Icons.check_circle, movie.status == 'completed',
            () => provider.setStatus(movie.id, 'completed', mediaType: movie.mediaType), Colors.teal),
        chip("Dropped", Icons.cancel, movie.status == 'dropped',
            () => provider.setStatus(movie.id, 'dropped', mediaType: movie.mediaType), Colors.redAccent),
        chip("Plan to Watch", Icons.bookmark, movie.status == 'planToWatch',
            () => provider.setStatus(movie.id, 'planToWatch', mediaType: movie.mediaType), Colors.blueAccent),
      ],
    );
  }

  Widget _buildScoreRow(Movie movie, MovieProvider provider) {
    return Row(
      children: [
        ...List.generate(10, (i) {
          final starValue = i + 1;
          final filled = (movie.userScore ?? 0) >= starValue;
          return GestureDetector(
            onTap: () => provider.setScore(
              movie.id,
              movie.userScore == starValue.toDouble() ? null : starValue.toDouble(),
              mediaType: movie.mediaType,
            ),
            child: Icon(filled ? Icons.star : Icons.star_border, color: Colors.amber, size: 22),
          );
        }),
        const SizedBox(width: 10),
        Text(
          movie.userScore != null ? '${movie.userScore!.toStringAsFixed(0)}/10' : 'Not rated',
          style: const TextStyle(color: Colors.white70, fontFamily: 'Times'),
        ),
      ],
    );
  }

  Widget _buildEpisodeProgress(Movie movie, MovieProvider provider, ThemeData theme) {
    final total = movie.totalEpisodes;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
          onPressed: () => provider.decrementEpisode(movie.id, mediaType: movie.mediaType),
        ),
        Text(
          total != null ? '${movie.episodesWatched} / $total' : '${movie.episodesWatched}',
          style: const TextStyle(color: Colors.white, fontFamily: 'Times', fontWeight: FontWeight.bold, fontSize: 16),
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.secondary),
          onPressed: () => provider.incrementEpisode(movie.id, mediaType: movie.mediaType),
        ),
        const Spacer(),
        if (total != null && total > 0)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: movie.watchProgress,
                minHeight: 6,
                backgroundColor: Colors.white12,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
      ],
    );
  }
}