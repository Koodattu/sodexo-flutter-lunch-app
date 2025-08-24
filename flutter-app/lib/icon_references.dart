import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// This file ensures all icons used in the app are included in web builds
/// by creating explicit references to prevent tree-shaking
class IconReferences {
  static const List<IconData> materialIcons = [
    // From course_card.dart
    Icons.school,
    Icons.work,
    Icons.person,
    Icons.local_dining,
    Icons.info_outline,

    // From favorites_header.dart
    Icons.refresh,
    Icons.reorder,
    Icons.language,
    Icons.filter_list,

    // From restaurants_page.dart
    Icons.restaurant_menu,
    Icons.restaurant,
    Icons.location_on,
    Icons.close,
    Icons.search,
    Icons.star,
    Icons.star_border,
    Icons.access_time,
    Icons.local_cafe,
    Icons.category,

    // From reorder_favorites_dialog.dart
    Icons.drag_handle,
  ];

  static const List<IconData> fontAwesomeIcons = [
    // From main_screen_page.dart
    FontAwesomeIcons.heartCrack,
    FontAwesomeIcons.solidHeart,

    // From restaurants_page.dart
    FontAwesomeIcons.spinner,
  ];

  /// Call this method somewhere in your app to ensure icons are referenced
  static void ensureIconsAreIncluded() {
    // Force the icon fonts to be loaded by accessing their properties
    for (var icon in materialIcons) {
      icon.codePoint;
      icon.fontFamily;
      icon.fontPackage;
    }

    for (var icon in fontAwesomeIcons) {
      icon.codePoint;
      icon.fontFamily;
      icon.fontPackage;
    }
  }
}
