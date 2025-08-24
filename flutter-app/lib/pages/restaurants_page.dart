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

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({super.key});

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  String _selectedFilter = 'All';
  bool _isSearching = false;
  bool _isLocating = false;
  bool _sortByDistance = false;

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

    // Filter out restaurants with null jsonId (no menu data available)
    restaurants =
        restaurants.where((restaurant) => restaurant.jsonId != null && restaurant.jsonId!.isNotEmpty).toList();

    restaurants.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      _allRestaurants = restaurants;
      _filteredRestaurants = restaurants;
    });
  }

  Future<void> _getLocationAndSort() async {
    if (_isLocating) return;
    setState(() {
      _isLocating = true;
    });
    try {
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _isLocating = false;
          });
          return;
        }
      }
      var permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          setState(() {
            _isLocating = false;
          });
          return;
        }
      }
      _userLocation = await location.getLocation();
      setState(() {
        _isLocating = false;
        _sortByDistance = true;
      });
      setState(() {});
    } catch (e) {
      setState(() {
        _isLocating = false;
      });
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

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
      _sortByDistance = false;
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
      _sortByDistance = false;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      _searchController.clear();
      _filteredRestaurants = _allRestaurants;
      if (_isSearching) {
        _searchFocusNode.requestFocus();
      }
      _sortByDistance = false;
    });
  }

  Widget _buildHeader(LunchAppState appState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Row(
        children: [
          // Expanded widget: either a title text or a search TextField when searching.
          Expanded(
            child: _isSearching
                ? TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _searchRestaurants,
                    decoration: InputDecoration(
                      hintText: 'Etsi ravintoloita...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide(
                          color: Colors.blue.shade900,
                          width: 4,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide(
                          color: Colors.red.shade900,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  )
                : Text(
                    "Kaikki ravintolat",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          // Location button (with spinner when locating)
          IconButton(
            icon: _isLocating
                ? const FaIcon(FontAwesomeIcons.spinner)
                : const Icon(Icons.location_on, color: Colors.white),
            onPressed: _getLocationAndSort,
          ),
          // Search toggle button
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: _toggleSearch,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(
    BuildContext context,
    Restaurant restaurant,
    LunchAppState appState,
  ) {
    return Card(
      color: const Color.fromARGB(255, 46, 46, 46),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 4,
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
              // Row with restaurant name, location, and favorite toggle.
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
              // Hours row: chips for lunch and open hours.
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  if (restaurant.lunchHours != null && restaurant.lunchHours!.isNotEmpty)
                    Chip(
                      avatar: const Icon(
                        Icons.restaurant_menu,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Lounas: ${restaurant.lunchHours!}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.deepOrange.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: const BorderSide(color: Colors.transparent, width: 0),
                      ),
                    ),
                  if (restaurant.openHours != null && restaurant.openHours!.isNotEmpty)
                    Chip(
                      avatar: const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Auki: ${restaurant.openHours!}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.tealAccent.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: const BorderSide(color: Colors.transparent, width: 0),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Types row: icon and label indicators for restaurant types.
              if (restaurant.type.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: (List<String>.from(restaurant.type)
                        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())))
                      .where((t) => t.toLowerCase() != 'lunch')
                      .map((t) => _buildTypeIndicator(t))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIndicator(String type) {
    IconData iconData;
    Color color;
    String label;

    switch (type.toLowerCase()) {
      case 'student':
        iconData = Icons.school;
        color = Colors.blueAccent;
        label = 'Opiskelija-alennus';
        break;
      case 'cafe':
        iconData = Icons.local_cafe;
        color = Colors.brown[500]!;
        label = 'Kahvilapalvelut';
        break;
      case 'lunch':
        iconData = Icons.restaurant;
        color = Colors.deepOrangeAccent;
        label = 'Lounas';
        break;
      default:
        iconData = Icons.category;
        color = Colors.grey;
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<LunchAppState>(context);

    // Separate restaurants into favorites and non-favorites for sorting.
    final favoriteRestaurants = _filteredRestaurants.where((r) => appState.favoritesSet.contains(r.urlId)).toList();
    final nonFavoriteRestaurants = _filteredRestaurants.where((r) => !appState.favoritesSet.contains(r.urlId)).toList();

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
      // Sort favorites by their order in the favorites list
      favoriteRestaurants.sort((a, b) {
        int indexA = appState.favorites.indexOf(a.urlId);
        int indexB = appState.favorites.indexOf(b.urlId);
        return indexA.compareTo(indexB);
      });
      nonFavoriteRestaurants.sort((a, b) => a.name.compareTo(b.name));
    }

    // Merge the two lists (favorites first).
    final allRestaurants = [...favoriteRestaurants, ...nonFavoriteRestaurants];

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 17, 17, 17),
        body: Column(
          children: [
            // Updated header row with title/search field and icon buttons.
            _buildHeader(appState),
            // (Optional) You can keep filter buttons below the header if desired.
            if (_isSearching) _buildFilterRow(),
            Expanded(
              child: ListView(
                children:
                    allRestaurants.map((restaurant) => _buildRestaurantCard(context, restaurant, appState)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The unchanged filter row.
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
}
