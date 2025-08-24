import 'package:flutter/material.dart';
import '../services/menu_service.dart';
import 'weekly_menu_list.dart';
import 'menu_state_builder.dart';

/// A widget that handles displaying a single restaurant's menu with refresh capability
class MenuTabView extends StatelessWidget {
  final String restaurantJsonId;
  final ValueNotifier<int> refreshNotifier;

  const MenuTabView({
    super.key,
    required this.restaurantJsonId,
    required this.refreshNotifier,
  });

  Future<Map<String, dynamic>?> _getMenuForRestaurant(int refreshKey) async {
    return MenuService.fetchMenuWithFallback(restaurantJsonId);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: refreshNotifier,
      builder: (context, refreshKey, child) {
        return FutureBuilder<Map<String, dynamic>?>(
          key: ValueKey('$restaurantJsonId-$refreshKey'),
          future: _getMenuForRestaurant(refreshKey),
          builder: (context, menuSnapshot) {
            return MenuStateBuilder(
              isLoading: menuSnapshot.connectionState != ConnectionState.done,
              hasError: false, // We handle errors silently in the service
              isEmpty: !menuSnapshot.hasData || menuSnapshot.data == null || (menuSnapshot.data?.isEmpty ?? true),
              errorMessage: "Ruokalistan lataaminen epäonnistui.",
              emptyMessage: "Ei ruokalistaa saatavilla.",
              contentBuilder: () => WeeklyMenuList(menuData: menuSnapshot.data!),
            );
          },
        );
      },
    );
  }
}
