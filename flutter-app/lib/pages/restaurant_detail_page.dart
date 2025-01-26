import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/restaurant.dart';

/// Detail page that shows the current week and next week menu data from Sodexo.
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
        Uri.parse(
          'https://www.sodexo.fi/ruokalistat/output/weekly_json/${widget.restaurant.jsonId}',
        ),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['mealdates'] != null && decodedData['mealdates'].isNotEmpty) {
          setState(() {
            _currentWeekMenuData = decodedData;
          });
        } else {
          setState(() {
            // Empty map indicates no menu available
            _currentWeekMenuData = {};
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
          Uri.parse(
            'https://www.sodexo.fi/ruokalistat/output/daily_json/${widget.restaurant.jsonId}/$dateString',
          ),
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

  void _showCourseDetailDialog(BuildContext context, Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          elevation: 8,
          title: Text(
            course['title_fi'] ?? course['title_en'] ?? 'Unknown Dish',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: 'Category: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${course['category'] ?? 'No Category'}\n',
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Price: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${course['price'] ?? 'No Price'}\n',
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                if (course['dietcodes'] != null)
                  RichText(
                    text: TextSpan(
                      text: 'Diet Codes: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${course['dietcodes']}\n',
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                if (course['allergens'] != null)
                  RichText(
                    text: TextSpan(
                      text: 'Allergens: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${course['allergens']}\n',
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                if (course['properties'] != null)
                  RichText(
                    text: TextSpan(
                      text: 'Properties: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${course['properties']}\n',
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                if (course['recipes'] != null) ..._buildRecipeDetails(course['recipes']),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildRecipeDetails(Map<String, dynamic> recipes) {
    List<Widget> details = [];

    recipes.forEach((key, recipe) {
      if (key != 'hideAll') {
        details.add(const SizedBox(height: 8));
        details.add(
          RichText(
            text: TextSpan(
              text: 'Recipe: ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              children: <TextSpan>[
                TextSpan(
                  text: '${recipe['name'] ?? 'No Name'}\n',
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        );
        if (recipe['ingredients'] != null) {
          details.add(
            RichText(
              text: TextSpan(
                text: 'Ingredients: ',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                children: <TextSpan>[
                  TextSpan(
                    text: '${recipe['ingredients']}\n'.replaceAll(", ", "\n"),
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          );
        }
        if (recipe['nutrients'] != null) {
          details.add(
            RichText(
              text: TextSpan(
                text: 'Nutritional Info:\n',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                children: <TextSpan>[
                  TextSpan(
                    text: '${recipe['nutrients']}\n'.replaceAll("|", "\n"),
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          );
        }
      }
    });

    return details;
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
        title: Text(
          widget.restaurant.name,
          style: const TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
      return const Center(
        child: Text("Failed to load the menu for the current week."),
      );
    }
    if (_currentWeekMenuData!.isEmpty) {
      return const Center(
        child: Text("No menu available for this week."),
      );
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
                return Card(
                  color: const Color.fromARGB(255, 46, 46, 46),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    onTap: () {
                      _showCourseDetailDialog(context, course);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course['title_fi'] ?? 'No Title',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
      return const Center(
        child: Text("Failed to load the menu for the next week."),
      );
    }
    if (_nextWeekMenuData!.isEmpty || _nextWeekMenuData!.every((day) => day.isEmpty)) {
      return const Center(
        child: Text("No menu available for the next week."),
      );
    }

    final DateTime nextMonday = DateTime.now().add(Duration(days: (7 - DateTime.now().weekday + 1) % 7));

    return ListView.builder(
      itemCount: _nextWeekMenuData!.length,
      itemBuilder: (context, index) {
        final dayData = _nextWeekMenuData![index];
        final DateTime currentDayDate = nextMonday.add(Duration(days: index));
        final String dayName = DateFormat('EEEE').format(currentDayDate);
        final String dayDate =
            "${_twoDigits(currentDayDate.day)}.${_twoDigits(currentDayDate.month)}.${currentDayDate.year}";
        final String dayTitle = '$dayName - $dayDate';
        final courses = dayData['courses'];

        if (courses == null || courses.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    dayTitle,
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "No menu available for this day.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

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
                return Card(
                  color: const Color.fromARGB(255, 46, 46, 46),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    onTap: () {
                      _showCourseDetailDialog(context, course);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course['title_fi'] ?? 'No Title',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
