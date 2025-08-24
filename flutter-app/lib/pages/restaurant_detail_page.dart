import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
    final DateTime nextMonday = today.weekday == DateTime.monday
        ? today.add(const Duration(days: 7))
        : today.add(Duration(days: (8 - today.weekday) % 7));

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

  /// Returns Finnish weekday name for given date
  String _getFinnishWeekdayName(DateTime date) {
    const weekdays = ['Maanantai', 'Tiistai', 'Keskiviikko', 'Torstai', 'Perjantai', 'Lauantai', 'Sunnuntai'];
    return weekdays[date.weekday - 1];
  }

  /// Builds a course card widget that can be tapped to show details
  Widget _buildCourseCard(Map<String, dynamic> course) {
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
                  course['title_fi'] ?? 'Ei otsikkoa',
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
                  course['category'] ?? 'Ei kategoriaa',
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hinta: ${course['price'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the day section with title and courses
  Widget _buildDaySection(String dayTitle, Map<String, dynamic>? courses) {
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
          if (courses == null || courses.isEmpty)
            const Text(
              "Ei valikkoa saatavilla tälle päivälle.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          else
            ...courses.entries.map<Widget>((courseEntry) {
              final course = courseEntry.value;
              return _buildCourseCard(course);
            }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Generic method to build loading/error/empty states
  Widget _buildMenuState({
    required bool isLoading,
    required bool hasError,
    required bool isEmpty,
    required String errorMessage,
    required String emptyMessage,
    required Widget Function() contentBuilder,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (hasError) {
      return Center(child: Text(errorMessage));
    }
    if (isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return contentBuilder();
  }

  void _showCourseDetailDialog(BuildContext context, Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          elevation: 8,
          title: Text(
            course['title_fi'] ?? course['title_en'] ?? 'Tuntematon Ruoka',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: 'Kategoria: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${course['category'] ?? 'Ei kategoriaa'}\n',
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Hinta: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${course['price'] ?? 'Ei hintaa'}\n',
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                if (course['dietcodes'] != null)
                  RichText(
                    text: TextSpan(
                      text: 'Ravintosisältö: ',
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
                if (course['additionalDietInfo']['allergens'] != null)
                  RichText(
                    text: TextSpan(
                      text: 'Allergiat: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${course['additionalDietInfo']['allergens']}\n',
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                if (course['properties'] != null)
                  RichText(
                    text: TextSpan(
                      text: 'Ominaisuudet: ',
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
              child: const Text('Sulje'),
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
              text: 'Resepti: ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              children: <TextSpan>[
                TextSpan(
                  text: '${recipe['name'] ?? 'Ei nimeä'}\n',
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
                text: 'Ainesosat: ',
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
                text: 'Ravintosisältö:\n',
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
            Tab(text: 'Tämä viikko'),
            Tab(text: 'Seuraava viikko'),
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
    return _buildMenuState(
      isLoading: _isLoadingCurrentWeek,
      hasError: _errorFetchingCurrentWeek,
      isEmpty: _currentWeekMenuData?.isEmpty ?? true,
      errorMessage: "Valikon lataaminen tälle viikolle epäonnistui.",
      emptyMessage: "Ei valikkoa saatavilla tälle viikolle.",
      contentBuilder: () {
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

            return _buildDaySection(dayTitle, courses);
          },
        );
      },
    );
  }

  Widget _buildNextWeekMenu() {
    return _buildMenuState(
      isLoading: _isLoadingNextWeek,
      hasError: _errorFetchingNextWeek,
      isEmpty: (_nextWeekMenuData?.isEmpty ?? true) || (_nextWeekMenuData?.every((day) => day.isEmpty) ?? true),
      errorMessage: "Valikon lataaminen seuraavalle viikolle epäonnistui.",
      emptyMessage: "Ei valikkoa saatavilla seuraavalle viikolle.",
      contentBuilder: () {
        final DateTime nextMonday = DateTime.now().weekday == DateTime.monday
            ? DateTime.now().add(const Duration(days: 7))
            : DateTime.now().add(Duration(days: (8 - DateTime.now().weekday) % 7));

        return ListView.builder(
          itemCount: _nextWeekMenuData!.length,
          itemBuilder: (context, index) {
            final dayData = _nextWeekMenuData![index];
            final DateTime currentDayDate = nextMonday.add(Duration(days: index));
            final String dayName = _getFinnishWeekdayName(currentDayDate);
            final String dayDate =
                "${_twoDigits(currentDayDate.day)}.${_twoDigits(currentDayDate.month)}.${currentDayDate.year}";
            final String dayTitle = '$dayName - $dayDate';
            final courses = dayData['courses'];

            return _buildDaySection(dayTitle, courses);
          },
        );
      },
    );
  }
}
