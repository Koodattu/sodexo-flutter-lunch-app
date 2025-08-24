import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service class for fetching menu data from Sodexo API
class MenuService {
  static const String _baseWeeklyUrl = 'https://www.sodexo.fi/ruokalistat/output/weekly_json';
  static const String _baseDailyUrl = 'https://www.sodexo.fi/ruokalistat/output/daily_json';

  /// Fetches weekly menu data for a restaurant
  static Future<Map<String, dynamic>?> fetchWeeklyMenu(String jsonId) async {
    try {
      final response = await http.get(Uri.parse('$_baseWeeklyUrl/$jsonId'));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['mealdates'] != null && decodedData['mealdates'].isNotEmpty) {
          return decodedData;
        } else {
          // Empty map indicates no menu available
          return {};
        }
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  /// Fetches daily menu data for a specific date
  static Future<Map<String, dynamic>?> fetchDailyMenu(String jsonId, String dateString) async {
    try {
      final response = await http.get(Uri.parse('$_baseDailyUrl/$jsonId/$dateString'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (error) {
      return {};
    }
  }

  /// Fetches next week menu data by making individual daily requests
  static Future<Map<String, dynamic>?> fetchNextWeekMenu(String jsonId) async {
    final List<Map<String, dynamic>> nextWeekMenu = [];
    final DateTime today = DateTime.now();
    final DateTime nextMonday = today.weekday == DateTime.monday
        ? today.add(const Duration(days: 7))
        : today.add(Duration(days: (8 - today.weekday) % 7));

    try {
      for (int i = 0; i < 5; i++) {
        final DateTime nextWeekDay = nextMonday.add(Duration(days: i));
        final String dateString = "${nextWeekDay.year}-${_twoDigits(nextWeekDay.month)}-${_twoDigits(nextWeekDay.day)}";

        final dayData = await fetchDailyMenu(jsonId, dateString);
        nextWeekMenu.add(dayData ?? {});
      }

      // Convert next week data to the same format as current week data
      final List<Map<String, dynamic>> mealdates = [];
      for (int i = 0; i < nextWeekMenu.length; i++) {
        final dayData = nextWeekMenu[i];
        final DateTime currentDayDate = nextMonday.add(Duration(days: i));
        final String dayName = MenuDateUtils.getFinnishWeekdayName(currentDayDate);

        // Handle the different data structure for next week (daily API returns List instead of Map)
        final courses = dayData['courses'] is List
            ? DataUtils.convertListToMap(dayData['courses'])
            : dayData['courses'] as Map<String, dynamic>?;

        mealdates.add({
          'date': dayName,
          'courses': courses ?? {},
        });
      }

      return {
        'mealdates': mealdates,
        'isNextWeek': true, // Flag to indicate this is next week data
      };
    } catch (error) {
      return null;
    }
  }

  /// Fetches menu with automatic fallback to next week if current week is expired
  static Future<Map<String, dynamic>?> fetchMenuWithFallback(String jsonId, {bool forceRefresh = false}) async {
    try {
      // First, try to fetch current week menu
      final currentWeekData = await fetchWeeklyMenu(jsonId);

      if (currentWeekData != null && currentWeekData.isNotEmpty) {
        // Check if current week menu is still valid
        if (currentWeekData['mealdates'] != null && currentWeekData['mealdates'].isNotEmpty) {
          final List<dynamic> mealdates = currentWeekData['mealdates'];
          final DateTime now = DateTime.now();
          final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

          // Check if current date is after the last date in the week menu
          final DateTime lastDayOfWeek = startOfWeek.add(Duration(days: mealdates.length - 1));

          if (now.isAfter(lastDayOfWeek.add(const Duration(days: 1)))) {
            // Current week is expired, fetch next week menu
            return await fetchNextWeekMenu(jsonId);
          }
        }
        return currentWeekData;
      }

      // If current week fails, try next week
      return await fetchNextWeekMenu(jsonId);
    } catch (e) {
      return null;
    }
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

/// Utility class for date-related operations
class MenuDateUtils {
  static String twoDigits(int n) => n.toString().padLeft(2, '0');

  /// Returns Finnish weekday name for given date
  static String getFinnishWeekdayName(DateTime date) {
    const weekdays = ['Maanantai', 'Tiistai', 'Keskiviikko', 'Torstai', 'Perjantai', 'Lauantai', 'Sunnuntai'];
    return weekdays[date.weekday - 1];
  }

  /// Gets the start of current week (Monday)
  static DateTime getStartOfWeek([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    return targetDate.subtract(Duration(days: targetDate.weekday - 1));
  }

  /// Gets the start of next week (Monday)
  static DateTime getStartOfNextWeek([DateTime? date]) {
    final today = date ?? DateTime.now();
    return today.weekday == DateTime.monday
        ? today.add(const Duration(days: 7))
        : today.add(Duration(days: (8 - today.weekday) % 7));
  }
}

/// Utility class for data transformations
class DataUtils {
  /// Converts a List of courses to a Map format for consistency
  static Map<String, dynamic>? convertListToMap(dynamic coursesList) {
    if (coursesList == null || coursesList is! List || coursesList.isEmpty) {
      return null;
    }

    final Map<String, dynamic> coursesMap = {};
    for (int i = 0; i < coursesList.length; i++) {
      coursesMap[i.toString()] = coursesList[i];
    }
    return coursesMap;
  }
}
