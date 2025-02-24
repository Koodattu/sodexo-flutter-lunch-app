// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sodexo_menu_common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MetaImpl _$$MetaImplFromJson(Map<String, dynamic> json) => _$MetaImpl(
      generatedTimestamp: (json['generated_timestamp'] as num).toInt(),
      refUrl: json['ref_url'] as String,
      refTitle: json['ref_title'] as String,
      restaurantMashieId: json['restaurant_mashie_id'] as String,
    );

Map<String, dynamic> _$$MetaImplToJson(_$MetaImpl instance) =>
    <String, dynamic>{
      'generated_timestamp': instance.generatedTimestamp,
      'ref_url': instance.refUrl,
      'ref_title': instance.refTitle,
      'restaurant_mashie_id': instance.restaurantMashieId,
    };

_$CourseImpl _$$CourseImplFromJson(Map<String, dynamic> json) => _$CourseImpl(
      titleFi: json['title_fi'] as String,
      titleEn: json['title_en'] as String,
      category: json['category'] as String,
      mealCategory: json['meal_category'] as String?,
      dietcodes: json['dietcodes'] as String,
      properties: json['properties'] as String,
      additionalDietInfo: AdditionalDietInfo.fromJson(
          json['additionalDietInfo'] as Map<String, dynamic>),
      recipes: (json['recipes'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Recipe.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$CourseImplToJson(_$CourseImpl instance) =>
    <String, dynamic>{
      'title_fi': instance.titleFi,
      'title_en': instance.titleEn,
      'category': instance.category,
      'meal_category': instance.mealCategory,
      'dietcodes': instance.dietcodes,
      'properties': instance.properties,
      'additionalDietInfo': instance.additionalDietInfo,
      'recipes': instance.recipes,
    };

_$AdditionalDietInfoImpl _$$AdditionalDietInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$AdditionalDietInfoImpl(
      allergens: json['allergens'] as String,
      dietcodeImages: (json['dietcodeImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$AdditionalDietInfoImplToJson(
        _$AdditionalDietInfoImpl instance) =>
    <String, dynamic>{
      'allergens': instance.allergens,
      'dietcodeImages': instance.dietcodeImages,
    };

_$RecipeImpl _$$RecipeImplFromJson(Map<String, dynamic> json) => _$RecipeImpl(
      name: json['name'] as String,
      ingredients: json['ingredients'],
      nutrients: json['nutrients'] as String,
    );

Map<String, dynamic> _$$RecipeImplToJson(_$RecipeImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'ingredients': instance.ingredients,
      'nutrients': instance.nutrients,
    };
