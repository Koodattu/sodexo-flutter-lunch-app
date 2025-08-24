import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../models/restaurant.dart';
import '../providers/lunch_app_state.dart';
import '../widgets/course_card.dart';

class FavoriteMenusPage extends StatefulWidget {
  const FavoriteMenusPage({super.key});
  @override
  State<FavoriteMenusPage> createState() => _FavoriteMenusPageState();
}

class _FavoriteMenusPageState extends State<FavoriteMenusPage> with TickerProviderStateMixin {
  String _twoDigits(int n) => n.toString().padLeft(2, '0');
  List<Restaurant> _allRestaurants = [];
  bool _isLoading = true;
  TabController? _tabController;
  int _refreshKey = 0;
  Map<String, ValueNotifier<int>> _tabNotifiers = {};
  Map<String, Map<String, dynamic>?> _menuCache = {};

  /// Converts a List of courses to a Map format for consistency
  Map<String, dynamic>? _convertListToMap(dynamic coursesList) {
    if (coursesList == null || coursesList is! List || coursesList.isEmpty) {
      return null;
    }

    final Map<String, dynamic> coursesMap = {};
    for (int i = 0; i < coursesList.length; i++) {
      coursesMap[i.toString()] = coursesList[i];
    }
    return coursesMap;
  }

