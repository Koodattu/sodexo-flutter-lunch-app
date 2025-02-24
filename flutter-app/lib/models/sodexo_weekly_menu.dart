// To parse this JSON data, do
//
//     final sodexoWeeklyMenu = sodexoWeeklyMenuFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

import 'package:sodexo_flutter_lunch_app/models/sodexo_menu_common.dart';

part 'sodexo_weekly_menu.freezed.dart';
part 'sodexo_weekly_menu.g.dart';

SodexoWeeklyMenu sodexoWeeklyMenuFromJson(String str) => SodexoWeeklyMenu.fromJson(json.decode(str));

String sodexoWeeklyMenuToJson(SodexoWeeklyMenu data) => json.encode(data.toJson());

@freezed
class SodexoWeeklyMenu with _$SodexoWeeklyMenu {
  const factory SodexoWeeklyMenu({
    @JsonKey(name: "meta") required Meta meta,
    @JsonKey(name: "timeperiod") required String timeperiod,
    @JsonKey(name: "mealdates") required List<Mealdate> mealdates,
  }) = _SodexoWeeklyMenu;

  factory SodexoWeeklyMenu.fromJson(Map<String, dynamic> json) => _$SodexoWeeklyMenuFromJson(json);
}

@freezed
class Mealdate with _$Mealdate {
  const factory Mealdate({
    @JsonKey(name: "date") required String date,
    @JsonKey(name: "courses") required Map<String, Course> courses,
  }) = _Mealdate;

  factory Mealdate.fromJson(Map<String, dynamic> json) => _$MealdateFromJson(json);
}
