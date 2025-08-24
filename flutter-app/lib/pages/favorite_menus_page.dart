import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/restaurant.dart';
import '../providers/lunch_app_state.dart';
import '../services/menu_service.dart';
import '../widgets/favorites_header.dart';
import '../widgets/custom_tab_bar.dart';
import '../widgets/weekly_menu_list.dart';
import '../widgets/menu_state_builder.dart';

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
        _menuCache[jsonId] = menuData;
      }
    }
    setState(() {});
  }

  Future<void> _refreshMenu(String jsonId) async {
    setState(() {
      _refreshingMenus.add(jsonId);
    });

    try {
      final menuData = await MenuService.fetchMenuWithFallback(jsonId);
      setState(() {
        _menuCache[jsonId] = menuData;
        _refreshingMenus.remove(jsonId);
      });
    } catch (e) {
      setState(() {
        _refreshingMenus.remove(jsonId);
      });
    }
  }

  void _ensureFavoriteMenusLoaded(List<Restaurant> favoriteRestaurants) {
    for (final restaurant in favoriteRestaurants) {
      final jsonId = restaurant.jsonId ?? '';
      if (jsonId.isNotEmpty && !_menuCache.containsKey(jsonId)) {
        // Load menu asynchronously without blocking the UI
        MenuService.fetchMenuWithFallback(jsonId).then((menuData) {
          if (mounted) {
            setState(() {
              _menuCache[jsonId] = menuData;
            });
          }
        });
      }
    }
  }

  void _handleRefresh() async {
    final favorites = Provider.of<LunchAppState>(context, listen: false).favorites;
    final favoriteRestaurants = _allRestaurants.where((r) => favorites.contains(r.urlId)).toList();

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

  @override
  Widget build(BuildContext context) {
    // Listen to the favorites changes in the provider.
    final favorites = Provider.of<LunchAppState>(context).favorites;
    // Filter the loaded restaurants based on the current favorites.
    final favoriteRestaurants = _allRestaurants.where((r) => favorites.contains(r.urlId)).toList();

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
              FavoritesHeader(onRefresh: _handleRefresh),
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
              FavoritesHeader(onRefresh: _handleRefresh),
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
            FavoritesHeader(onRefresh: _handleRefresh),
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

                  return MenuStateBuilder(
                    isLoading: isRefreshing || cachedMenu == null,
                    hasError: false,
                    isEmpty: !isRefreshing && (cachedMenu == null || cachedMenu.isEmpty),
                    errorMessage: "Ruokalistan lataaminen epäonnistui.",
                    emptyMessage: "Ei ruokalistaa saatavilla.",
                    contentBuilder: () => WeeklyMenuList(menuData: cachedMenu!),
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
