import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LunchAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink, brightness: Brightness.dark),
        ),
        home: const LunchAppHomePage(),
      ),
    );
  }
}

class LunchAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class Restaurant {
  final String? jsonId;
  final String urlId;
  final String name;
  final String location;
  final String? lunchHours;
  final String? openHours;
  final List<String> type;

  Restaurant({
    this.jsonId,
    required this.urlId,
    required this.name,
    required this.location,
    this.lunchHours,
    this.openHours,
    required this.type,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      jsonId: json['json_id'],
      urlId: json['url_id'],
      name: json['name'].trim(),
      location: json['location'],
      lunchHours: json['lunch_hours'],
      openHours: json['open_hours'],
      type: List<String>.from(json['type']), // Update JSON parsing
    );
  }
}

class LunchAppHomePage extends StatefulWidget {
  const LunchAppHomePage({super.key});

  @override
  State<LunchAppHomePage> createState() => _LunchAppHomePageState();
}

class _LunchAppHomePageState extends State<LunchAppHomePage> {
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  String _selectedFilter = 'All';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    final String jsonString = await rootBundle.loadString('assets/sodexo_restaurants.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);

    List<Restaurant> restaurants = jsonResponse.map((data) => Restaurant.fromJson(data)).toList();

    // Sort restaurants alphabetically by name
    restaurants.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      _allRestaurants = restaurants;
      _filteredRestaurants = restaurants;
    });
  }

  void _filterRestaurants(String type) {
    setState(() {
      _selectedFilter = type;

      List<Restaurant> filteredList;
      if (type == 'All') {
        filteredList = _allRestaurants;
      } else {
        filteredList = _allRestaurants.where((restaurant) => restaurant.type.contains(type)).toList();
      }

      if (_searchController.text.isNotEmpty) {
        _filteredRestaurants = filteredList
            .where((restaurant) =>
                restaurant.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                restaurant.location.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      } else {
        _filteredRestaurants = filteredList;
      }
    });
  }

  void _searchRestaurants(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRestaurants = _allRestaurants;
      } else {
        _filteredRestaurants = _allRestaurants
            .where((restaurant) =>
                restaurant.name.toLowerCase().contains(query.toLowerCase()) ||
                restaurant.location.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      _searchController.clear();
      _filteredRestaurants = _allRestaurants;
      _searchFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Search restaurants...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _searchRestaurants,
              )
            : const Text('Sodexo Restaurants', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 223, 0, 0),
        systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Color.fromARGB(132, 0, 0, 0)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => _filterRestaurants('All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFilter == 'All' ? Colors.red : const Color.fromARGB(255, 102, 60, 57),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('All'),
                  ),
                  ElevatedButton(
                    onPressed: () => _filterRestaurants('lunch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFilter == 'lunch' ? Colors.red : const Color.fromARGB(255, 102, 60, 57),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Lunch'),
                  ),
                  ElevatedButton(
                    onPressed: () => _filterRestaurants('student'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedFilter == 'student' ? Colors.red : const Color.fromARGB(255, 102, 60, 57),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Student'),
                  ),
                  ElevatedButton(
                    onPressed: () => _filterRestaurants('cafe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFilter == 'cafe' ? Colors.red : const Color.fromARGB(255, 102, 60, 57),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cafe'),
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: _filteredRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _filteredRestaurants[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(restaurant.location),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text('Lunch: ${restaurant.lunchHours ?? "N/A"}'),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text('Open: ${restaurant.openHours ?? "N/A"}'),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.restaurant_menu, color: Colors.grey),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text('Type: ${restaurant.type.join(", ")}'), // Join multiple types with a comma
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
