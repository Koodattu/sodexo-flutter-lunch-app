import 'package:english_words/english_words.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

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
  final double? lat; // Latitude
  final double? lon; // Longitude

  Restaurant({
    this.jsonId,
    required this.urlId,
    required this.name,
    required this.location,
    this.lunchHours,
    this.openHours,
    required this.type,
    this.lat,
    this.lon,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      jsonId: json['json_id'],
      urlId: json['url_id'],
      name: json['name'].trim(),
      location: json['location'],
      lunchHours: json['lunch_hours'],
      openHours: json['open_hours'],
      type: List<String>.from(json['type']),
      lat: json['lat'] != null ? double.tryParse(json['lat']) : null, // Parse latitude
      lon: json['lon'] != null ? double.tryParse(json['lon']) : null, // Parse longitude
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
        return;
      }
    }

    // Check if permission is granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
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
          a.lat!,
          a.lon!,
        );
        double distanceB = _calculateDistance(
          _userLocation!.latitude!,
          _userLocation!.longitude!,
          b.lat!,
          b.lon!,
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

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _currentWeekMenuData;
  List<Map<String, dynamic>>? _nextWeekMenuData;
  TabController? _tabController;
  bool _isLoadingCurrentWeek = true;
  bool _isLoadingNextWeek = true;
  bool _errorFetchingCurrentWeek = false;
  bool _errorFetchingNextWeek = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMenuData();
    _fetchNextWeekMenuData();
  }

  Future<void> _fetchMenuData() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.sodexo.fi/ruokalistat/output/weekly_json/${widget.restaurant.jsonId}'),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['mealdates'] != null && decodedData['mealdates'].isNotEmpty) {
          setState(() {
            _currentWeekMenuData = decodedData;
          });
        } else {
          setState(() {
            _currentWeekMenuData = {}; // Empty map indicates no menu available
          });
        }
      } else {
        setState(() {
          _errorFetchingCurrentWeek = true;
        });
      }
    } catch (error) {
      setState(() {
        _errorFetchingCurrentWeek = true;
      });
    } finally {
      setState(() {
        _isLoadingCurrentWeek = false;
      });
    }
  }

  Future<void> _fetchNextWeekMenuData() async {
    final List<Map<String, dynamic>> nextWeekMenu = [];
    final DateTime today = DateTime.now();
    final DateTime nextMonday = today.add(Duration(days: (7 - today.weekday + 1) % 7));

    try {
      for (int i = 0; i < 5; i++) {
        final DateTime nextWeekDay = nextMonday.add(Duration(days: i));
        final String dateString = "${nextWeekDay.year}-${_twoDigits(nextWeekDay.month)}-${_twoDigits(nextWeekDay.day)}";
        final response = await http.get(
          Uri.parse('https://www.sodexo.fi/ruokalistat/output/daily_json/${widget.restaurant.jsonId}/$dateString'),
        );

        if (response.statusCode == 200) {
          final decodedData = json.decode(response.body);
          nextWeekMenu.add(decodedData);
        } else {
          nextWeekMenu.add({});
        }
      }

      setState(() {
        _nextWeekMenuData = nextWeekMenu;
      });
    } catch (error) {
      setState(() {
        _errorFetchingNextWeek = true;
      });
    } finally {
      setState(() {
        _isLoadingNextWeek = false;
      });
    }
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Current Week'),
            Tab(text: 'Next Week'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentWeekMenu(),
          _buildNextWeekMenu(),
        ],
      ),
    );
  }

  Widget _buildCurrentWeekMenu() {
    if (_isLoadingCurrentWeek) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorFetchingCurrentWeek) {
      return const Center(child: Text("Failed to load the menu for the current week."));
    }
    if (_currentWeekMenuData!.isEmpty) {
      return const Center(child: Text("No menu available for this week."));
    }

    final DateTime startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    return ListView.builder(
      itemCount: _currentWeekMenuData!['mealdates'].length,
      itemBuilder: (context, index) {
        final dayData = _currentWeekMenuData!['mealdates'][index];
        final DateTime currentDayDate = startOfWeek.add(Duration(days: index));
        final String dayName = dayData['date'];
        final String dayDate =
            "${_twoDigits(currentDayDate.day)}.${_twoDigits(currentDayDate.month)}.${currentDayDate.year}";
        final String dayTitle = '$dayName - $dayDate';
        final courses = dayData['courses'];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayTitle,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...courses.entries.map<Widget>((courseEntry) {
                final course = courseEntry.value;
                return InkWell(
                  onTap: () {
                    // Handle course card tap
                  },
                  child: Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['title_fi'] ?? 'No Title',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course['title_en'] ?? 'No English Title',
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course['category'] ?? 'No Category',
                            style: const TextStyle(fontSize: 14, color: Colors.white54),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: ${course['price'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 14, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNextWeekMenu() {
    if (_isLoadingNextWeek) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorFetchingNextWeek) {
      return const Center(child: Text("Failed to load the menu for the next week."));
    }
    if (_nextWeekMenuData!.isEmpty || _nextWeekMenuData!.every((day) => day.isEmpty)) {
      return const Center(child: Text("No menu available for the next week."));
    }

    final DateTime nextMonday = DateTime.now().add(Duration(days: (7 - DateTime.now().weekday + 1) % 7));

    return ListView.builder(
      itemCount: _nextWeekMenuData!.length,
      itemBuilder: (context, index) {
        final dayData = _nextWeekMenuData![index];
        if (dayData.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "No menu available for this day.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          );
        }
        final DateTime currentDayDate = nextMonday.add(Duration(days: index));
        final String dayName = DateFormat('EEEE').format(currentDayDate);
        final String dayDate =
            "${_twoDigits(currentDayDate.day)}.${_twoDigits(currentDayDate.month)}.${currentDayDate.year}";
        final String dayTitle = '$dayName - $dayDate';
        final courses = dayData['courses'];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayTitle,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...courses.entries.map<Widget>((courseEntry) {
                final course = courseEntry.value;
                return InkWell(
                  onTap: () {
                    // Handle course card tap
                  },
                  child: Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['title_fi'] ?? 'No Title',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course['title_en'] ?? 'No English Title',
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course['category'] ?? 'No Category',
                            style: const TextStyle(fontSize: 14, color: Colors.white54),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: ${course['price'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 14, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
