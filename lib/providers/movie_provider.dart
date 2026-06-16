import 'package:flutter/material.dart';
import '../data/models/movie_model.dart';
import '../data/services/api_service.dart'; 

class MovieProvider with ChangeNotifier {
  final ApiService _apiService = ApiService(); 

  List<Movie> _trendingMovies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Movie> get trendingMovies => _trendingMovies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTrendingMovies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); 

    try {
      _trendingMovies = await _apiService.getTrendingMovies();
      _errorMessage = null; 
    } catch (e) {
      _errorMessage = 'Failed to load movies: ${e.toString()}'; 
      _trendingMovies = []; 
    } finally {
      _isLoading = false; 
      notifyListeners(); 
    }
  }

  void updateMovieStatus(int movieId, String newStatus) {
    try {
      for (var movie in _trendingMovies) {
        if (movie.id == movieId) {
          movie.status = newStatus;
          break; 
        }
      }
      notifyListeners(); 
    } catch (e) {
      print("Error updating movie status: $e");
    }
  }
}
