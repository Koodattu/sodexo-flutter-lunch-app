// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sodexo_weekly_menu.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SodexoWeeklyMenu _$SodexoWeeklyMenuFromJson(Map<String, dynamic> json) {
  return _SodexoWeeklyMenu.fromJson(json);
}

/// @nodoc
mixin _$SodexoWeeklyMenu {
  @JsonKey(name: "meta")
  Meta get meta => throw _privateConstructorUsedError;
  @JsonKey(name: "timeperiod")
  String get timeperiod => throw _privateConstructorUsedError;
  @JsonKey(name: "mealdates")
  List<Mealdate> get mealdates => throw _privateConstructorUsedError;

  /// Serializes this SodexoWeeklyMenu to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SodexoWeeklyMenu
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SodexoWeeklyMenuCopyWith<SodexoWeeklyMenu> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SodexoWeeklyMenuCopyWith<$Res> {
  factory $SodexoWeeklyMenuCopyWith(
          SodexoWeeklyMenu value, $Res Function(SodexoWeeklyMenu) then) =
      _$SodexoWeeklyMenuCopyWithImpl<$Res, SodexoWeeklyMenu>;
  @useResult
  $Res call(
      {@JsonKey(name: "meta") Meta meta,
      @JsonKey(name: "timeperiod") String timeperiod,
      @JsonKey(name: "mealdates") List<Mealdate> mealdates});

  $MetaCopyWith<$Res> get meta;
}

/// @nodoc
class _$SodexoWeeklyMenuCopyWithImpl<$Res, $Val extends SodexoWeeklyMenu>
    implements $SodexoWeeklyMenuCopyWith<$Res> {
  _$SodexoWeeklyMenuCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SodexoWeeklyMenu
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meta = null,
    Object? timeperiod = null,
    Object? mealdates = null,
  }) {
    return _then(_value.copyWith(
      meta: null == meta
          ? _value.meta
          : meta // ignore: cast_nullable_to_non_nullable
              as Meta,
      timeperiod: null == timeperiod
          ? _value.timeperiod
          : timeperiod // ignore: cast_nullable_to_non_nullable
              as String,
      mealdates: null == mealdates
          ? _value.mealdates
          : mealdates // ignore: cast_nullable_to_non_nullable
              as List<Mealdate>,
    ) as $Val);
  }

  /// Create a copy of SodexoWeeklyMenu
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
abstract class _$$SodexoWeeklyMenuImplCopyWith<$Res>
    implements $SodexoWeeklyMenuCopyWith<$Res> {
  factory _$$SodexoWeeklyMenuImplCopyWith(_$SodexoWeeklyMenuImpl value,
          $Res Function(_$SodexoWeeklyMenuImpl) then) =
      __$$SodexoWeeklyMenuImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "meta") Meta meta,
      @JsonKey(name: "timeperiod") String timeperiod,
      @JsonKey(name: "mealdates") List<Mealdate> mealdates});

  @override
  $MetaCopyWith<$Res> get meta;
}

/// @nodoc
class __$$SodexoWeeklyMenuImplCopyWithImpl<$Res>
    extends _$SodexoWeeklyMenuCopyWithImpl<$Res, _$SodexoWeeklyMenuImpl>
    implements _$$SodexoWeeklyMenuImplCopyWith<$Res> {
  __$$SodexoWeeklyMenuImplCopyWithImpl(_$SodexoWeeklyMenuImpl _value,
      $Res Function(_$SodexoWeeklyMenuImpl) _then)
      : super(_value, _then);

  /// Create a copy of SodexoWeeklyMenu
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meta = null,
    Object? timeperiod = null,
    Object? mealdates = null,
  }) {
    return _then(_$SodexoWeeklyMenuImpl(
      meta: null == meta
          ? _value.meta
          : meta // ignore: cast_nullable_to_non_nullable
              as Meta,
      timeperiod: null == timeperiod
          ? _value.timeperiod
          : timeperiod // ignore: cast_nullable_to_non_nullable
              as String,
      mealdates: null == mealdates
          ? _value._mealdates
          : mealdates // ignore: cast_nullable_to_non_nullable
              as List<Mealdate>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SodexoWeeklyMenuImpl implements _SodexoWeeklyMenu {
  const _$SodexoWeeklyMenuImpl(
      {@JsonKey(name: "meta") required this.meta,
      @JsonKey(name: "timeperiod") required this.timeperiod,
      @JsonKey(name: "mealdates") required final List<Mealdate> mealdates})
      : _mealdates = mealdates;

  factory _$SodexoWeeklyMenuImpl.fromJson(Map<String, dynamic> json) =>
      _$$SodexoWeeklyMenuImplFromJson(json);

  @override
  @JsonKey(name: "meta")
  final Meta meta;
  @override
  @JsonKey(name: "timeperiod")
  final String timeperiod;
  final List<Mealdate> _mealdates;
  @override
  @JsonKey(name: "mealdates")
  List<Mealdate> get mealdates {
    if (_mealdates is EqualUnmodifiableListView) return _mealdates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mealdates);
  }

  @override
  String toString() {
    return 'SodexoWeeklyMenu(meta: $meta, timeperiod: $timeperiod, mealdates: $mealdates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SodexoWeeklyMenuImpl &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.timeperiod, timeperiod) ||
                other.timeperiod == timeperiod) &&
            const DeepCollectionEquality()
                .equals(other._mealdates, _mealdates));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, meta, timeperiod,
      const DeepCollectionEquality().hash(_mealdates));

  /// Create a copy of SodexoWeeklyMenu
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SodexoWeeklyMenuImplCopyWith<_$SodexoWeeklyMenuImpl> get copyWith =>
      __$$SodexoWeeklyMenuImplCopyWithImpl<_$SodexoWeeklyMenuImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SodexoWeeklyMenuImplToJson(
      this,
    );
  }
}

