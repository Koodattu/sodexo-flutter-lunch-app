import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../services/menu_service.dart';
import '../widgets/day_section.dart';
import '../widgets/menu_state_builder.dart';
import '../widgets/custom_tab_bar.dart';

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
    final data = await MenuService.fetchWeeklyMenu(widget.restaurant.jsonId ?? '');
    setState(() {
      if (data != null) {
        _currentWeekMenuData = data;
      } else {
        _errorFetchingCurrentWeek = true;
      }
      _isLoadingCurrentWeek = false;
    });
  }

  Future<void> _fetchNextWeekMenuData() async {
    final data = await MenuService.fetchNextWeekMenu(widget.restaurant.jsonId ?? '');
    setState(() {
      if (data != null) {
        _nextWeekMenuData = data['mealdates']?.cast<Map<String, dynamic>>();
      } else {
        _errorFetchingNextWeek = true;
      }
      _isLoadingNextWeek = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.red.shade900, Colors.blue.shade900]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Scaffold(
          backgroundColor: const Color.fromARGB(255, 17, 17, 17),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              widget.restaurant.name,
              style: const TextStyle(color: Colors.white),
            ),
            bottom: CustomTabBar(
              controller: _tabController,
              tabLabels: const ['Tämä viikko', 'Seuraava viikko'],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildCurrentWeekMenu(),
              _buildNextWeekMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeekMenu() {
    return MenuStateBuilder(
      isLoading: _isLoadingCurrentWeek,
      hasError: _errorFetchingCurrentWeek,
      isEmpty: _currentWeekMenuData?.isEmpty ?? true,
      errorMessage: "Ruokalistan lataaminen tälle viikolle epäonnistui.",
      emptyMessage: "Ei ruokalistaa saatavilla tälle viikolle.",
      contentBuilder: () {
        final DateTime startOfWeek = MenuDateUtils.getStartOfWeek();

        return ListView.builder(
          itemCount: _currentWeekMenuData!['mealdates'].length,
          itemBuilder: (context, index) {
            final dayData = _currentWeekMenuData!['mealdates'][index];
            final DateTime currentDayDate = startOfWeek.add(Duration(days: index));
            final String dayName = dayData['date'];
            final String dayDate =
                "${MenuDateUtils.twoDigits(currentDayDate.day)}.${MenuDateUtils.twoDigits(currentDayDate.month)}.${currentDayDate.year}";
            final String dayTitle = '$dayName - $dayDate';
            final courses = dayData['courses'];

            return DaySection(
              dayTitle: dayTitle,
              courses: courses,
            );
          },
        );
      },
    );
  }

  Widget _buildNextWeekMenu() {
    return MenuStateBuilder(
      isLoading: _isLoadingNextWeek,
      hasError: _errorFetchingNextWeek,
      isEmpty: (_nextWeekMenuData?.isEmpty ?? true) || (_nextWeekMenuData?.every((day) => day.isEmpty) ?? true),
      errorMessage: "Ruokalistan lataaminen seuraavalle viikolle epäonnistui.",
      emptyMessage: "Ei ruokalistaa saatavilla seuraavalle viikolle.",
      contentBuilder: () {
        final DateTime nextMonday = MenuDateUtils.getStartOfNextWeek();

        return ListView.builder(
          itemCount: _nextWeekMenuData!.length,
          itemBuilder: (context, index) {
            final dayData = _nextWeekMenuData![index];
            final DateTime currentDayDate = nextMonday.add(Duration(days: index));
            final String dayName = MenuDateUtils.getFinnishWeekdayName(currentDayDate);
            final String dayDate =
                "${MenuDateUtils.twoDigits(currentDayDate.day)}.${MenuDateUtils.twoDigits(currentDayDate.month)}.${currentDayDate.year}";
            final String dayTitle = '$dayName - $dayDate';

            // Handle the different data structure for next week (daily API returns List instead of Map)
            final courses = dayData['courses'] is List
                ? DataUtils.convertListToMap(dayData['courses'])
                : dayData['courses'] as Map<String, dynamic>?;

            return DaySection(
              dayTitle: dayTitle,
              courses: courses,
            );
          },
        );
      },
    );
  }
}
