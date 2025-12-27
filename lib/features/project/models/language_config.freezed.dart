// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'language_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LanguageConfig {

 String get code; String get name;
/// Create a copy of LanguageConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LanguageConfigCopyWith<LanguageConfig> get copyWith => _$LanguageConfigCopyWithImpl<LanguageConfig>(this as LanguageConfig, _$identity);

  /// Serializes this LanguageConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LanguageConfig&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name);

@override
String toString() {
  return 'LanguageConfig(code: $code, name: $name)';
}


}

/// @nodoc
abstract mixin class $LanguageConfigCopyWith<$Res>  {
  factory $LanguageConfigCopyWith(LanguageConfig value, $Res Function(LanguageConfig) _then) = _$LanguageConfigCopyWithImpl;
@useResult
$Res call({
 String code, String name
});




}
/// @nodoc
class _$LanguageConfigCopyWithImpl<$Res>
    implements $LanguageConfigCopyWith<$Res> {
  _$LanguageConfigCopyWithImpl(this._self, this._then);

  final LanguageConfig _self;
  final $Res Function(LanguageConfig) _then;

/// Create a copy of LanguageConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LanguageConfig].
extension LanguageConfigPatterns on LanguageConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LanguageConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LanguageConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LanguageConfig value)  $default,){
final _that = this;
switch (_that) {
case _LanguageConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LanguageConfig value)?  $default,){
final _that = this;
switch (_that) {
case _LanguageConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LanguageConfig() when $default != null:
return $default(_that.code,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name)  $default,) {final _that = this;
switch (_that) {
case _LanguageConfig():
return $default(_that.code,_that.name);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name)?  $default,) {final _that = this;
switch (_that) {
case _LanguageConfig() when $default != null:
return $default(_that.code,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LanguageConfig extends LanguageConfig {
  const _LanguageConfig({required this.code, required this.name}): super._();
  factory _LanguageConfig.fromJson(Map<String, dynamic> json) => _$LanguageConfigFromJson(json);

@override final  String code;
@override final  String name;

/// Create a copy of LanguageConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LanguageConfigCopyWith<_LanguageConfig> get copyWith => __$LanguageConfigCopyWithImpl<_LanguageConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LanguageConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LanguageConfig&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name);

@override
String toString() {
  return 'LanguageConfig(code: $code, name: $name)';
}


}

/// @nodoc
abstract mixin class _$LanguageConfigCopyWith<$Res> implements $LanguageConfigCopyWith<$Res> {
  factory _$LanguageConfigCopyWith(_LanguageConfig value, $Res Function(_LanguageConfig) _then) = __$LanguageConfigCopyWithImpl;
@override @useResult
$Res call({
 String code, String name
});




}
/// @nodoc
class __$LanguageConfigCopyWithImpl<$Res>
    implements _$LanguageConfigCopyWith<$Res> {
  __$LanguageConfigCopyWithImpl(this._self, this._then);

  final _LanguageConfig _self;
  final $Res Function(_LanguageConfig) _then;

/// Create a copy of LanguageConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,}) {
  return _then(_LanguageConfig(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
