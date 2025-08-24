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
                color: _getDietCodeColor(code).withValues(alpha: 0.5),
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

  /// Builds price chips based on the price format
  List<Widget> _buildPriceChips(String price) {
    final prices = price.split('/').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();

    if (prices.length == 3) {
      // Student / Staff / Guest format
      return [
        _buildSinglePriceChip(prices[0], Icons.school, Colors.indigo, 'Opiskelija'),
        const SizedBox(width: 4),
        _buildSinglePriceChip(prices[1], Icons.work, Colors.amber, 'Henkilökunta'),
        const SizedBox(width: 4),
        _buildSinglePriceChip(prices[2], Icons.person, Colors.pink, 'Vieras'),
      ];
    } else if (prices.length == 2) {
      // Staff / Guest format
      return [
        _buildSinglePriceChip(prices[0], Icons.work, Colors.amber, 'Henkilökunta'),
        const SizedBox(width: 4),
        _buildSinglePriceChip(prices[1], Icons.person, Colors.pink, 'Vieras'),
      ];
    } else if (prices.length == 1) {
      // Single price format
      return [
        _buildSinglePriceChip(prices[0], Icons.local_dining, Colors.deepPurple, 'Hinta'),
      ];
    }

    return [];
  }

  /// Builds a single price chip with icon and price
  Widget _buildSinglePriceChip(String price, IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
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
                  const SizedBox(height: 12),

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
                            color: Colors.cyan.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.label,
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

                  const SizedBox(height: 12),

                  // Price section
                  if (course['price'] != null)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _buildPriceChips(course['price']),
                    ),
                ],
              ),
              // Absolutely positioned info icon in bottom right corner
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(
                  Icons.info_outline,
                  color: Colors.white70,
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Raaka-aineet ja ravintoarvot',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                course['title_fi'] ?? course['title_en'] ?? 'Tuntematon Ruoka',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
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
        // Recipe name
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
        // Allergens
        if (recipe['allergens'] != null) {
          details.add(
            RichText(
              text: TextSpan(
                text: 'Allergiat: ',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                children: <TextSpan>[
                  TextSpan(
                    text: '${recipe['allergens']}\n',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          );
        }
        // Nutrients as a grid
        if (recipe['nutrients'] != null) {
          final nutrientPairs = _parseNutrients(recipe['nutrients']);
          if (nutrientPairs.isNotEmpty) {
            details.add(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ravintoarvotiedot / 100 g:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                    },
                    border: TableBorder.all(color: Colors.white24, width: 0.5),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFF333333)),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                            child: Text('Ravintoaine',
                                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                            child: Text('Määrä',
                                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ),
                      ...nutrientPairs.map((pair) => TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                child: Text(pair.key, style: TextStyle(color: Colors.white, fontSize: 13)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                child: Text(pair.value, style: TextStyle(color: Colors.white, fontSize: 13)),
                              ),
                            ],
                          )),
                    ],
                  ),
                ],
              ),
            );
          }
        }
        // Ingredients
        if (recipe['ingredients'] != null) {
          details.add(
            RichText(
              text: TextSpan(
                text: 'Ainesosat: ',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                children: <TextSpan>[
                  TextSpan(
                    text: '${recipe['ingredients']}\n',
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

  /// Parses a nutrients string like "Energy 100kcal | Protein 5g" into a list of key-value pairs
  List<MapEntry<String, String>> _parseNutrients(String nutrients) {
    final pairs = <MapEntry<String, String>>[];
    final items = nutrients.split('|');
    for (var item in items) {
      final trimmed = item.trim();
      if (trimmed.isEmpty) continue;
      // Split by the first colon for key-value
      final colonIndex = trimmed.indexOf(':');
      if (colonIndex > 0) {
        final key = trimmed.substring(0, colonIndex).trim();
        final value = trimmed.substring(colonIndex + 1).trim();
        pairs.add(MapEntry(key, value));
      } else {
        pairs.add(MapEntry(trimmed, ''));
      }
    }
    return pairs;
  }
}
