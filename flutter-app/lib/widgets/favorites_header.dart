import 'package:flutter/material.dart';

/// A reusable header widget for the favorites page with refresh and other action buttons
class FavoritesHeader extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback? onReorder;
  final VoidCallback? onFilter;

  const FavoritesHeader({
    super.key,
    required this.onRefresh,
    this.onReorder,
    this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Suosikit",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: onRefresh,
            tooltip: 'Refresh',
          ),
          IconButton(
            key: const Key('reorder_button'),
            icon: Icon(
              Icons.reorder,
              color: onReorder != null ? Colors.white : Colors.transparent,
            ),
            onPressed: onReorder,
            tooltip: onReorder != null ? 'Reorder favorites' : null,
          ),
          IconButton(
            key: const Key('language_button'),
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {}, // No functionality yet
            tooltip: 'Language',
          ),
          IconButton(
            key: const Key('filter_button'),
            icon: Icon(
              Icons.filter_list,
              color: onFilter != null ? Colors.white : Colors.transparent,
            ),
            onPressed: onFilter,
            tooltip: onFilter != null ? 'Filters' : null,
          ),
        ],
      ),
    );
  }
}
