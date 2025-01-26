import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';

import '../models/restaurant.dart';
import 'restaurant_detail_page.dart';

/// The main home page where restaurants are listed, filtered, searched, and sorted by location.
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
  bool _isLocating = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  LocationData? _userLocation;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  // Method to get the user's location and sort the restaurants
  Future<void> _getLocationAndSort() async {
    if (_isLocating) {
      return;
    }
    setState(() {
      _isLocating = true;
    });
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _isLocating = false;
        });
        return;
      }
    }

    // Check if permission is granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _isLocating = false;
        });
        return;
      }
    }

    // Get the user's current location
    _userLocation = await location.getLocation();

    // Sort restaurants based on proximity
    if (_userLocation != null) {
      _filteredRestaurants.sort((a, b) {
        double distanceA = _calculateDistance(
          _userLocation!.latitude!,
          _userLocation!.longitude!,
          a.lat ?? 0,
          a.lon ?? 0,
        );
        double distanceB = _calculateDistance(
          _userLocation!.latitude!,
          _userLocation!.longitude!,
          b.lat ?? 0,
          b.lon ?? 0,
        );
        return distanceA.compareTo(distanceB);
      });
    }

    setState(() {
      _isLocating = false;
    });
  }

  // Helper method to calculate distance between two points (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of the Earth in km
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
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
      backgroundColor: const Color.fromARGB(255, 17, 17, 17),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 223, 0, 0),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(132, 0, 0, 0),
        ),
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
            : const Text(
                'Sodexo Restaurants',
                style: TextStyle(color: Colors.white),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Insert settings logic here if needed
            },
          ),
          IconButton(
            icon: _isLocating ? const FaIcon(FontAwesomeIcons.spinner) : const Icon(Icons.location_on),
            onPressed: _getLocationAndSort,
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
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
                  color: const Color.fromARGB(255, 46, 46, 46),
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              RestaurantDetailPage(restaurant: restaurant),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                                child: Text(
                                  'Type: ${restaurant.type.join(", ")}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
