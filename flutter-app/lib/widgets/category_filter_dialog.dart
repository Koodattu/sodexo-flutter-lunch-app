import 'package:flutter/material.dart';

class CategoryFilterDialog extends StatefulWidget {
  final Set<String> availableCategories;
  final Map<String, bool> currentFilters;
  final Function(Map<String, bool>) onFiltersChanged;

  const CategoryFilterDialog({
    super.key,
    required this.availableCategories,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<CategoryFilterDialog> createState() => _CategoryFilterDialogState();
}

class _CategoryFilterDialogState extends State<CategoryFilterDialog> {
  late Map<String, bool> _filters;

  @override
  void initState() {
    super.initState();
    // Initialize filters - default to true (visible) for new categories
    _filters = Map<String, bool>.from(widget.currentFilters);
    for (final category in widget.availableCategories) {
      if (!_filters.containsKey(category)) {
        _filters[category] = true;
      }
    }
  }

  /// Cleans up category text by removing numbers and text in parentheses
  /// Uses the same logic as CourseCard for consistency
  String _cleanCategory(String category) {
    String cleaned = category;

    // Remove numbers
    cleaned = cleaned.replaceAll(RegExp(r'\d+'), '');

    // Split at first opening parenthesis and take only the first part
    if (cleaned.contains('(')) {
      cleaned = cleaned.split('(')[0];
    }

    // Trim whitespace and convert to uppercase
    return cleaned.trim().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Sort categories alphabetically for consistent display
    final sortedCategories = widget.availableCategories.toList()..sort();

    return AlertDialog(
      backgroundColor: Colors.grey[850],
      elevation: 8,
      title: const Text(
        'Suodata kategorioita',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category list with flexible height
            Flexible(
              child: sortedCategories.isEmpty
                  ? const Center(
                      child: Text(
                        'Ei kategorioita saatavilla',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedCategories.length,
                      itemBuilder: (context, index) {
                        final category = sortedCategories[index];
                        final isVisible = _filters[category] ?? true;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 32, 32, 32),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(() {
                                  _filters[category] = !(_filters[category] ?? true);
                                });
                              },
                              child: CheckboxListTile(
                                title: Text(
                                  category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                value: isVisible,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _filters[category] = value ?? true;
                                  });
                                },
                                checkColor: Colors.white,
                                activeColor: Colors.blue.shade700,
                                side: const BorderSide(color: Colors.white54),
                                controlAffinity: ListTileControlAffinity.trailing,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Peruuta',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onFiltersChanged(_filters);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Tallenna'),
        ),
      ],
    );
  }
}
