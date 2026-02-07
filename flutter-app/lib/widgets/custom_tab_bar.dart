import 'package:flutter/material.dart';

/// A reusable custom tab bar widget with consistent styling
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController? controller;
  final List<String> tabLabels;
  final bool isScrollable;

  const CustomTabBar({
    super.key,
    this.controller,
    required this.tabLabels,
    this.isScrollable = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 17, 17, 17),
      child: TabBar(
        controller: controller,
        isScrollable: isScrollable,
        tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
        indicator: const BoxDecoration(), // Remove the underline indicator
        dividerColor: Colors.transparent, // Remove the separator line
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        overlayColor: WidgetStateProperty.all(Colors.transparent), // Remove tap ripple effect
        splashFactory: NoSplash.splashFactory, // Remove splash effect
        labelPadding: isScrollable
            ? const EdgeInsets.symmetric(horizontal: 8.0)
            : null, // Reduce horizontal padding between tabs for scrollable tabs
        tabs: tabLabels.map((label) => Tab(text: label)).toList(),
      ),
    );
  }
}
