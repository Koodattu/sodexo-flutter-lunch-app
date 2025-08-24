import 'package:flutter/material.dart';
import 'course_card.dart';

/// A reusable widget that displays a day's menu with title and courses,
/// with special handling for filtered content
class FilteredDaySection extends StatelessWidget {
  final String dayTitle;
  final Map<String, dynamic>? originalCourses;
  final Map<String, dynamic>? filteredCourses;

  const FilteredDaySection({
    super.key,
    required this.dayTitle,
    this.originalCourses,
    this.filteredCourses,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          if (_shouldShowFilteredMessage())
            const Text(
              "Kaikki kategoriat on suodatettu pois.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          else if (filteredCourses == null || filteredCourses!.isEmpty)
            const Text(
              "Ei ruokalistaa saatavilla tälle päivälle.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          else
            ...filteredCourses!.entries.map<Widget>((courseEntry) {
              final course = courseEntry.value;
              return CourseCard(course: course);
            }),
        ],
      ),
    );
  }

  /// Determines if we should show the "all filtered out" message
  bool _shouldShowFilteredMessage() {
    // Show filtered message if:
    // - There were original courses available
    // - But no filtered courses remain
    return (originalCourses != null && originalCourses!.isNotEmpty) &&
        (filteredCourses == null || filteredCourses!.isEmpty);
  }
}
