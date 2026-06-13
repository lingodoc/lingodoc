// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserPreferences {

// Application settings
@ThemeModeConverter() ThemeMode get themeMode; int get autoRefreshIntervalSeconds; bool get enableAutoRefresh; bool get rememberWindowState;// Editor preferences (override project config)
 int get editorFontSize; bool get editorLineNumbers; bool get editorWordWrap;// Preview preferences
 bool get retainPdfPage;// Screen library
 String? get screenLibraryPath;
/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<UserPreferences> get copyWith => _$UserPreferencesCopyWithImpl<UserPreferences>(this as UserPreferences, _$identity);

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPreferences&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.autoRefreshIntervalSeconds, autoRefreshIntervalSeconds) || other.autoRefreshIntervalSeconds == autoRefreshIntervalSeconds)&&(identical(other.enableAutoRefresh, enableAutoRefresh) || other.enableAutoRefresh == enableAutoRefresh)&&(identical(other.rememberWindowState, rememberWindowState) || other.rememberWindowState == rememberWindowState)&&(identical(other.editorFontSize, editorFontSize) || other.editorFontSize == editorFontSize)&&(identical(other.editorLineNumbers, editorLineNumbers) || other.editorLineNumbers == editorLineNumbers)&&(identical(other.editorWordWrap, editorWordWrap) || other.editorWordWrap == editorWordWrap)&&(identical(other.retainPdfPage, retainPdfPage) || other.retainPdfPage == retainPdfPage)&&(identical(other.screenLibraryPath, screenLibraryPath) || other.screenLibraryPath == screenLibraryPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,autoRefreshIntervalSeconds,enableAutoRefresh,rememberWindowState,editorFontSize,editorLineNumbers,editorWordWrap,retainPdfPage,screenLibraryPath);

@override
String toString() {
  return 'UserPreferences(themeMode: $themeMode, autoRefreshIntervalSeconds: $autoRefreshIntervalSeconds, enableAutoRefresh: $enableAutoRefresh, rememberWindowState: $rememberWindowState, editorFontSize: $editorFontSize, editorLineNumbers: $editorLineNumbers, editorWordWrap: $editorWordWrap, retainPdfPage: $retainPdfPage, screenLibraryPath: $screenLibraryPath)';
}


}

