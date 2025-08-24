import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/menu_service.dart';
import '../providers/lunch_app_state.dart';
import 'filtered_day_section.dart';

/// A filtered version of WeeklyMenuList that respects category filter settings
class FilteredWeeklyMenuList extends StatelessWidget {
  final Map<String, dynamic> menuData;

  const FilteredWeeklyMenuList({
    super.key,
    required this.menuData,
  });

  /// Filters courses based on category filter settings
  Map<String, dynamic>? _filterCourses(Map<String, dynamic>? courses, LunchAppState appState) {
    if (courses == null || courses.isEmpty) return courses;

    final Map<String, dynamic> filteredCourses = {};

    for (final entry in courses.entries) {
      final course = entry.value as Map<String, dynamic>?;
      if (course != null && course['category'] != null) {
        final category = course['category'].toString();
        if (appState.isCategoryVisible(category)) {
          filteredCourses[entry.key] = entry.value;
        }
      } else {
        // Include courses without categories
        filteredCourses[entry.key] = entry.value;
      }
    }

    return filteredCourses;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<LunchAppState>(context);
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
        final originalCourses = dayData['courses'] as Map<String, dynamic>?;
        final filteredCourses = _filterCourses(originalCourses, appState);

        return FilteredDaySection(
          dayTitle: dayTitle,
          originalCourses: originalCourses,
          filteredCourses: filteredCourses,
        );
      },
    );
  }
}
