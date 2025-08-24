import 'package:flutter/material.dart';

/// A reusable course card widget that displays course information
/// and shows detailed information in a dialog when tapped.
class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseCard({
    super.key,
    required this.course,
  });

  /// Returns color for different diet codes
  Color _getDietCodeColor(String code) {
    switch (code.trim().toUpperCase()) {
      case 'G':
        return Colors.green; // Green for gluten-free
      case 'L':
        return Colors.blue; // Blue for lactose-free
      case 'M':
        return Colors.purple; // Purple for milk-free
      case 'VE':
        return Colors.lightGreen; // Light green for vegan
      case 'VL':
        return Colors.teal; // Teal for low-lactose
      case 'S':
        return Colors.orange; // Orange for contains soy
      default:
        return Colors.grey; // Grey for unknown codes
    }
  }

  /// Builds individual diet code chips
  List<Widget> _buildDietCodeChips(String dietCodes) {
    final codes = dietCodes.split(',').map((code) => code.trim()).where((code) => code.isNotEmpty).toList();

    return codes
        .map((code) => Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getDietCodeColor(code).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 46, 46, 46),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showCourseDetailDialog(context, course);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main title
                  Text(
                    course['title_fi'] ?? 'Ei otsikkoa',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category and Diet codes row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Category chip on the left
                      if (course['category'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.restaurant_menu,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                course['category'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox.shrink(),

                      // Diet codes chips on the right
                      if (course['dietcodes'] != null)
                        Flexible(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            alignment: WrapAlignment.end,
                            children: _buildDietCodeChips(course['dietcodes']),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Price section
                  Row(
                    children: [
                      if (course['price'] != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.euro,
                            color: Colors.yellow.shade400,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          course['price'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.euro,
                            color: Colors.white54,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Hinta ei saatavilla',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              // Absolutely positioned info icon in top right corner
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.info_outline,
                  color: Colors.white54,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                if (course['additionalDietInfo'] != null && course['additionalDietInfo']['allergens'] != null)
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
}