  /// Returns Finnish weekday name for given date
  String _getFinnishWeekdayName(DateTime date) {
    const weekdays = ['Maanantai', 'Tiistai', 'Keskiviikko', 'Torstai', 'Perjantai', 'Lauantai', 'Sunnuntai'];
    return weekdays[date.weekday - 1];
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Suosikit",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              final favorites = Provider.of<LunchAppState>(context, listen: false).favorites;
              final favoriteRestaurants = _allRestaurants.where((r) => favorites.contains(r.urlId)).toList();

              if (favoriteRestaurants.isNotEmpty) {
                if (favoriteRestaurants.length == 1) {
                  // Single tab case - clear cache and refresh
                  final restaurantJsonId = favoriteRestaurants[0].jsonId ?? '';
                  _menuCache.remove(restaurantJsonId);
                  setState(() {
                    _refreshKey++;
                  });
                } else {
                  // Multiple tabs case - use ValueNotifier to avoid full rebuild
                  final currentIndex = _tabController?.index ?? 0;
                  if (currentIndex < favoriteRestaurants.length) {
                    final restaurantJsonId = favoriteRestaurants[currentIndex].jsonId ?? '';

                    // Clear cache for this restaurant
                    _menuCache.remove(restaurantJsonId);

                    // Initialize notifier if it doesn't exist
                    if (!_tabNotifiers.containsKey(restaurantJsonId)) {
                      _tabNotifiers[restaurantJsonId] = ValueNotifier<int>(0);
                    }

                    // Update the notifier (this will trigger rebuild of only the listening widget)
                    _tabNotifiers[restaurantJsonId]!.value = _tabNotifiers[restaurantJsonId]!.value + 1;
                  }
                }
              }
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {}, // No functionality yet
            tooltip: 'Language',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {}, // No functionality yet
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.star, color: Colors.white),
            onPressed: () {}, // No functionality yet
            tooltip: 'Sort',
          ),
        ],
      ),
    );
  }

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

  Future<Map<String, dynamic>?> _fetchWeeklyMenu(String jsonId, {bool forceRefresh = false}) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh && _menuCache.containsKey(jsonId)) {
      return _menuCache[jsonId];
    }

    try {
      // First, try to fetch current week menu
      final response = await http.get(Uri.parse('https://www.sodexo.fi/ruokalistat/output/weekly_json/$jsonId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if current week menu is still valid
        if (data['mealdates'] != null && data['mealdates'].isNotEmpty) {
          final List<dynamic> mealdates = data['mealdates'];
          final DateTime now = DateTime.now();
          final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

          // Check if current date is after the last date in the week menu
          final DateTime lastDayOfWeek = startOfWeek.add(Duration(days: mealdates.length - 1));

          if (now.isAfter(lastDayOfWeek.add(const Duration(days: 1)))) {
            // Current week is expired, fetch next week menu
            final nextWeekData = await _fetchNextWeekMenuData(jsonId);
            if (nextWeekData != null) {
              _menuCache[jsonId] = nextWeekData;
              return nextWeekData;
            }
          }
        }

        // Cache and return current week data
        _menuCache[jsonId] = data;
        return data;
      }
    } catch (e) {
      // If current week fails, try next week
      final nextWeekData = await _fetchNextWeekMenuData(jsonId);
      if (nextWeekData != null) {
        _menuCache[jsonId] = nextWeekData;
        return nextWeekData;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchNextWeekMenuData(String jsonId) async {
    final List<Map<String, dynamic>> nextWeekMenu = [];
    final DateTime today = DateTime.now();
    final DateTime nextMonday = today.weekday == DateTime.monday
        ? today.add(const Duration(days: 7))
        : today.add(Duration(days: (8 - today.weekday) % 7));

    try {
      for (int i = 0; i < 5; i++) {
        final DateTime nextWeekDay = nextMonday.add(Duration(days: i));
        final String dateString = "${nextWeekDay.year}-${_twoDigits(nextWeekDay.month)}-${_twoDigits(nextWeekDay.day)}";

        final response = await http.get(
          Uri.parse(
            'https://www.sodexo.fi/ruokalistat/output/daily_json/$jsonId/$dateString',
          ),
        );

        if (response.statusCode == 200) {
          final decodedData = json.decode(response.body);
          nextWeekMenu.add(decodedData);
        } else {
          nextWeekMenu.add({});
        }
      }

      // Convert next week data to the same format as current week data
      final List<Map<String, dynamic>> mealdates = [];
      for (int i = 0; i < nextWeekMenu.length; i++) {
        final dayData = nextWeekMenu[i];
        final DateTime currentDayDate = nextMonday.add(Duration(days: i));
        final String dayName = _getFinnishWeekdayName(currentDayDate);

        // Handle the different data structure for next week (daily API returns List instead of Map)
        final courses = dayData['courses'] is List
            ? _convertListToMap(dayData['courses'])
            : dayData['courses'] as Map<String, dynamic>?;

        mealdates.add({
          'date': dayName,
          'courses': courses ?? {},
        });
      }

      return {
        'mealdates': mealdates,
        'isNextWeek': true, // Flag to indicate this is next week data
      };
    } catch (error) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getMenuForRestaurant(String restaurantJsonId, int refreshKey) async {
    // If cache is empty (first time) or refreshKey changed (refresh was pressed), fetch new data
    return _fetchWeeklyMenu(restaurantJsonId);
  }

  Widget _buildWeeklyMenu(Map<String, dynamic> menuData) {
    final List<dynamic> mealdates = menuData['mealdates'];
    final bool isNextWeek = menuData['isNextWeek'] ?? false;

    // Calculate the correct start date based on whether this is next week data
    final DateTime startOfWeek;
    if (isNextWeek) {
      final DateTime today = DateTime.now();
      startOfWeek = today.weekday == DateTime.monday
          ? today.add(const Duration(days: 7))
          : today.add(Duration(days: (8 - today.weekday) % 7));
    } else {
      startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: mealdates.length,
      itemBuilder: (context, dayIndex) {
        final dayData = mealdates[dayIndex];
        final DateTime currentDayDate = startOfWeek.add(Duration(days: dayIndex));
        final String dayName = dayData['date'];
        final String dayDate =
            "${_twoDigits(currentDayDate.day)}.${_twoDigits(currentDayDate.month)}.${currentDayDate.year}";
        final String dayTitle = '$dayName - $dayDate';
        final courses = dayData['courses'] as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dayTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ...courses.entries.map((courseEntry) {
                final course = courseEntry.value;
                return CourseCard(course: course);
              }),
            ],
          ),
        );
      },
    );
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
              _buildHeader(),
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
              _buildHeader(),
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
              _buildHeader(),
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
                  future: _fetchWeeklyMenu(restaurant.jsonId ?? ''),
                  builder: (context, menuSnapshot) {
                    if (menuSnapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!menuSnapshot.hasData || menuSnapshot.data == null || (menuSnapshot.data?.isEmpty ?? true)) {
                      return const Center(
                        child: Text("No menu available.", style: TextStyle(color: Colors.white)),
                      );
                    }
                    return _buildWeeklyMenu(menuSnapshot.data!);
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
            _buildHeader(),
            // Tab bar for restaurant names
            Container(
              color: const Color.fromARGB(255, 17, 17, 17),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: const BoxDecoration(), // Remove the underline indicator
                dividerColor: Colors.transparent, // Remove the separator line
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                overlayColor: MaterialStateProperty.all(Colors.transparent), // Remove tap ripple effect
                splashFactory: NoSplash.splashFactory, // Remove splash effect
                labelPadding: const EdgeInsets.symmetric(horizontal: 8.0), // Reduce horizontal padding between tabs
                tabs: favoriteRestaurants.map((restaurant) {
                  return Tab(
                    text: restaurant.name,
                  );
                }).toList(),
              ),
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

                  return ValueListenableBuilder<int>(
                    valueListenable: _tabNotifiers[restaurantJsonId]!,
                    builder: (context, refreshKey, child) {
                      return FutureBuilder<Map<String, dynamic>?>(
                        key: ValueKey('$restaurantJsonId-$refreshKey'),
                        future: _getMenuForRestaurant(restaurantJsonId, refreshKey),
                        builder: (context, menuSnapshot) {
                          if (menuSnapshot.connectionState != ConnectionState.done) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!menuSnapshot.hasData ||
                              menuSnapshot.data == null ||
                              (menuSnapshot.data?.isEmpty ?? true)) {
                            return const Center(
                              child: Text("No menu available.", style: TextStyle(color: Colors.white)),
                            );
                          }
                          return _buildWeeklyMenu(menuSnapshot.data!);
                        },
                      );
                    },
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
