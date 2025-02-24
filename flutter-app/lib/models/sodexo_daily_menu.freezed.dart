// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sodexo_daily_menu.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SodexoDailyMenu _$SodexoDailyMenuFromJson(Map<String, dynamic> json) {
  return _SodexoDailyMenu.fromJson(json);
}

/// @nodoc
mixin _$SodexoDailyMenu {
  Meta get meta => throw _privateConstructorUsedError;
  Map<String, Course> get courses => throw _privateConstructorUsedError;

  /// Serializes this SodexoDailyMenu to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SodexoDailyMenu
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SodexoDailyMenuCopyWith<SodexoDailyMenu> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SodexoDailyMenuCopyWith<$Res> {
  factory $SodexoDailyMenuCopyWith(
          SodexoDailyMenu value, $Res Function(SodexoDailyMenu) then) =
      _$SodexoDailyMenuCopyWithImpl<$Res, SodexoDailyMenu>;
  @useResult
  $Res call({Meta meta, Map<String, Course> courses});

  $MetaCopyWith<$Res> get meta;
}

/// @nodoc
class _$SodexoDailyMenuCopyWithImpl<$Res, $Val extends SodexoDailyMenu>
    implements $SodexoDailyMenuCopyWith<$Res> {
  _$SodexoDailyMenuCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SodexoDailyMenu
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meta = null,
    Object? courses = null,
  }) {
    return _then(_value.copyWith(
      meta: null == meta
          ? _value.meta
          : meta // ignore: cast_nullable_to_non_nullable
              as Meta,
      courses: null == courses
          ? _value.courses
          : courses // ignore: cast_nullable_to_non_nullable
              as Map<String, Course>,
    ) as $Val);
  }

  /// Create a copy of SodexoDailyMenu
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MetaCopyWith<$Res> get meta {
    return $MetaCopyWith<$Res>(_value.meta, (value) {
      return _then(_value.copyWith(meta: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SodexoDailyMenuImplCopyWith<$Res>
    implements $SodexoDailyMenuCopyWith<$Res> {
  factory _$$SodexoDailyMenuImplCopyWith(_$SodexoDailyMenuImpl value,
          $Res Function(_$SodexoDailyMenuImpl) then) =
      __$$SodexoDailyMenuImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Meta meta, Map<String, Course> courses});

  @override
  $MetaCopyWith<$Res> get meta;
}

/// @nodoc
class __$$SodexoDailyMenuImplCopyWithImpl<$Res>
    extends _$SodexoDailyMenuCopyWithImpl<$Res, _$SodexoDailyMenuImpl>
    implements _$$SodexoDailyMenuImplCopyWith<$Res> {
  __$$SodexoDailyMenuImplCopyWithImpl(
      _$SodexoDailyMenuImpl _value, $Res Function(_$SodexoDailyMenuImpl) _then)
      : super(_value, _then);

  /// Create a copy of SodexoDailyMenu
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meta = null,
    Object? courses = null,
  }) {
    return _then(_$SodexoDailyMenuImpl(
      meta: null == meta
          ? _value.meta
          : meta // ignore: cast_nullable_to_non_nullable
              as Meta,
      courses: null == courses
          ? _value._courses
          : courses // ignore: cast_nullable_to_non_nullable
              as Map<String, Course>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SodexoDailyMenuImpl implements _SodexoDailyMenu {
  const _$SodexoDailyMenuImpl(
      {required this.meta, required final Map<String, Course> courses})
      : _courses = courses;

  factory _$SodexoDailyMenuImpl.fromJson(Map<String, dynamic> json) =>
      _$$SodexoDailyMenuImplFromJson(json);

  @override
  final Meta meta;
  final Map<String, Course> _courses;
  @override
  Map<String, Course> get courses {
    if (_courses is EqualUnmodifiableMapView) return _courses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_courses);
  }

  @override
  String toString() {
    return 'SodexoDailyMenu(meta: $meta, courses: $courses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SodexoDailyMenuImpl &&
            (identical(other.meta, meta) || other.meta == meta) &&
            const DeepCollectionEquality().equals(other._courses, _courses));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, meta, const DeepCollectionEquality().hash(_courses));

  /// Create a copy of SodexoDailyMenu
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SodexoDailyMenuImplCopyWith<_$SodexoDailyMenuImpl> get copyWith =>
      __$$SodexoDailyMenuImplCopyWithImpl<_$SodexoDailyMenuImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SodexoDailyMenuImplToJson(
      this,
    );
  }
}

abstract class _SodexoDailyMenu implements SodexoDailyMenu {
  const factory _SodexoDailyMenu(
      {required final Meta meta,
      required final Map<String, Course> courses}) = _$SodexoDailyMenuImpl;

  factory _SodexoDailyMenu.fromJson(Map<String, dynamic> json) =
      _$SodexoDailyMenuImpl.fromJson;

  @override
  Meta get meta;
  @override
  Map<String, Course> get courses;

  /// Create a copy of SodexoDailyMenu
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SodexoDailyMenuImplCopyWith<_$SodexoDailyMenuImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