/// @nodoc
abstract mixin class $UserPreferencesCopyWith<$Res>  {
  factory $UserPreferencesCopyWith(UserPreferences value, $Res Function(UserPreferences) _then) = _$UserPreferencesCopyWithImpl;
@useResult
$Res call({
@ThemeModeConverter() ThemeMode themeMode, int autoRefreshIntervalSeconds, bool enableAutoRefresh, bool rememberWindowState, int editorFontSize, bool editorLineNumbers, bool editorWordWrap, bool retainPdfPage, String? screenLibraryPath
});




}
/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._self, this._then);

  final UserPreferences _self;
  final $Res Function(UserPreferences) _then;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? autoRefreshIntervalSeconds = null,Object? enableAutoRefresh = null,Object? rememberWindowState = null,Object? editorFontSize = null,Object? editorLineNumbers = null,Object? editorWordWrap = null,Object? retainPdfPage = null,Object? screenLibraryPath = freezed,}) {
  return _then(_self.copyWith(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,autoRefreshIntervalSeconds: null == autoRefreshIntervalSeconds ? _self.autoRefreshIntervalSeconds : autoRefreshIntervalSeconds // ignore: cast_nullable_to_non_nullable
as int,enableAutoRefresh: null == enableAutoRefresh ? _self.enableAutoRefresh : enableAutoRefresh // ignore: cast_nullable_to_non_nullable
as bool,rememberWindowState: null == rememberWindowState ? _self.rememberWindowState : rememberWindowState // ignore: cast_nullable_to_non_nullable
as bool,editorFontSize: null == editorFontSize ? _self.editorFontSize : editorFontSize // ignore: cast_nullable_to_non_nullable
as int,editorLineNumbers: null == editorLineNumbers ? _self.editorLineNumbers : editorLineNumbers // ignore: cast_nullable_to_non_nullable
as bool,editorWordWrap: null == editorWordWrap ? _self.editorWordWrap : editorWordWrap // ignore: cast_nullable_to_non_nullable
as bool,retainPdfPage: null == retainPdfPage ? _self.retainPdfPage : retainPdfPage // ignore: cast_nullable_to_non_nullable
as bool,screenLibraryPath: freezed == screenLibraryPath ? _self.screenLibraryPath : screenLibraryPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPreferences].
extension UserPreferencesPatterns on UserPreferences {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPreferences value)  $default,){
final _that = this;
switch (_that) {
case _UserPreferences():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@ThemeModeConverter()  ThemeMode themeMode,  int autoRefreshIntervalSeconds,  bool enableAutoRefresh,  bool rememberWindowState,  int editorFontSize,  bool editorLineNumbers,  bool editorWordWrap,  bool retainPdfPage,  String? screenLibraryPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that.themeMode,_that.autoRefreshIntervalSeconds,_that.enableAutoRefresh,_that.rememberWindowState,_that.editorFontSize,_that.editorLineNumbers,_that.editorWordWrap,_that.retainPdfPage,_that.screenLibraryPath);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@ThemeModeConverter()  ThemeMode themeMode,  int autoRefreshIntervalSeconds,  bool enableAutoRefresh,  bool rememberWindowState,  int editorFontSize,  bool editorLineNumbers,  bool editorWordWrap,  bool retainPdfPage,  String? screenLibraryPath)  $default,) {final _that = this;
switch (_that) {
case _UserPreferences():
return $default(_that.themeMode,_that.autoRefreshIntervalSeconds,_that.enableAutoRefresh,_that.rememberWindowState,_that.editorFontSize,_that.editorLineNumbers,_that.editorWordWrap,_that.retainPdfPage,_that.screenLibraryPath);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@ThemeModeConverter()  ThemeMode themeMode,  int autoRefreshIntervalSeconds,  bool enableAutoRefresh,  bool rememberWindowState,  int editorFontSize,  bool editorLineNumbers,  bool editorWordWrap,  bool retainPdfPage,  String? screenLibraryPath)?  $default,) {final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that.themeMode,_that.autoRefreshIntervalSeconds,_that.enableAutoRefresh,_that.rememberWindowState,_that.editorFontSize,_that.editorLineNumbers,_that.editorWordWrap,_that.retainPdfPage,_that.screenLibraryPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserPreferences extends UserPreferences {
  const _UserPreferences({@ThemeModeConverter() this.themeMode = ThemeMode.dark, this.autoRefreshIntervalSeconds = 10, this.enableAutoRefresh = true, this.rememberWindowState = true, this.editorFontSize = 14, this.editorLineNumbers = true, this.editorWordWrap = true, this.retainPdfPage = true, this.screenLibraryPath = null}): super._();
  factory _UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);

// Application settings
@override@JsonKey()@ThemeModeConverter() final  ThemeMode themeMode;
@override@JsonKey() final  int autoRefreshIntervalSeconds;
@override@JsonKey() final  bool enableAutoRefresh;
@override@JsonKey() final  bool rememberWindowState;
// Editor preferences (override project config)
@override@JsonKey() final  int editorFontSize;
@override@JsonKey() final  bool editorLineNumbers;
@override@JsonKey() final  bool editorWordWrap;
// Preview preferences
@override@JsonKey() final  bool retainPdfPage;
// Screen library
@override@JsonKey() final  String? screenLibraryPath;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPreferencesCopyWith<_UserPreferences> get copyWith => __$UserPreferencesCopyWithImpl<_UserPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPreferences&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.autoRefreshIntervalSeconds, autoRefreshIntervalSeconds) || other.autoRefreshIntervalSeconds == autoRefreshIntervalSeconds)&&(identical(other.enableAutoRefresh, enableAutoRefresh) || other.enableAutoRefresh == enableAutoRefresh)&&(identical(other.rememberWindowState, rememberWindowState) || other.rememberWindowState == rememberWindowState)&&(identical(other.editorFontSize, editorFontSize) || other.editorFontSize == editorFontSize)&&(identical(other.editorLineNumbers, editorLineNumbers) || other.editorLineNumbers == editorLineNumbers)&&(identical(other.editorWordWrap, editorWordWrap) || other.editorWordWrap == editorWordWrap)&&(identical(other.retainPdfPage, retainPdfPage) || other.retainPdfPage == retainPdfPage)&&(identical(other.screenLibraryPath, screenLibraryPath) || other.screenLibraryPath == screenLibraryPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,autoRefreshIntervalSeconds,enableAutoRefresh,rememberWindowState,editorFontSize,editorLineNumbers,editorWordWrap,retainPdfPage,screenLibraryPath);

