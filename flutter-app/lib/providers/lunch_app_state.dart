import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A simple ChangeNotifier that manages a random WordPair and favorites.
class LunchAppState extends ChangeNotifier {
  var current = WordPair.random();

  // Holds the set of favorite restaurant IDs (we'll use urlId as a unique key).
  Set<String> _favorites = {};

  Set<String> get favorites => _favorites;

  LunchAppState() {
    _loadFavoritesFromPrefs();
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  /// Toggles a restaurant's favorite status.
  /// If it’s already favorited, remove it. If not, add it.
  /// Persists changes in SharedPreferences.
  Future<void> toggleFavorite(String restaurantId) async {
    if (_favorites.contains(restaurantId)) {
      _favorites.remove(restaurantId);
    } else {
      _favorites.add(restaurantId);
    }
    notifyListeners();
    await _saveFavoritesToPrefs();
  }

  /// Checks if a restaurantId is in the favorites.
  bool isFavorite(String restaurantId) => _favorites.contains(restaurantId);

  /// Loads favorites from SharedPreferences on startup.
  Future<void> _loadFavoritesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedFavorites = prefs.getStringList('favorites');
    if (storedFavorites != null) {
      _favorites = storedFavorites.toSet();
    }
    notifyListeners();
  }

  /// Persists current favorites to SharedPreferences.
  Future<void> _saveFavoritesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites.toList());
  }
}
