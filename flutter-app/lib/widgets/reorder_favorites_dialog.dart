import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class ReorderFavoritesDialog extends StatefulWidget {
  final List<Restaurant> favoriteRestaurants;
  final Function(List<String>) onReorder;

  const ReorderFavoritesDialog({
    super.key,
    required this.favoriteRestaurants,
    required this.onReorder,
  });

  @override
  State<ReorderFavoritesDialog> createState() => _ReorderFavoritesDialogState();
}

class _ReorderFavoritesDialogState extends State<ReorderFavoritesDialog> {
  late List<Restaurant> _restaurants;

  @override
  void initState() {
    super.initState();
    _restaurants = List<Restaurant>.from(widget.favoriteRestaurants);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.red.shade900],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(2), // Border thickness
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 46, 46, 46),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Järjestä suosikit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final Restaurant item = _restaurants.removeAt(oldIndex);
                      _restaurants.insert(newIndex, item);
                    });
                  },
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      color: Colors.transparent,
                      child: child,
                    );
                  },
                  children: _restaurants.asMap().entries.map((entry) {
                    final index = entry.key;
                    final restaurant = entry.value;
                    return Container(
                      key: ValueKey(restaurant.urlId),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade900, Colors.red.shade900],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(1), // Border thickness
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 60, 60, 60),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: ListTile(
                          leading: ReorderableDragStartListener(
                            index: index,
                            child: const Icon(
                              Icons.drag_handle,
                              color: Colors.white70,
                            ),
                          ),
                          title: Text(
                            restaurant.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            restaurant.location,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Peruuta',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final newOrder = _restaurants.map((r) => r.urlId).toList();
                      widget.onReorder(newOrder);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tallenna'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
