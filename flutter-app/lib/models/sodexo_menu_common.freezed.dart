// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sodexo_menu_common.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Meta _$MetaFromJson(Map<String, dynamic> json) {
  return _Meta.fromJson(json);
}

/// @nodoc
mixin _$Meta {
  @JsonKey(name: "generated_timestamp")
  int get generatedTimestamp => throw _privateConstructorUsedError;
  @JsonKey(name: "ref_url")
  String get refUrl => throw _privateConstructorUsedError;
  @JsonKey(name: "ref_title")
  String get refTitle => throw _privateConstructorUsedError;
  @JsonKey(name: "restaurant_mashie_id")
  String get restaurantMashieId => throw _privateConstructorUsedError;

  /// Serializes this Meta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MetaCopyWith<Meta> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MetaCopyWith<$Res> {
  factory $MetaCopyWith(Meta value, $Res Function(Meta) then) =
      _$MetaCopyWithImpl<$Res, Meta>;
  @useResult
  $Res call(
      {@JsonKey(name: "generated_timestamp") int generatedTimestamp,
      @JsonKey(name: "ref_url") String refUrl,
      @JsonKey(name: "ref_title") String refTitle,
      @JsonKey(name: "restaurant_mashie_id") String restaurantMashieId});
}

/// @nodoc
class _$MetaCopyWithImpl<$Res, $Val extends Meta>
    implements $MetaCopyWith<$Res> {
  _$MetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? generatedTimestamp = null,
    Object? refUrl = null,
    Object? refTitle = null,
    Object? restaurantMashieId = null,
  }) {
    return _then(_value.copyWith(
      generatedTimestamp: null == generatedTimestamp
          ? _value.generatedTimestamp
          : generatedTimestamp // ignore: cast_nullable_to_non_nullable
              as int,
      refUrl: null == refUrl
          ? _value.refUrl
          : refUrl // ignore: cast_nullable_to_non_nullable
              as String,
      refTitle: null == refTitle
          ? _value.refTitle
          : refTitle // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantMashieId: null == restaurantMashieId
          ? _value.restaurantMashieId
          : restaurantMashieId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MetaImplCopyWith<$Res> implements $MetaCopyWith<$Res> {
  factory _$$MetaImplCopyWith(
          _$MetaImpl value, $Res Function(_$MetaImpl) then) =
      __$$MetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "generated_timestamp") int generatedTimestamp,
      @JsonKey(name: "ref_url") String refUrl,
      @JsonKey(name: "ref_title") String refTitle,
      @JsonKey(name: "restaurant_mashie_id") String restaurantMashieId});
}

