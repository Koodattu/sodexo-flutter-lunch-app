import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/restaurant.dart';
import '../providers/lunch_app_state.dart';
import '../services/menu_service.dart';
import '../widgets/favorites_header.dart';
import '../widgets/custom_tab_bar.dart';
import '../widgets/menu_tab_view.dart';
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
  int _refreshKey = 0;
  Map<String, ValueNotifier<int>> _tabNotifiers = {};

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    // Dispose all ValueNotifiers
    for (var notifier in _tabNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  void _updateTabController(int length) {
    _tabController?.dispose();
    if (length >= 2) {
      _tabController = TabController(length: length, vsync: this);
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
  }

  void _handleRefresh() {
    final favorites = Provider.of<LunchAppState>(context, listen: false).favorites;
    final favoriteRestaurants = _allRestaurants.where((r) => favorites.contains(r.urlId)).toList();

    if (favoriteRestaurants.isNotEmpty) {
      if (favoriteRestaurants.length == 1) {
        // Single tab case - refresh entire page
        setState(() {
          _refreshKey++;
        });
      } else {
        // Multiple tabs case - use ValueNotifier to avoid full rebuild
        final currentIndex = _tabController?.index ?? 0;
        if (currentIndex < favoriteRestaurants.length) {
          final restaurantJsonId = favoriteRestaurants[currentIndex].jsonId ?? '';

          // Initialize notifier if it doesn't exist
          if (!_tabNotifiers.containsKey(restaurantJsonId)) {
            _tabNotifiers[restaurantJsonId] = ValueNotifier<int>(0);
          }

          // Update the notifier (this will trigger rebuild of only the listening widget)
          _tabNotifiers[restaurantJsonId]!.value = _tabNotifiers[restaurantJsonId]!.value + 1;
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

    // Update tab controller when favorites change
    _updateTabController(favoriteRestaurants.length);

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

    // Single favorite - show as before
    if (favoriteRestaurants.length == 1) {
      final restaurant = favoriteRestaurants[0];
      return SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 17, 17, 17),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FavoritesHeader(onRefresh: _handleRefresh),
              // Restaurant header.
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  restaurant.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              // Weekly menu for the restaurant.
              Expanded(
                child: FutureBuilder<Map<String, dynamic>?>(
                  key: ValueKey(_refreshKey),
                  future: MenuService.fetchMenuWithFallback(restaurant.jsonId ?? ''),
                  builder: (context, menuSnapshot) {
                    return MenuStateBuilder(
                      isLoading: menuSnapshot.connectionState != ConnectionState.done,
                      hasError: false,
                      isEmpty:
                          !menuSnapshot.hasData || menuSnapshot.data == null || (menuSnapshot.data?.isEmpty ?? true),
                      errorMessage: "No menu available.",
                      emptyMessage: "No menu available.",
                      contentBuilder: () => WeeklyMenuList(menuData: menuSnapshot.data!),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Multiple favorites - show with tabs
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

                  // Initialize notifier if it doesn't exist
                  if (!_tabNotifiers.containsKey(restaurantJsonId)) {
                    _tabNotifiers[restaurantJsonId] = ValueNotifier<int>(0);
                  }

                  return MenuTabView(
                    restaurantJsonId: restaurantJsonId,
                    refreshNotifier: _tabNotifiers[restaurantJsonId]!,
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
