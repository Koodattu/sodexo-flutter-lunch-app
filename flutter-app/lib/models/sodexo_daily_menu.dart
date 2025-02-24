// To parse this JSON data, do
//
//     final sodexoDailyMenu = sodexoDailyMenuFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

import 'package:sodexo_flutter_lunch_app/models/sodexo_menu_common.dart';

part 'sodexo_daily_menu.freezed.dart';
part 'sodexo_daily_menu.g.dart';

SodexoDailyMenu sodexoDailyMenuFromJson(String str) => SodexoDailyMenu.fromJson(json.decode(str));

String sodexoDailyMenuToJson(SodexoDailyMenu data) => json.encode(data.toJson());

@freezed
class SodexoDailyMenu with _$SodexoDailyMenu {
  const factory SodexoDailyMenu({
    required Meta meta,
    required Map<String, Course> courses,
  }) = _SodexoDailyMenu;

  factory SodexoDailyMenu.fromJson(Map<String, dynamic> json) => _$SodexoDailyMenuFromJson(json);
}
