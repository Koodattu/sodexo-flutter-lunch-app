import 'package:flutter/material.dart';
import 'course_card.dart';

/// A reusable widget that displays a day's menu with title and courses
class DaySection extends StatelessWidget {
  final String dayTitle;
  final Map<String, dynamic>? courses;

  const DaySection({
    super.key,
    required this.dayTitle,
    this.courses,
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
          if (courses == null || courses!.isEmpty)
            const Text(
              "Ei ruokalistaa saatavilla tälle päivälle.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          else
            ...courses!.entries.map<Widget>((courseEntry) {
              final course = courseEntry.value;
              return CourseCard(course: course);
            }),
        ],
      ),
    );
  }
}
