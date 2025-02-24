// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sodexo_daily_menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SodexoDailyMenuImpl _$$SodexoDailyMenuImplFromJson(
        Map<String, dynamic> json) =>
    _$SodexoDailyMenuImpl(
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
      courses: (json['courses'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Course.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$SodexoDailyMenuImplToJson(
        _$SodexoDailyMenuImpl instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'courses': instance.courses,
    };
