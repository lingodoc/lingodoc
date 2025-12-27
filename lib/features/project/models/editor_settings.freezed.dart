// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EditorSettings {

 String get theme; int get fontSize; bool get lineNumbers; bool get wordWrap; int get autoSaveInterval;
/// Create a copy of EditorSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorSettingsCopyWith<EditorSettings> get copyWith => _$EditorSettingsCopyWithImpl<EditorSettings>(this as EditorSettings, _$identity);

  /// Serializes this EditorSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorSettings&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.lineNumbers, lineNumbers) || other.lineNumbers == lineNumbers)&&(identical(other.wordWrap, wordWrap) || other.wordWrap == wordWrap)&&(identical(other.autoSaveInterval, autoSaveInterval) || other.autoSaveInterval == autoSaveInterval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,theme,fontSize,lineNumbers,wordWrap,autoSaveInterval);

@override
String toString() {
  return 'EditorSettings(theme: $theme, fontSize: $fontSize, lineNumbers: $lineNumbers, wordWrap: $wordWrap, autoSaveInterval: $autoSaveInterval)';
}


}

/// @nodoc
abstract mixin class $EditorSettingsCopyWith<$Res>  {
  factory $EditorSettingsCopyWith(EditorSettings value, $Res Function(EditorSettings) _then) = _$EditorSettingsCopyWithImpl;
@useResult
$Res call({
 String theme, int fontSize, bool lineNumbers, bool wordWrap, int autoSaveInterval
});




}
/// @nodoc
class _$EditorSettingsCopyWithImpl<$Res>
    implements $EditorSettingsCopyWith<$Res> {
  _$EditorSettingsCopyWithImpl(this._self, this._then);

  final EditorSettings _self;
  final $Res Function(EditorSettings) _then;

/// Create a copy of EditorSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? theme = null,Object? fontSize = null,Object? lineNumbers = null,Object? wordWrap = null,Object? autoSaveInterval = null,}) {
  return _then(_self.copyWith(
theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as int,lineNumbers: null == lineNumbers ? _self.lineNumbers : lineNumbers // ignore: cast_nullable_to_non_nullable
as bool,wordWrap: null == wordWrap ? _self.wordWrap : wordWrap // ignore: cast_nullable_to_non_nullable
as bool,autoSaveInterval: null == autoSaveInterval ? _self.autoSaveInterval : autoSaveInterval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EditorSettings].
extension EditorSettingsPatterns on EditorSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorSettings value)  $default,){
final _that = this;
switch (_that) {
case _EditorSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorSettings value)?  $default,){
final _that = this;
switch (_that) {
case _EditorSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String theme,  int fontSize,  bool lineNumbers,  bool wordWrap,  int autoSaveInterval)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorSettings() when $default != null:
return $default(_that.theme,_that.fontSize,_that.lineNumbers,_that.wordWrap,_that.autoSaveInterval);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String theme,  int fontSize,  bool lineNumbers,  bool wordWrap,  int autoSaveInterval)  $default,) {final _that = this;
switch (_that) {
case _EditorSettings():
return $default(_that.theme,_that.fontSize,_that.lineNumbers,_that.wordWrap,_that.autoSaveInterval);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String theme,  int fontSize,  bool lineNumbers,  bool wordWrap,  int autoSaveInterval)?  $default,) {final _that = this;
switch (_that) {
case _EditorSettings() when $default != null:
return $default(_that.theme,_that.fontSize,_that.lineNumbers,_that.wordWrap,_that.autoSaveInterval);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EditorSettings extends EditorSettings {
  const _EditorSettings({this.theme = 'vs-dark', this.fontSize = 14, this.lineNumbers = true, this.wordWrap = true, this.autoSaveInterval = 1}): super._();
  factory _EditorSettings.fromJson(Map<String, dynamic> json) => _$EditorSettingsFromJson(json);

@override@JsonKey() final  String theme;
@override@JsonKey() final  int fontSize;
@override@JsonKey() final  bool lineNumbers;
@override@JsonKey() final  bool wordWrap;
@override@JsonKey() final  int autoSaveInterval;

/// Create a copy of EditorSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorSettingsCopyWith<_EditorSettings> get copyWith => __$EditorSettingsCopyWithImpl<_EditorSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EditorSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorSettings&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.lineNumbers, lineNumbers) || other.lineNumbers == lineNumbers)&&(identical(other.wordWrap, wordWrap) || other.wordWrap == wordWrap)&&(identical(other.autoSaveInterval, autoSaveInterval) || other.autoSaveInterval == autoSaveInterval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,theme,fontSize,lineNumbers,wordWrap,autoSaveInterval);

@override
String toString() {
  return 'EditorSettings(theme: $theme, fontSize: $fontSize, lineNumbers: $lineNumbers, wordWrap: $wordWrap, autoSaveInterval: $autoSaveInterval)';
}


}

/// @nodoc
abstract mixin class _$EditorSettingsCopyWith<$Res> implements $EditorSettingsCopyWith<$Res> {
  factory _$EditorSettingsCopyWith(_EditorSettings value, $Res Function(_EditorSettings) _then) = __$EditorSettingsCopyWithImpl;
@override @useResult
$Res call({
 String theme, int fontSize, bool lineNumbers, bool wordWrap, int autoSaveInterval
});




}
/// @nodoc
class __$EditorSettingsCopyWithImpl<$Res>
    implements _$EditorSettingsCopyWith<$Res> {
  __$EditorSettingsCopyWithImpl(this._self, this._then);

  final _EditorSettings _self;
  final $Res Function(_EditorSettings) _then;

/// Create a copy of EditorSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? theme = null,Object? fontSize = null,Object? lineNumbers = null,Object? wordWrap = null,Object? autoSaveInterval = null,}) {
  return _then(_EditorSettings(
theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as int,lineNumbers: null == lineNumbers ? _self.lineNumbers : lineNumbers // ignore: cast_nullable_to_non_nullable
as bool,wordWrap: null == wordWrap ? _self.wordWrap : wordWrap // ignore: cast_nullable_to_non_nullable
as bool,autoSaveInterval: null == autoSaveInterval ? _self.autoSaveInterval : autoSaveInterval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
