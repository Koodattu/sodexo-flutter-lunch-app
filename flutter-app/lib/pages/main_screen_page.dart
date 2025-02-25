import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'favorite_menus_page.dart';
import 'restaurants_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Both pages remain in memory using an IndexedStack.
  final List<Widget> _pages = const [
    FavoriteMenusPage(),
    RestaurantsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.red.shade900]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.red.shade900, Colors.blue.shade900]),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: WidgetStateColor.resolveWith((states) {
                if (_selectedIndex == 0) {
                  return Colors.blue.shade900;
                }
                return Colors.red.shade900;
              }),
              labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  );
                }
                return const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(size: 28);
                }
                return IconThemeData(size: 24);
              }),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.black,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: FaIcon(FontAwesomeIcons.heartCrack),
                  selectedIcon: FaIcon(FontAwesomeIcons.solidHeart),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: Icon(Icons.restaurant_menu),
                  selectedIcon: Icon(Icons.restaurant),
                  label: 'Restaurants',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
