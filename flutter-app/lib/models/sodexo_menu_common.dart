import 'package:freezed_annotation/freezed_annotation.dart';

part 'sodexo_menu_common.freezed.dart';
part 'sodexo_menu_common.g.dart';

@freezed
class Meta with _$Meta {
  const factory Meta({
    @JsonKey(name: "generated_timestamp") required int generatedTimestamp,
    @JsonKey(name: "ref_url") required String refUrl,
    @JsonKey(name: "ref_title") required String refTitle,
    @JsonKey(name: "restaurant_mashie_id") required String restaurantMashieId,
  }) = _Meta;

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
}

@freezed
class Course with _$Course {
  const factory Course({
    @JsonKey(name: "title_fi") required String titleFi,
    @JsonKey(name: "title_en") required String titleEn,
    required String category,
    // Use a nullable type if the value can be null:
    @JsonKey(name: "meal_category") String? mealCategory,
    required String dietcodes,
    required String properties,
    @JsonKey(name: "additionalDietInfo") required AdditionalDietInfo additionalDietInfo,
    // Instead of enumerating keys, we parse recipes as a map.
    required Map<String, Recipe> recipes,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}

@freezed
class AdditionalDietInfo with _$AdditionalDietInfo {
  const factory AdditionalDietInfo({
    required String allergens,
    // Make this optional if it’s not always present.
    List<String>? dietcodeImages,
  }) = _AdditionalDietInfo;

  factory AdditionalDietInfo.fromJson(Map<String, dynamic> json) => _$AdditionalDietInfoFromJson(json);
}

@freezed
class Recipe with _$Recipe {
  const factory Recipe({
    required String name,
    // If ingredients can be either a String or a List, consider writing a custom converter or simply using dynamic.
    required dynamic ingredients,
    required String nutrients,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}
