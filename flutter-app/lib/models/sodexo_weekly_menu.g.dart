// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sodexo_weekly_menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SodexoWeeklyMenuImpl _$$SodexoWeeklyMenuImplFromJson(
        Map<String, dynamic> json) =>
    _$SodexoWeeklyMenuImpl(
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
      timeperiod: json['timeperiod'] as String,
      mealdates: (json['mealdates'] as List<dynamic>)
          .map((e) => Mealdate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SodexoWeeklyMenuImplToJson(
        _$SodexoWeeklyMenuImpl instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'timeperiod': instance.timeperiod,
      'mealdates': instance.mealdates,
    };

_$MealdateImpl _$$MealdateImplFromJson(Map<String, dynamic> json) =>
    _$MealdateImpl(
      date: json['date'] as String,
      courses: (json['courses'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Course.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$MealdateImplToJson(_$MealdateImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'courses': instance.courses,
    };
