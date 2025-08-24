import 'package:flutter/material.dart';

/// A reusable widget that handles common menu states: loading, error, empty, and content
class MenuStateBuilder extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final bool isEmpty;
  final String errorMessage;
  final String emptyMessage;
  final Widget Function() contentBuilder;

  const MenuStateBuilder({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.isEmpty,
    required this.errorMessage,
    required this.emptyMessage,
    required this.contentBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (hasError) {
      return Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
    if (isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
    return contentBuilder();
  }
}
