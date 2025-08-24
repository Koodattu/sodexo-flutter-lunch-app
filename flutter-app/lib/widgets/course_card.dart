import 'package:flutter/material.dart';

/// A reusable course card widget that displays course information
/// and shows detailed information in a dialog when tapped.
class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseCard({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
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
