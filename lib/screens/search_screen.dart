import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/poster_grid_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // debounce می‌زنه تا هر بار که تایپ می‌کنی سریعاً درخواست نره سمت سرور
  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      Provider.of<MovieProvider>(context, listen: false).searchMovies(query);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          style: const TextStyle(color: Colors.white, fontFamily: 'Times'),
          decoration: InputDecoration(
            hintText: 'Search movies & anime...',
            hintStyle: const TextStyle(color: Colors.white38, fontFamily: 'Times'),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _controller.clear();
                      Provider.of<MovieProvider>(context, listen: false).clearSearch();
                      setState(() {});
                    },
                  )
                : null,
          ),
        ),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          if (provider.isSearching) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.secondary));
          }
          if (provider.searchError != null) {
            return Center(child: Text(provider.searchError!, style: const TextStyle(color: Colors.white70, fontFamily: 'Times')));
          }
          if (_controller.text.trim().isEmpty) {
            return const Center(child: Text("Write something to search :)", style: TextStyle(color: Colors.white38, fontFamily: 'Times')));
          }
          if (provider.searchResults.isEmpty) {
            return const Center(child: Text("No result found :(", style: TextStyle(color: Colors.white38, fontFamily: 'Times')));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.55,
            ),
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) => PosterGridTile(movie: provider.searchResults[index]),
          );
        },
      ),
    );
  }
}