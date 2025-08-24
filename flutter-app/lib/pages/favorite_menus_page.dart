import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/restaurant.dart';
import '../providers/lunch_app_state.dart';
import '../services/menu_service.dart';
import '../widgets/favorites_header.dart';
import '../widgets/custom_tab_bar.dart';
import '../widgets/filtered_weekly_menu_list.dart';
import '../widgets/menu_state_builder.dart';
import '../widgets/reorder_favorites_dialog.dart';
import '../widgets/category_filter_dialog.dart';

class FavoriteMenusPage extends StatefulWidget {
  const FavoriteMenusPage({super.key});
  @override
  State<FavoriteMenusPage> createState() => _FavoriteMenusPageState();
}

class _FavoriteMenusPageState extends State<FavoriteMenusPage> with TickerProviderStateMixin {
  List<Restaurant> _allRestaurants = [];
  bool _isLoading = true;
  TabController? _tabController;
  final Map<String, Map<String, dynamic>?> _menuCache = {};
  final Set<String> _refreshingMenus = {};
  final Set<String> _errorMenus = {};
  Set<String> _previousFavorites = {};
  int _previousTabCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _updateTabController(int length) {
    final currentIndex = _tabController?.index ?? 0;
    _tabController?.dispose();
    if (length >= 1) {
      _tabController = TabController(
        length: length,
        vsync: this,
        initialIndex: currentIndex < length ? currentIndex : 0,
      );
    } else {
      _tabController = null;
    }
  }

  Future<void> _loadRestaurants() async {
    final String jsonString = await rootBundle.loadString('assets/sodexo_restaurants.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);
    List<Restaurant> restaurants = jsonResponse.map((data) => Restaurant.fromJson(data)).toList();
    setState(() {
      _allRestaurants = restaurants;
      _isLoading = false;
    });

    // Pre-load menus for favorite restaurants
    _loadFavoriteMenus();
  }

  Future<void> _loadFavoriteMenus() async {
    final favorites = Provider.of<LunchAppState>(context, listen: false).favorites;
    final favoriteRestaurants = _allRestaurants.where((r) => favorites.contains(r.urlId)).toList();

    for (final restaurant in favoriteRestaurants) {
      final jsonId = restaurant.jsonId ?? '';
      if (jsonId.isNotEmpty && !_menuCache.containsKey(jsonId)) {
        final menuData = await MenuService.fetchMenuWithFallback(jsonId);
        if (menuData != null) {
          // menuData can be either valid data or empty map {}
          _menuCache[jsonId] = menuData;
          _errorMenus.remove(jsonId);
        } else {
          // null indicates an error occurred
          _menuCache[jsonId] = {};
          _errorMenus.add(jsonId);
        }
      }
    }
    setState(() {});
  }

  Future<void> _refreshMenu(String jsonId) async {
    setState(() {
      _refreshingMenus.add(jsonId);
      _errorMenus.remove(jsonId);
    });

    final menuData = await MenuService.fetchMenuWithFallback(jsonId);
    setState(() {
      if (menuData != null) {
        // menuData can be either valid data or empty map {}
        _menuCache[jsonId] = menuData;
        _refreshingMenus.remove(jsonId);
      } else {
        // null indicates an error occurred
        _menuCache[jsonId] = {};
        _errorMenus.add(jsonId);
        _refreshingMenus.remove(jsonId);
      }
    });
  }

  void _ensureFavoriteMenusLoaded(List<Restaurant> favoriteRestaurants) {
    for (final restaurant in favoriteRestaurants) {
      final jsonId = restaurant.jsonId ?? '';
      if (jsonId.isNotEmpty && !_menuCache.containsKey(jsonId)) {
        // Load menu asynchronously without blocking the UI
        MenuService.fetchMenuWithFallback(jsonId).then((menuData) {
          if (mounted) {
            setState(() {
              if (menuData != null) {
                // menuData can be either valid data or empty map {}
                _menuCache[jsonId] = menuData;
                _errorMenus.remove(jsonId);
              } else {
                // null indicates an error occurred
                _menuCache[jsonId] = {};
                _errorMenus.add(jsonId);
              }
            });
          }
        });
      }
    }
  }

  void _handleRefresh() async {
    final favorites = Provider.of<LunchAppState>(context, listen: false).favorites;
    // Use the same ordering logic as in build method to maintain consistency
    final favoriteRestaurants = favorites
        .map((urlId) {
          try {
            return _allRestaurants.firstWhere((r) => r.urlId == urlId);
          } catch (e) {
            return null;
          }
        })
        .where((restaurant) => restaurant != null)
        .cast<Restaurant>()
        .toList();

    if (favoriteRestaurants.isNotEmpty) {
      // Refresh current tab's menu
      final currentIndex = _tabController?.index ?? 0;
      if (currentIndex < favoriteRestaurants.length) {
        final jsonId = favoriteRestaurants[currentIndex].jsonId ?? '';
        if (jsonId.isNotEmpty) {
          await _refreshMenu(jsonId);
        }
      }
    }
  }

  void _handleReorder() {
    final appState = Provider.of<LunchAppState>(context, listen: false);
    final favoriteRestaurants = appState.favorites
        .map((urlId) {
          try {
            return _allRestaurants.firstWhere((r) => r.urlId == urlId);
          } catch (e) {
            return null;
          }
        })
        .where((restaurant) => restaurant != null)
        .cast<Restaurant>()
        .toList();

    if (favoriteRestaurants.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => ReorderFavoritesDialog(
          favoriteRestaurants: favoriteRestaurants,
          onReorder: (newOrder) {
            appState.reorderFavorites(newOrder);
          },
        ),
      );
    }
  }