abstract class _SodexoWeeklyMenu implements SodexoWeeklyMenu {
  const factory _SodexoWeeklyMenu(
      {@JsonKey(name: "meta") required final Meta meta,
      @JsonKey(name: "timeperiod") required final String timeperiod,
      @JsonKey(name: "mealdates")
      required final List<Mealdate> mealdates}) = _$SodexoWeeklyMenuImpl;

  factory _SodexoWeeklyMenu.fromJson(Map<String, dynamic> json) =
      _$SodexoWeeklyMenuImpl.fromJson;

  @override
  @JsonKey(name: "meta")
  Meta get meta;
  @override
  @JsonKey(name: "timeperiod")
  String get timeperiod;
  @override
  @JsonKey(name: "mealdates")
  List<Mealdate> get mealdates;

  /// Create a copy of SodexoWeeklyMenu
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SodexoWeeklyMenuImplCopyWith<_$SodexoWeeklyMenuImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Mealdate _$MealdateFromJson(Map<String, dynamic> json) {
  return _Mealdate.fromJson(json);
}

/// @nodoc
mixin _$Mealdate {
  @JsonKey(name: "date")
  String get date => throw _privateConstructorUsedError;
  @JsonKey(name: "courses")
  Map<String, Course> get courses => throw _privateConstructorUsedError;

  /// Serializes this Mealdate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Mealdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealdateCopyWith<Mealdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealdateCopyWith<$Res> {
  factory $MealdateCopyWith(Mealdate value, $Res Function(Mealdate) then) =
      _$MealdateCopyWithImpl<$Res, Mealdate>;
  @useResult
  $Res call(
      {@JsonKey(name: "date") String date,
      @JsonKey(name: "courses") Map<String, Course> courses});
}

/// @nodoc
class _$MealdateCopyWithImpl<$Res, $Val extends Mealdate>
    implements $MealdateCopyWith<$Res> {
  _$MealdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Mealdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? courses = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      courses: null == courses
          ? _value.courses
          : courses // ignore: cast_nullable_to_non_nullable
              as Map<String, Course>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MealdateImplCopyWith<$Res>
    implements $MealdateCopyWith<$Res> {
  factory _$$MealdateImplCopyWith(
          _$MealdateImpl value, $Res Function(_$MealdateImpl) then) =
      __$$MealdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "date") String date,
      @JsonKey(name: "courses") Map<String, Course> courses});
}

/// @nodoc
class __$$MealdateImplCopyWithImpl<$Res>
    extends _$MealdateCopyWithImpl<$Res, _$MealdateImpl>
    implements _$$MealdateImplCopyWith<$Res> {
  __$$MealdateImplCopyWithImpl(
      _$MealdateImpl _value, $Res Function(_$MealdateImpl) _then)
      : super(_value, _then);

  /// Create a copy of Mealdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? courses = null,
  }) {
    return _then(_$MealdateImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      courses: null == courses
          ? _value._courses
          : courses // ignore: cast_nullable_to_non_nullable
              as Map<String, Course>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MealdateImpl implements _Mealdate {
  const _$MealdateImpl(
      {@JsonKey(name: "date") required this.date,
      @JsonKey(name: "courses") required final Map<String, Course> courses})
      : _courses = courses;

  factory _$MealdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealdateImplFromJson(json);

  @override
  @JsonKey(name: "date")
  final String date;
  final Map<String, Course> _courses;
  @override
  @JsonKey(name: "courses")
  Map<String, Course> get courses {
    if (_courses is EqualUnmodifiableMapView) return _courses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_courses);
  }

  @override
  String toString() {
    return 'Mealdate(date: $date, courses: $courses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealdateImpl &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._courses, _courses));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, date, const DeepCollectionEquality().hash(_courses));

  /// Create a copy of Mealdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealdateImplCopyWith<_$MealdateImpl> get copyWith =>
      __$$MealdateImplCopyWithImpl<_$MealdateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealdateImplToJson(
      this,
    );
  }
}

abstract class _Mealdate implements Mealdate {
  const factory _Mealdate(
      {@JsonKey(name: "date") required final String date,
      @JsonKey(name: "courses")
      required final Map<String, Course> courses}) = _$MealdateImpl;

  factory _Mealdate.fromJson(Map<String, dynamic> json) =
      _$MealdateImpl.fromJson;

  @override
  @JsonKey(name: "date")
  String get date;
  @override
  @JsonKey(name: "courses")
  Map<String, Course> get courses;

  /// Create a copy of Mealdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealdateImplCopyWith<_$MealdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
