import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../models/restaurant.dart';
import '../providers/lunch_app_state.dart';

class FavoriteMenusPage extends StatefulWidget {
  const FavoriteMenusPage({super.key});
  @override
  State<FavoriteMenusPage> createState() => _FavoriteMenusPageState();
}

class _FavoriteMenusPageState extends State<FavoriteMenusPage> {
  List<Restaurant> _allRestaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
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

  Widget _buildFancyCourseCard(Map<String, dynamic> course) {
    return Card(
      color: const Color(0xFF2E2E2E),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course['title_fi'] ?? 'No Title',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            if (course['title_en'] != null)
              Text(
                course['title_en'],
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(
                    'Category: ${course['category'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.deepOrangeAccent,
                ),
                if (course['price'] != null)
                  Chip(
                    label: Text(
                      'Price: ${course['price']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                if (course['dietcodes'] != null)
                  Chip(
                    label: Text(
                      'Diet: ${course['dietcodes']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blueGrey,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (course['properties'] != null)
              Text(
                'Properties: ${course['properties']}',
                style: const TextStyle(color: Colors.white54),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyMenu(Map<String, dynamic> menuData) {
    final List<dynamic> mealdates = menuData['mealdates'];
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: mealdates.length,
      itemBuilder: (context, dayIndex) {
        final dayData = mealdates[dayIndex];
        final dayTitle = dayData['date'] ?? '';
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
                return _buildFancyCourseCard(course);
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

    if (_isLoading) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 17, 17, 17),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (favoriteRestaurants.isEmpty) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 17, 17, 17),
          body: const Center(
            child: Text(
              "You have no favorite restaurants.",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 17, 17, 17),
        body: PageView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: favoriteRestaurants.length,
          itemBuilder: (context, index) {
            final restaurant = favoriteRestaurants[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
            );
          },
        ),
      ),
    );
  }
}