  void _handleFilter() {
    final appState = Provider.of<LunchAppState>(context, listen: false);
    final availableCategories = _collectAvailableCategories();

    if (availableCategories.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => CategoryFilterDialog(
          availableCategories: availableCategories,
          currentFilters: appState.categoryFilters,
          onFiltersChanged: (newFilters) {
            appState.updateCategoryFilters(newFilters);
          },
        ),
      );
    } else {
      // Show snackbar if no categories are available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ei kategorioita saatavilla suodatettavaksi'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Collects unique categories from all cached menus
  Set<String> _collectAvailableCategories() {
    final Set<String> categories = {};

    for (final menuData in _menuCache.values) {
      if (menuData != null && menuData.isNotEmpty) {
        // Handle both weekly and daily menu formats
        if (menuData.containsKey('mealdates')) {
          // Weekly menu format
          final List<dynamic> mealdates = menuData['mealdates'];
          for (final dayData in mealdates) {
            final courses = dayData['courses'] as Map<String, dynamic>?;
            if (courses != null) {
              _extractCategoriesFromCourses(courses, categories);
            }
          }
        } else if (menuData.containsKey('courses')) {
          // Daily menu format
          final courses = menuData['courses'];
          if (courses is Map<String, dynamic>) {
            _extractCategoriesFromCourses(courses, categories);
          } else if (courses is List) {
            // Handle list format from daily API
            for (int i = 0; i < courses.length; i++) {
              final course = courses[i] as Map<String, dynamic>?;
              if (course != null && course['category'] != null) {
                categories.add(_cleanCategory(course['category'].toString()));
              }
            }
          }
        }
      }
    }

    return categories;
  }

  /// Extracts categories from courses map and adds them to the categories set
  void _extractCategoriesFromCourses(Map<String, dynamic> courses, Set<String> categories) {
    for (final courseEntry in courses.entries) {
      final course = courseEntry.value as Map<String, dynamic>?;
      if (course != null && course['category'] != null) {
        categories.add(_cleanCategory(course['category'].toString()));
      }
    }
  }

  /// Cleans up category text by removing numbers and text in parentheses
  /// Uses the same logic as CourseCard for consistency
  String _cleanCategory(String category) {
    String cleaned = category;

    // Remove numbers
    cleaned = cleaned.replaceAll(RegExp(r'\d+'), '');

    // Split at first opening parenthesis and take only the first part
    if (cleaned.contains('(')) {
      cleaned = cleaned.split('(')[0];
    }

    // Trim whitespace and convert to uppercase
    return cleaned.trim().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the favorites changes in the provider.
    final appState = Provider.of<LunchAppState>(context);
    final favorites = appState.favorites;
    // Filter the loaded restaurants based on the current favorites and maintain order.
    final favoriteRestaurants = favorites
        .map((urlId) {
          try {
            return _allRestaurants.firstWhere((r) => r.urlId == urlId);
          } catch (e) {
            return null;
          }
        })
        .where((restaurant) => restaurant != null)
        .cast<Restaurant>()
        .toList();

    // Update tab controller only when the tab count changes
    final currentTabCount = favoriteRestaurants.length;
    if (currentTabCount != _previousTabCount) {
      _updateTabController(currentTabCount);
      _previousTabCount = currentTabCount;
    }

    // Only load menus for new favorites if the favorites set has actually changed
    final currentFavorites = favorites.toSet();
    if (!_previousFavorites.containsAll(currentFavorites) || !currentFavorites.containsAll(_previousFavorites)) {
      _previousFavorites = currentFavorites;
      // Load menus for any new favorite restaurants (but don't call setState here)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureFavoriteMenusLoaded(favoriteRestaurants);
      });
    }

    if (_isLoading) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 17, 17, 17),
          body: Column(
            children: [
              FavoritesHeader(onRefresh: _handleRefresh, onReorder: _handleReorder, onFilter: _handleFilter),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      );
    }

    if (favoriteRestaurants.isEmpty) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 17, 17, 17),
          body: Column(
            children: [
              FavoritesHeader(onRefresh: _handleRefresh), // No reorder or filter when empty
              const Expanded(
                child: Center(
                  child: Text(
                    "You have no favorite restaurants.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show with tabs (works for both single and multiple favorites)
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 17, 17, 17),
        body: Column(
          children: [
            FavoritesHeader(onRefresh: _handleRefresh, onReorder: _handleReorder, onFilter: _handleFilter),
            // Tab bar for restaurant names
            CustomTabBar(
              controller: _tabController,
              isScrollable: true,
              tabLabels: favoriteRestaurants.map((restaurant) => restaurant.name).toList(),
            ),
            // Tab view for restaurant content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: favoriteRestaurants.map((restaurant) {
                  final restaurantJsonId = restaurant.jsonId ?? '';
                  final cachedMenu = _menuCache[restaurantJsonId];
                  final isRefreshing = _refreshingMenus.contains(restaurantJsonId);
                  final hasError = _errorMenus.contains(restaurantJsonId);
                  final isLoading = isRefreshing || (!hasError && cachedMenu == null);
                  final isEmpty = !isRefreshing && !hasError && cachedMenu != null && cachedMenu.isEmpty;

                  return MenuStateBuilder(
                    isLoading: isLoading,
                    hasError: hasError,
                    isEmpty: isEmpty,
                    errorMessage: "Ruokalistan lataaminen epäonnistui.",
                    emptyMessage:
                        "Tälle ravintolalle ei ole saatavilla ruokalistaa tällä hetkellä. Tarkista myöhemmin uudelleen tai kokeile ravintolan omaa verkkosivustoa.",
                    contentBuilder: () => FilteredWeeklyMenuList(menuData: cachedMenu!),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
