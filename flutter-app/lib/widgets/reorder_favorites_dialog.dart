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
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 46, 46, 46),
      title: const Text(
        'Järjestä suosikit',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ReorderableListView.builder(
          itemCount: _restaurants.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final Restaurant item = _restaurants.removeAt(oldIndex);
              _restaurants.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            final restaurant = _restaurants[index];
            return Card(
              key: ValueKey(restaurant.urlId),
              color: const Color.fromARGB(255, 60, 60, 60),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(
                  Icons.drag_handle,
                  color: Colors.white70,
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
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Peruuta',
            style: TextStyle(color: Colors.white70),
          ),
        ),
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
    );
  }
}
