// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectSettings {

 LanguageConfig get defaultLanguage; String get outputDirectory; bool get autoCompile; int get compileDebounceMs;
/// Create a copy of ProjectSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectSettingsCopyWith<ProjectSettings> get copyWith => _$ProjectSettingsCopyWithImpl<ProjectSettings>(this as ProjectSettings, _$identity);

  /// Serializes this ProjectSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectSettings&&(identical(other.defaultLanguage, defaultLanguage) || other.defaultLanguage == defaultLanguage)&&(identical(other.outputDirectory, outputDirectory) || other.outputDirectory == outputDirectory)&&(identical(other.autoCompile, autoCompile) || other.autoCompile == autoCompile)&&(identical(other.compileDebounceMs, compileDebounceMs) || other.compileDebounceMs == compileDebounceMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultLanguage,outputDirectory,autoCompile,compileDebounceMs);

@override
String toString() {
  return 'ProjectSettings(defaultLanguage: $defaultLanguage, outputDirectory: $outputDirectory, autoCompile: $autoCompile, compileDebounceMs: $compileDebounceMs)';
}


}

/// @nodoc
abstract mixin class $ProjectSettingsCopyWith<$Res>  {
  factory $ProjectSettingsCopyWith(ProjectSettings value, $Res Function(ProjectSettings) _then) = _$ProjectSettingsCopyWithImpl;
@useResult
$Res call({
 LanguageConfig defaultLanguage, String outputDirectory, bool autoCompile, int compileDebounceMs
});


$LanguageConfigCopyWith<$Res> get defaultLanguage;

}
/// @nodoc
class _$ProjectSettingsCopyWithImpl<$Res>
    implements $ProjectSettingsCopyWith<$Res> {
  _$ProjectSettingsCopyWithImpl(this._self, this._then);

  final ProjectSettings _self;
  final $Res Function(ProjectSettings) _then;

/// Create a copy of ProjectSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultLanguage = null,Object? outputDirectory = null,Object? autoCompile = null,Object? compileDebounceMs = null,}) {
  return _then(_self.copyWith(
defaultLanguage: null == defaultLanguage ? _self.defaultLanguage : defaultLanguage // ignore: cast_nullable_to_non_nullable
as LanguageConfig,outputDirectory: null == outputDirectory ? _self.outputDirectory : outputDirectory // ignore: cast_nullable_to_non_nullable
as String,autoCompile: null == autoCompile ? _self.autoCompile : autoCompile // ignore: cast_nullable_to_non_nullable
as bool,compileDebounceMs: null == compileDebounceMs ? _self.compileDebounceMs : compileDebounceMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ProjectSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LanguageConfigCopyWith<$Res> get defaultLanguage {
  
  return $LanguageConfigCopyWith<$Res>(_self.defaultLanguage, (value) {
    return _then(_self.copyWith(defaultLanguage: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProjectSettings].
extension ProjectSettingsPatterns on ProjectSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectSettings value)  $default,){
final _that = this;
switch (_that) {
case _ProjectSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LanguageConfig defaultLanguage,  String outputDirectory,  bool autoCompile,  int compileDebounceMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectSettings() when $default != null:
return $default(_that.defaultLanguage,_that.outputDirectory,_that.autoCompile,_that.compileDebounceMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LanguageConfig defaultLanguage,  String outputDirectory,  bool autoCompile,  int compileDebounceMs)  $default,) {final _that = this;
switch (_that) {
case _ProjectSettings():
return $default(_that.defaultLanguage,_that.outputDirectory,_that.autoCompile,_that.compileDebounceMs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LanguageConfig defaultLanguage,  String outputDirectory,  bool autoCompile,  int compileDebounceMs)?  $default,) {final _that = this;
switch (_that) {
case _ProjectSettings() when $default != null:
return $default(_that.defaultLanguage,_that.outputDirectory,_that.autoCompile,_that.compileDebounceMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectSettings extends ProjectSettings {
  const _ProjectSettings({required this.defaultLanguage, this.outputDirectory = 'output', this.autoCompile = true, this.compileDebounceMs = 500}): super._();
  factory _ProjectSettings.fromJson(Map<String, dynamic> json) => _$ProjectSettingsFromJson(json);

@override final  LanguageConfig defaultLanguage;
@override@JsonKey() final  String outputDirectory;
@override@JsonKey() final  bool autoCompile;
@override@JsonKey() final  int compileDebounceMs;

/// Create a copy of ProjectSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectSettingsCopyWith<_ProjectSettings> get copyWith => __$ProjectSettingsCopyWithImpl<_ProjectSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectSettings&&(identical(other.defaultLanguage, defaultLanguage) || other.defaultLanguage == defaultLanguage)&&(identical(other.outputDirectory, outputDirectory) || other.outputDirectory == outputDirectory)&&(identical(other.autoCompile, autoCompile) || other.autoCompile == autoCompile)&&(identical(other.compileDebounceMs, compileDebounceMs) || other.compileDebounceMs == compileDebounceMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultLanguage,outputDirectory,autoCompile,compileDebounceMs);

@override
String toString() {
  return 'ProjectSettings(defaultLanguage: $defaultLanguage, outputDirectory: $outputDirectory, autoCompile: $autoCompile, compileDebounceMs: $compileDebounceMs)';
}


}

/// @nodoc
abstract mixin class _$ProjectSettingsCopyWith<$Res> implements $ProjectSettingsCopyWith<$Res> {
  factory _$ProjectSettingsCopyWith(_ProjectSettings value, $Res Function(_ProjectSettings) _then) = __$ProjectSettingsCopyWithImpl;
@override @useResult
$Res call({
 LanguageConfig defaultLanguage, String outputDirectory, bool autoCompile, int compileDebounceMs
});


@override $LanguageConfigCopyWith<$Res> get defaultLanguage;

}
/// @nodoc
class __$ProjectSettingsCopyWithImpl<$Res>
    implements _$ProjectSettingsCopyWith<$Res> {
  __$ProjectSettingsCopyWithImpl(this._self, this._then);

  final _ProjectSettings _self;
  final $Res Function(_ProjectSettings) _then;

/// Create a copy of ProjectSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultLanguage = null,Object? outputDirectory = null,Object? autoCompile = null,Object? compileDebounceMs = null,}) {
  return _then(_ProjectSettings(
defaultLanguage: null == defaultLanguage ? _self.defaultLanguage : defaultLanguage // ignore: cast_nullable_to_non_nullable
as LanguageConfig,outputDirectory: null == outputDirectory ? _self.outputDirectory : outputDirectory // ignore: cast_nullable_to_non_nullable
as String,autoCompile: null == autoCompile ? _self.autoCompile : autoCompile // ignore: cast_nullable_to_non_nullable
as bool,compileDebounceMs: null == compileDebounceMs ? _self.compileDebounceMs : compileDebounceMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ProjectSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LanguageConfigCopyWith<$Res> get defaultLanguage {
  
  return $LanguageConfigCopyWith<$Res>(_self.defaultLanguage, (value) {
    return _then(_self.copyWith(defaultLanguage: value));
  });
}
}

// dart format on
