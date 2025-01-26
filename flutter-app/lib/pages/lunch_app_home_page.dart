import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../models/restaurant.dart';
import '../providers/lunch_app_state.dart';
import 'restaurant_detail_page.dart';

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
  bool _sortByDistance = false; // NEW: Track whether we are sorting by distance

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  LocationData? _userLocation;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    final String jsonString = await rootBundle.loadString('assets/sodexo_restaurants.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);

    List<Restaurant> restaurants = jsonResponse.map((data) => Restaurant.fromJson(data)).toList();

    // Sort restaurants alphabetically by name by default
    restaurants.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      _allRestaurants = restaurants;
      _filteredRestaurants = restaurants;
    });
  }

  // Method to get the user's location and sort the restaurants by distance
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
    setState(() {
      _isLocating = false;
      // Indicate that we are now sorting by distance
      _sortByDistance = true;
    });

    // Rebuild so that we re-sort the list in the build() method
    setState(() {});
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

  // Filter restaurants by type and search query
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

      // Reset sorting to name-based if we change filters (optional)
      _sortByDistance = false;
    });
  }

  // Search restaurants by name/location
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
      // Reset sorting to name-based if we change search (optional)
      _sortByDistance = false;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      _searchController.clear();
      _filteredRestaurants = _allRestaurants;
      _searchFocusNode.requestFocus();
      _sortByDistance = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Grab our app state (where favorites are stored)
    final appState = Provider.of<LunchAppState>(context);

    // At build time, we have two groups:
    // 1) Favorite restaurants (subset of _filteredRestaurants)
    // 2) Non-favorites (subset of _filteredRestaurants)

    final favoriteRestaurants = _filteredRestaurants.where((r) => appState.isFavorite(r.urlId)).toList();
    final nonFavoriteRestaurants = _filteredRestaurants.where((r) => !appState.isFavorite(r.urlId)).toList();

    // Now we need to apply sorting. We either sort by name or by distance (if user location is available and _sortByDistance is true).

    // If we’re sorting by distance but user location is null, we’ll skip that step.
    if (_sortByDistance && _userLocation != null) {
      favoriteRestaurants.sort((a, b) {
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
      nonFavoriteRestaurants.sort((a, b) {
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
    } else {
      // Default sort by name
      favoriteRestaurants.sort((a, b) => a.name.compareTo(b.name));
      nonFavoriteRestaurants.sort((a, b) => a.name.compareTo(b.name));
    }

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
            _buildFilterRow(),
          ],
          // Favorites first
          Expanded(
            child: ListView(
              children: [
                if (favoriteRestaurants.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Favorites',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[200],
                      ),
                    ),
                  ),
                ...favoriteRestaurants.map((restaurant) {
                  return _buildRestaurantCard(context, restaurant, appState);
                }),

                // Then all the non-favorites
                if (nonFavoriteRestaurants.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'All Restaurants',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[200],
                      ),
                    ),
                  ),
                ...nonFavoriteRestaurants.map((restaurant) {
                  return _buildRestaurantCard(context, restaurant, appState);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A helper to build the row of filter buttons (All, Lunch, Student, Cafe).
  Widget _buildFilterRow() {
    return Padding(
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
              backgroundColor: _selectedFilter == 'student' ? Colors.red : const Color.fromARGB(255, 102, 60, 57),
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
    );
  }

  /// A helper to build a Card widget for a given restaurant.
  Widget _buildRestaurantCard(
    BuildContext context,
    Restaurant restaurant,
    LunchAppState appState,
  ) {
    return Card(
      color: const Color.fromARGB(255, 46, 46, 46),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 4, // Slightly increased elevation for better separation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return RestaurantDetailPage(restaurant: restaurant);
              },
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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row with the title and favorite icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                restaurant.location,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      appState.isFavorite(restaurant.urlId) ? Icons.star : Icons.star_border,
                      color: appState.isFavorite(restaurant.urlId) ? Colors.yellow : Colors.white,
                    ),
                    onPressed: () {
                      appState.toggleFavorite(restaurant.urlId);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Hours row (using chips)
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  if (restaurant.lunchHours != null && restaurant.lunchHours!.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.restaurant_menu, size: 16, color: Colors.white),
                      label: Text(
                        'Lunch: ${restaurant.lunchHours!}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.deepOrange.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  if (restaurant.openHours != null && restaurant.openHours!.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.access_time, size: 16, color: Colors.white),
                      label: Text(
                        'Open: ${restaurant.openHours!}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.tealAccent.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // Types row (icons + text)
              if (restaurant.type.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: (List<String>.from(restaurant.type)
                        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())))
                      .where((type) => type.toLowerCase() != 'lunch')
                      .map((t) => _buildTypeIndicator(t))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a little widget (icon + text) for each 'type'.
  Widget _buildTypeIndicator(String type) {
    // Define mapping from type -> icon/color.
    IconData iconData;
    Color color;
    String label;

    switch (type.toLowerCase()) {
      case 'student':
        iconData = Icons.school;
        color = Colors.blueAccent;
        label = 'Student Discount';
        break;
      case 'cafe':
        iconData = Icons.local_cafe;
        color = Colors.brown[500]!;
        label = 'Cafe Services';
        break;
      case 'lunch':
        iconData = Icons.restaurant;
        color = Colors.deepOrangeAccent;
        label = 'Lunch';
        break;
      default:
        iconData = Icons.category;
        color = Colors.grey;
        // Capitalize the first letter
        label = type[0].toUpperCase() + type.substring(1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