/// @nodoc
class __$$MetaImplCopyWithImpl<$Res>
    extends _$MetaCopyWithImpl<$Res, _$MetaImpl>
    implements _$$MetaImplCopyWith<$Res> {
  __$$MetaImplCopyWithImpl(_$MetaImpl _value, $Res Function(_$MetaImpl) _then)
      : super(_value, _then);

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? generatedTimestamp = null,
    Object? refUrl = null,
    Object? refTitle = null,
    Object? restaurantMashieId = null,
  }) {
    return _then(_$MetaImpl(
      generatedTimestamp: null == generatedTimestamp
          ? _value.generatedTimestamp
          : generatedTimestamp // ignore: cast_nullable_to_non_nullable
              as int,
      refUrl: null == refUrl
          ? _value.refUrl
          : refUrl // ignore: cast_nullable_to_non_nullable
              as String,
      refTitle: null == refTitle
          ? _value.refTitle
          : refTitle // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantMashieId: null == restaurantMashieId
          ? _value.restaurantMashieId
          : restaurantMashieId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MetaImpl implements _Meta {
  const _$MetaImpl(
      {@JsonKey(name: "generated_timestamp") required this.generatedTimestamp,
      @JsonKey(name: "ref_url") required this.refUrl,
      @JsonKey(name: "ref_title") required this.refTitle,
      @JsonKey(name: "restaurant_mashie_id") required this.restaurantMashieId});

  factory _$MetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetaImplFromJson(json);

  @override
  @JsonKey(name: "generated_timestamp")
  final int generatedTimestamp;
  @override
  @JsonKey(name: "ref_url")
  final String refUrl;
  @override
  @JsonKey(name: "ref_title")
  final String refTitle;
  @override
  @JsonKey(name: "restaurant_mashie_id")
  final String restaurantMashieId;

  @override
  String toString() {
    return 'Meta(generatedTimestamp: $generatedTimestamp, refUrl: $refUrl, refTitle: $refTitle, restaurantMashieId: $restaurantMashieId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MetaImpl &&
            (identical(other.generatedTimestamp, generatedTimestamp) ||
                other.generatedTimestamp == generatedTimestamp) &&
            (identical(other.refUrl, refUrl) || other.refUrl == refUrl) &&
            (identical(other.refTitle, refTitle) ||
                other.refTitle == refTitle) &&
            (identical(other.restaurantMashieId, restaurantMashieId) ||
                other.restaurantMashieId == restaurantMashieId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, generatedTimestamp, refUrl, refTitle, restaurantMashieId);

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MetaImplCopyWith<_$MetaImpl> get copyWith =>
      __$$MetaImplCopyWithImpl<_$MetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MetaImplToJson(
      this,
    );
  }
}

abstract class _Meta implements Meta {
  const factory _Meta(
      {@JsonKey(name: "generated_timestamp")
      required final int generatedTimestamp,
      @JsonKey(name: "ref_url") required final String refUrl,
      @JsonKey(name: "ref_title") required final String refTitle,
      @JsonKey(name: "restaurant_mashie_id")
      required final String restaurantMashieId}) = _$MetaImpl;

  factory _Meta.fromJson(Map<String, dynamic> json) = _$MetaImpl.fromJson;

  @override
  @JsonKey(name: "generated_timestamp")
  int get generatedTimestamp;
  @override
  @JsonKey(name: "ref_url")
  String get refUrl;
  @override
  @JsonKey(name: "ref_title")
  String get refTitle;
  @override
  @JsonKey(name: "restaurant_mashie_id")
  String get restaurantMashieId;

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MetaImplCopyWith<_$MetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Course _$CourseFromJson(Map<String, dynamic> json) {
  return _Course.fromJson(json);
}

/// @nodoc
mixin _$Course {
  @JsonKey(name: "title_fi")
  String get titleFi => throw _privateConstructorUsedError;
  @JsonKey(name: "title_en")
  String get titleEn => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // Use a nullable type if the value can be null:
  @JsonKey(name: "meal_category")
  String? get mealCategory => throw _privateConstructorUsedError;
  String get dietcodes => throw _privateConstructorUsedError;
  String get properties => throw _privateConstructorUsedError;
  @JsonKey(name: "additionalDietInfo")
  AdditionalDietInfo get additionalDietInfo =>
      throw _privateConstructorUsedError; // Instead of enumerating keys, we parse recipes as a map.
  Map<String, Recipe> get recipes => throw _privateConstructorUsedError;

  /// Serializes this Course to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseCopyWith<Course> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseCopyWith<$Res> {
  factory $CourseCopyWith(Course value, $Res Function(Course) then) =
      _$CourseCopyWithImpl<$Res, Course>;
  @useResult
  $Res call(
      {@JsonKey(name: "title_fi") String titleFi,
      @JsonKey(name: "title_en") String titleEn,
      String category,
      @JsonKey(name: "meal_category") String? mealCategory,
      String dietcodes,
      String properties,
      @JsonKey(name: "additionalDietInfo")
      AdditionalDietInfo additionalDietInfo,
      Map<String, Recipe> recipes});

  $AdditionalDietInfoCopyWith<$Res> get additionalDietInfo;
}

/// @nodoc
class _$CourseCopyWithImpl<$Res, $Val extends Course>
    implements $CourseCopyWith<$Res> {
  _$CourseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? titleFi = null,
    Object? titleEn = null,
    Object? category = null,
    Object? mealCategory = freezed,
    Object? dietcodes = null,
    Object? properties = null,
    Object? additionalDietInfo = null,
    Object? recipes = null,
  }) {
    return _then(_value.copyWith(
      titleFi: null == titleFi
          ? _value.titleFi
          : titleFi // ignore: cast_nullable_to_non_nullable
              as String,
      titleEn: null == titleEn
          ? _value.titleEn
          : titleEn // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      mealCategory: freezed == mealCategory
          ? _value.mealCategory
          : mealCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      dietcodes: null == dietcodes
          ? _value.dietcodes
          : dietcodes // ignore: cast_nullable_to_non_nullable
              as String,
      properties: null == properties
          ? _value.properties
          : properties // ignore: cast_nullable_to_non_nullable
              as String,
      additionalDietInfo: null == additionalDietInfo
          ? _value.additionalDietInfo
          : additionalDietInfo // ignore: cast_nullable_to_non_nullable
              as AdditionalDietInfo,
      recipes: null == recipes
          ? _value.recipes
          : recipes // ignore: cast_nullable_to_non_nullable
              as Map<String, Recipe>,
    ) as $Val);
  }

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AdditionalDietInfoCopyWith<$Res> get additionalDietInfo {
    return $AdditionalDietInfoCopyWith<$Res>(_value.additionalDietInfo,
        (value) {
      return _then(_value.copyWith(additionalDietInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CourseImplCopyWith<$Res> implements $CourseCopyWith<$Res> {
  factory _$$CourseImplCopyWith(
          _$CourseImpl value, $Res Function(_$CourseImpl) then) =
      __$$CourseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "title_fi") String titleFi,
      @JsonKey(name: "title_en") String titleEn,
      String category,
      @JsonKey(name: "meal_category") String? mealCategory,
      String dietcodes,
      String properties,
      @JsonKey(name: "additionalDietInfo")
      AdditionalDietInfo additionalDietInfo,
      Map<String, Recipe> recipes});

  @override
  $AdditionalDietInfoCopyWith<$Res> get additionalDietInfo;
}

/// @nodoc
class __$$CourseImplCopyWithImpl<$Res>
    extends _$CourseCopyWithImpl<$Res, _$CourseImpl>
    implements _$$CourseImplCopyWith<$Res> {
  __$$CourseImplCopyWithImpl(
      _$CourseImpl _value, $Res Function(_$CourseImpl) _then)
      : super(_value, _then);

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? titleFi = null,
    Object? titleEn = null,
    Object? category = null,
    Object? mealCategory = freezed,
    Object? dietcodes = null,
    Object? properties = null,
    Object? additionalDietInfo = null,
    Object? recipes = null,
  }) {
    return _then(_$CourseImpl(
      titleFi: null == titleFi
          ? _value.titleFi
          : titleFi // ignore: cast_nullable_to_non_nullable
              as String,
      titleEn: null == titleEn
          ? _value.titleEn
          : titleEn // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      mealCategory: freezed == mealCategory
          ? _value.mealCategory
          : mealCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      dietcodes: null == dietcodes
          ? _value.dietcodes
          : dietcodes // ignore: cast_nullable_to_non_nullable
              as String,
      properties: null == properties
          ? _value.properties
          : properties // ignore: cast_nullable_to_non_nullable
              as String,
      additionalDietInfo: null == additionalDietInfo
          ? _value.additionalDietInfo
          : additionalDietInfo // ignore: cast_nullable_to_non_nullable
              as AdditionalDietInfo,
      recipes: null == recipes
          ? _value._recipes
          : recipes // ignore: cast_nullable_to_non_nullable
              as Map<String, Recipe>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseImpl implements _Course {
  const _$CourseImpl(
      {@JsonKey(name: "title_fi") required this.titleFi,
      @JsonKey(name: "title_en") required this.titleEn,
      required this.category,
      @JsonKey(name: "meal_category") this.mealCategory,
      required this.dietcodes,
      required this.properties,
      @JsonKey(name: "additionalDietInfo") required this.additionalDietInfo,
      required final Map<String, Recipe> recipes})
      : _recipes = recipes;

  factory _$CourseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseImplFromJson(json);

  @override
  @JsonKey(name: "title_fi")
  final String titleFi;
  @override
  @JsonKey(name: "title_en")
  final String titleEn;
  @override
  final String category;
// Use a nullable type if the value can be null:
  @override
  @JsonKey(name: "meal_category")
  final String? mealCategory;
  @override
  final String dietcodes;
  @override
  final String properties;
  @override
  @JsonKey(name: "additionalDietInfo")
  final AdditionalDietInfo additionalDietInfo;
// Instead of enumerating keys, we parse recipes as a map.
  final Map<String, Recipe> _recipes;
// Instead of enumerating keys, we parse recipes as a map.
  @override
  Map<String, Recipe> get recipes {
    if (_recipes is EqualUnmodifiableMapView) return _recipes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_recipes);
  }

  @override
  String toString() {
    return 'Course(titleFi: $titleFi, titleEn: $titleEn, category: $category, mealCategory: $mealCategory, dietcodes: $dietcodes, properties: $properties, additionalDietInfo: $additionalDietInfo, recipes: $recipes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseImpl &&
            (identical(other.titleFi, titleFi) || other.titleFi == titleFi) &&
            (identical(other.titleEn, titleEn) || other.titleEn == titleEn) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.mealCategory, mealCategory) ||
                other.mealCategory == mealCategory) &&
            (identical(other.dietcodes, dietcodes) ||
                other.dietcodes == dietcodes) &&
            (identical(other.properties, properties) ||
                other.properties == properties) &&
            (identical(other.additionalDietInfo, additionalDietInfo) ||
                other.additionalDietInfo == additionalDietInfo) &&
            const DeepCollectionEquality().equals(other._recipes, _recipes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      titleFi,
      titleEn,
      category,
      mealCategory,
      dietcodes,
      properties,
      additionalDietInfo,
      const DeepCollectionEquality().hash(_recipes));

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseImplCopyWith<_$CourseImpl> get copyWith =>
      __$$CourseImplCopyWithImpl<_$CourseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseImplToJson(
      this,
    );
  }
}

abstract class _Course implements Course {
  const factory _Course(
      {@JsonKey(name: "title_fi") required final String titleFi,
      @JsonKey(name: "title_en") required final String titleEn,
      required final String category,
      @JsonKey(name: "meal_category") final String? mealCategory,
      required final String dietcodes,
      required final String properties,
      @JsonKey(name: "additionalDietInfo")
      required final AdditionalDietInfo additionalDietInfo,
      required final Map<String, Recipe> recipes}) = _$CourseImpl;

  factory _Course.fromJson(Map<String, dynamic> json) = _$CourseImpl.fromJson;

  @override
  @JsonKey(name: "title_fi")
  String get titleFi;
  @override
  @JsonKey(name: "title_en")
  String get titleEn;
  @override
  String get category; // Use a nullable type if the value can be null:
  @override
  @JsonKey(name: "meal_category")
  String? get mealCategory;
  @override
  String get dietcodes;
  @override
  String get properties;
  @override
  @JsonKey(name: "additionalDietInfo")
  AdditionalDietInfo
      get additionalDietInfo; // Instead of enumerating keys, we parse recipes as a map.
  @override
  Map<String, Recipe> get recipes;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseImplCopyWith<_$CourseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AdditionalDietInfo _$AdditionalDietInfoFromJson(Map<String, dynamic> json) {
  return _AdditionalDietInfo.fromJson(json);
}

/// @nodoc
mixin _$AdditionalDietInfo {
  String get allergens =>
      throw _privateConstructorUsedError; // Make this optional if it’s not always present.
  List<String>? get dietcodeImages => throw _privateConstructorUsedError;

  /// Serializes this AdditionalDietInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdditionalDietInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdditionalDietInfoCopyWith<AdditionalDietInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdditionalDietInfoCopyWith<$Res> {
  factory $AdditionalDietInfoCopyWith(
          AdditionalDietInfo value, $Res Function(AdditionalDietInfo) then) =
      _$AdditionalDietInfoCopyWithImpl<$Res, AdditionalDietInfo>;
  @useResult
  $Res call({String allergens, List<String>? dietcodeImages});
}

/// @nodoc
class _$AdditionalDietInfoCopyWithImpl<$Res, $Val extends AdditionalDietInfo>
    implements $AdditionalDietInfoCopyWith<$Res> {
  _$AdditionalDietInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdditionalDietInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergens = null,
    Object? dietcodeImages = freezed,
  }) {
    return _then(_value.copyWith(
      allergens: null == allergens
          ? _value.allergens
          : allergens // ignore: cast_nullable_to_non_nullable
              as String,
      dietcodeImages: freezed == dietcodeImages
          ? _value.dietcodeImages
          : dietcodeImages // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdditionalDietInfoImplCopyWith<$Res>
    implements $AdditionalDietInfoCopyWith<$Res> {
  factory _$$AdditionalDietInfoImplCopyWith(_$AdditionalDietInfoImpl value,
          $Res Function(_$AdditionalDietInfoImpl) then) =
      __$$AdditionalDietInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String allergens, List<String>? dietcodeImages});
}

/// @nodoc
class __$$AdditionalDietInfoImplCopyWithImpl<$Res>
    extends _$AdditionalDietInfoCopyWithImpl<$Res, _$AdditionalDietInfoImpl>
    implements _$$AdditionalDietInfoImplCopyWith<$Res> {
  __$$AdditionalDietInfoImplCopyWithImpl(_$AdditionalDietInfoImpl _value,
      $Res Function(_$AdditionalDietInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdditionalDietInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergens = null,
    Object? dietcodeImages = freezed,
  }) {
    return _then(_$AdditionalDietInfoImpl(
      allergens: null == allergens
          ? _value.allergens
          : allergens // ignore: cast_nullable_to_non_nullable
              as String,
      dietcodeImages: freezed == dietcodeImages
          ? _value._dietcodeImages
          : dietcodeImages // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdditionalDietInfoImpl implements _AdditionalDietInfo {
  const _$AdditionalDietInfoImpl(
      {required this.allergens, final List<String>? dietcodeImages})
      : _dietcodeImages = dietcodeImages;

  factory _$AdditionalDietInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdditionalDietInfoImplFromJson(json);

  @override
  final String allergens;
// Make this optional if it’s not always present.
  final List<String>? _dietcodeImages;
// Make this optional if it’s not always present.
  @override
  List<String>? get dietcodeImages {
    final value = _dietcodeImages;
    if (value == null) return null;
    if (_dietcodeImages is EqualUnmodifiableListView) return _dietcodeImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AdditionalDietInfo(allergens: $allergens, dietcodeImages: $dietcodeImages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdditionalDietInfoImpl &&
            (identical(other.allergens, allergens) ||
                other.allergens == allergens) &&
            const DeepCollectionEquality()
                .equals(other._dietcodeImages, _dietcodeImages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, allergens,
      const DeepCollectionEquality().hash(_dietcodeImages));

  /// Create a copy of AdditionalDietInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdditionalDietInfoImplCopyWith<_$AdditionalDietInfoImpl> get copyWith =>
      __$$AdditionalDietInfoImplCopyWithImpl<_$AdditionalDietInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdditionalDietInfoImplToJson(
      this,
    );
  }
}

abstract class _AdditionalDietInfo implements AdditionalDietInfo {
  const factory _AdditionalDietInfo(
      {required final String allergens,
      final List<String>? dietcodeImages}) = _$AdditionalDietInfoImpl;

  factory _AdditionalDietInfo.fromJson(Map<String, dynamic> json) =
      _$AdditionalDietInfoImpl.fromJson;

  @override
  String get allergens; // Make this optional if it’s not always present.
  @override
  List<String>? get dietcodeImages;

  /// Create a copy of AdditionalDietInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdditionalDietInfoImplCopyWith<_$AdditionalDietInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Recipe _$RecipeFromJson(Map<String, dynamic> json) {
  return _Recipe.fromJson(json);
}

/// @nodoc
mixin _$Recipe {
  String get name =>
      throw _privateConstructorUsedError; // If ingredients can be either a String or a List, consider writing a custom converter or simply using dynamic.
  dynamic get ingredients => throw _privateConstructorUsedError;
  String get nutrients => throw _privateConstructorUsedError;

  /// Serializes this Recipe to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeCopyWith<Recipe> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeCopyWith<$Res> {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) then) =
      _$RecipeCopyWithImpl<$Res, Recipe>;
  @useResult
  $Res call({String name, dynamic ingredients, String nutrients});
}

/// @nodoc
class _$RecipeCopyWithImpl<$Res, $Val extends Recipe>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? ingredients = freezed,
    Object? nutrients = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ingredients: freezed == ingredients
          ? _value.ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as dynamic,
      nutrients: null == nutrients
          ? _value.nutrients
          : nutrients // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecipeImplCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$$RecipeImplCopyWith(
          _$RecipeImpl value, $Res Function(_$RecipeImpl) then) =
      __$$RecipeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, dynamic ingredients, String nutrients});
}

/// @nodoc
class __$$RecipeImplCopyWithImpl<$Res>
    extends _$RecipeCopyWithImpl<$Res, _$RecipeImpl>
    implements _$$RecipeImplCopyWith<$Res> {
  __$$RecipeImplCopyWithImpl(
      _$RecipeImpl _value, $Res Function(_$RecipeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? ingredients = freezed,
    Object? nutrients = null,
  }) {
    return _then(_$RecipeImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ingredients: freezed == ingredients
          ? _value.ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as dynamic,
      nutrients: null == nutrients
          ? _value.nutrients
          : nutrients // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeImpl implements _Recipe {
  const _$RecipeImpl(
      {required this.name, required this.ingredients, required this.nutrients});

  factory _$RecipeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeImplFromJson(json);

  @override
  final String name;
// If ingredients can be either a String or a List, consider writing a custom converter or simply using dynamic.
  @override
  final dynamic ingredients;
  @override
  final String nutrients;

  @override
  String toString() {
    return 'Recipe(name: $name, ingredients: $ingredients, nutrients: $nutrients)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other.ingredients, ingredients) &&
            (identical(other.nutrients, nutrients) ||
                other.nutrients == nutrients));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name,
      const DeepCollectionEquality().hash(ingredients), nutrients);

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      __$$RecipeImplCopyWithImpl<_$RecipeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeImplToJson(
      this,
    );
  }
}

abstract class _Recipe implements Recipe {
  const factory _Recipe(
      {required final String name,
      required final dynamic ingredients,
      required final String nutrients}) = _$RecipeImpl;

  factory _Recipe.fromJson(Map<String, dynamic> json) = _$RecipeImpl.fromJson;

  @override
  String
      get name; // If ingredients can be either a String or a List, consider writing a custom converter or simply using dynamic.
  @override
  dynamic get ingredients;
  @override
  String get nutrients;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
