import 'package:flutter/material.dart';
import '../services/menu_service.dart';
import 'day_section.dart';

/// A reusable widget that displays a weekly menu from menu data
class WeeklyMenuList extends StatelessWidget {
  final Map<String, dynamic> menuData;

  const WeeklyMenuList({
    super.key,
    required this.menuData,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> mealdates = menuData['mealdates'];
    final bool isNextWeek = menuData['isNextWeek'] ?? false;

    // Calculate the correct start date based on whether this is next week data
    final DateTime startOfWeek = isNextWeek ? MenuDateUtils.getStartOfNextWeek() : MenuDateUtils.getStartOfWeek();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: mealdates.length,
      itemBuilder: (context, index) {
        final dayData = mealdates[index];
        final DateTime currentDayDate = startOfWeek.add(Duration(days: index));
        final String dayName = dayData['date'];
        final String dayDate =
            "${MenuDateUtils.twoDigits(currentDayDate.day)}.${MenuDateUtils.twoDigits(currentDayDate.month)}.${currentDayDate.year}";
        final String dayTitle = '$dayName - $dayDate';
        final courses = dayData['courses'] as Map<String, dynamic>?;

        return DaySection(
          dayTitle: dayTitle,
          courses: courses,
        );
      },
    );
  }
}
