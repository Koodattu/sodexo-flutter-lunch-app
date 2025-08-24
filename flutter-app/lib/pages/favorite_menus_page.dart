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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Favorites",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {}, // No functionality yet
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

  Future<Map<String, dynamic>?> _fetchWeeklyMenu(String jsonId) async {
    try {
      final response = await http.get(Uri.parse('https://www.sodexo.fi/ruokalistat/output/weekly_json/$jsonId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
    } catch (e) {
      // Handle error as needed.
    }
    return null;
  }

  Widget _buildWeeklyMenu(Map<String, dynamic> menuData) {
    final List<dynamic> mealdates = menuData['mealdates'];
    final DateTime startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

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
              const SizedBox(height: 8),
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
                labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                overlayColor: MaterialStateProperty.all(Colors.transparent), // Remove tap ripple effect
                splashFactory: NoSplash.splashFactory, // Remove splash effect
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
                  return FutureBuilder<Map<String, dynamic>?>(
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