@override
String toString() {
  return 'UserPreferences(themeMode: $themeMode, autoRefreshIntervalSeconds: $autoRefreshIntervalSeconds, enableAutoRefresh: $enableAutoRefresh, rememberWindowState: $rememberWindowState, editorFontSize: $editorFontSize, editorLineNumbers: $editorLineNumbers, editorWordWrap: $editorWordWrap, retainPdfPage: $retainPdfPage, screenLibraryPath: $screenLibraryPath)';
}


}

/// @nodoc
abstract mixin class _$UserPreferencesCopyWith<$Res> implements $UserPreferencesCopyWith<$Res> {
  factory _$UserPreferencesCopyWith(_UserPreferences value, $Res Function(_UserPreferences) _then) = __$UserPreferencesCopyWithImpl;
@override @useResult
$Res call({
@ThemeModeConverter() ThemeMode themeMode, int autoRefreshIntervalSeconds, bool enableAutoRefresh, bool rememberWindowState, int editorFontSize, bool editorLineNumbers, bool editorWordWrap, bool retainPdfPage, String? screenLibraryPath
});




}
/// @nodoc
class __$UserPreferencesCopyWithImpl<$Res>
    implements _$UserPreferencesCopyWith<$Res> {
  __$UserPreferencesCopyWithImpl(this._self, this._then);

  final _UserPreferences _self;
  final $Res Function(_UserPreferences) _then;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? autoRefreshIntervalSeconds = null,Object? enableAutoRefresh = null,Object? rememberWindowState = null,Object? editorFontSize = null,Object? editorLineNumbers = null,Object? editorWordWrap = null,Object? retainPdfPage = null,Object? screenLibraryPath = freezed,}) {
  return _then(_UserPreferences(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,autoRefreshIntervalSeconds: null == autoRefreshIntervalSeconds ? _self.autoRefreshIntervalSeconds : autoRefreshIntervalSeconds // ignore: cast_nullable_to_non_nullable
as int,enableAutoRefresh: null == enableAutoRefresh ? _self.enableAutoRefresh : enableAutoRefresh // ignore: cast_nullable_to_non_nullable
as bool,rememberWindowState: null == rememberWindowState ? _self.rememberWindowState : rememberWindowState // ignore: cast_nullable_to_non_nullable
as bool,editorFontSize: null == editorFontSize ? _self.editorFontSize : editorFontSize // ignore: cast_nullable_to_non_nullable
as int,editorLineNumbers: null == editorLineNumbers ? _self.editorLineNumbers : editorLineNumbers // ignore: cast_nullable_to_non_nullable
as bool,editorWordWrap: null == editorWordWrap ? _self.editorWordWrap : editorWordWrap // ignore: cast_nullable_to_non_nullable
as bool,retainPdfPage: null == retainPdfPage ? _self.retainPdfPage : retainPdfPage // ignore: cast_nullable_to_non_nullable
as bool,screenLibraryPath: freezed == screenLibraryPath ? _self.screenLibraryPath : screenLibraryPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
