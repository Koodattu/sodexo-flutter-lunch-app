import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A simple ChangeNotifier that manages a random WordPair and favorites.
class LunchAppState extends ChangeNotifier {
  var current = WordPair.random();

  // Holds the ordered list of favorite restaurant IDs (we'll use urlId as a unique key).
  List<String> _favorites = [];

  // Holds the category filter settings (category -> isVisible)
  Map<String, bool> _categoryFilters = {};

  List<String> get favorites => _favorites;
  Set<String> get favoritesSet => _favorites.toSet();
  Map<String, bool> get categoryFilters => Map.unmodifiable(_categoryFilters);

  LunchAppState() {
    _loadFavoritesFromPrefs();
    _loadCategoryFiltersFromPrefs();
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  /// Toggles a restaurant's favorite status.
  /// If it's already favorited, remove it. If not, add it to the end of the list.
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

  /// Reorders the favorites list to a new order.
  /// Used by the reorder dialog to change the order of favorites.
  Future<void> reorderFavorites(List<String> newOrder) async {
    _favorites = List<String>.from(newOrder);
    notifyListeners();
    await _saveFavoritesToPrefs();
  }

  /// Updates category filter settings.
  Future<void> updateCategoryFilters(Map<String, bool> newFilters) async {
    _categoryFilters = Map<String, bool>.from(newFilters);
    notifyListeners();
    await _saveCategoryFiltersToPrefs();
  }

  /// Checks if a category should be visible based on filter settings.
  bool isCategoryVisible(String category) {
    // Clean the category using the same logic as CourseCard
    String cleaned = category;
    cleaned = cleaned.replaceAll(RegExp(r'\d+'), '');
    if (cleaned.contains('(')) {
      cleaned = cleaned.split('(')[0];
    }
    cleaned = cleaned.trim().toUpperCase();

    // Default to visible if not in filter map
    return _categoryFilters[cleaned] ?? true;
  }

  /// Loads favorites from SharedPreferences on startup.
  Future<void> _loadFavoritesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedFavorites = prefs.getStringList('favorites');
    if (storedFavorites != null) {
      _favorites = storedFavorites;
    }
    notifyListeners();
  }

  /// Persists current favorites to SharedPreferences.
  Future<void> _saveFavoritesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
  }

  /// Loads category filters from SharedPreferences on startup.
  Future<void> _loadCategoryFiltersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, bool> storedFilters = {};
    final keys = prefs.getKeys().where((key) => key.startsWith('category_filter_'));
    for (final key in keys) {
      final categoryName = key.replaceFirst('category_filter_', '');
      storedFilters[categoryName] = prefs.getBool(key) ?? true;
    }
    if (storedFilters.isNotEmpty) {
      _categoryFilters = storedFilters;
    }
    notifyListeners();
  }

  /// Persists current category filters to SharedPreferences.
  Future<void> _saveCategoryFiltersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear existing category filter keys
    final keys = prefs.getKeys().where((key) => key.startsWith('category_filter_'));
    for (final key in keys) {
      await prefs.remove(key);
    }

    // Save current filters
    for (final entry in _categoryFilters.entries) {
      await prefs.setBool('category_filter_${entry.key}', entry.value);
    }
  }
}
