// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detachable_window_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DetachableWindowState {

/// Whether the preview is currently detached
 bool get isDetached;/// The selected language for the detached preview
 String? get selectedLanguage;/// Current PDF path being displayed
 String? get pdfPath;/// Whether compilation is in progress
 bool get isCompiling;/// Whether grid mode is enabled
 bool get isGridMode;
/// Create a copy of DetachableWindowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetachableWindowStateCopyWith<DetachableWindowState> get copyWith => _$DetachableWindowStateCopyWithImpl<DetachableWindowState>(this as DetachableWindowState, _$identity);

  /// Serializes this DetachableWindowState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetachableWindowState&&(identical(other.isDetached, isDetached) || other.isDetached == isDetached)&&(identical(other.selectedLanguage, selectedLanguage) || other.selectedLanguage == selectedLanguage)&&(identical(other.pdfPath, pdfPath) || other.pdfPath == pdfPath)&&(identical(other.isCompiling, isCompiling) || other.isCompiling == isCompiling)&&(identical(other.isGridMode, isGridMode) || other.isGridMode == isGridMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isDetached,selectedLanguage,pdfPath,isCompiling,isGridMode);

@override
String toString() {
  return 'DetachableWindowState(isDetached: $isDetached, selectedLanguage: $selectedLanguage, pdfPath: $pdfPath, isCompiling: $isCompiling, isGridMode: $isGridMode)';
}


}

/// @nodoc
abstract mixin class $DetachableWindowStateCopyWith<$Res>  {
  factory $DetachableWindowStateCopyWith(DetachableWindowState value, $Res Function(DetachableWindowState) _then) = _$DetachableWindowStateCopyWithImpl;
@useResult
$Res call({
 bool isDetached, String? selectedLanguage, String? pdfPath, bool isCompiling, bool isGridMode
});




}
/// @nodoc
class _$DetachableWindowStateCopyWithImpl<$Res>
    implements $DetachableWindowStateCopyWith<$Res> {
  _$DetachableWindowStateCopyWithImpl(this._self, this._then);

  final DetachableWindowState _self;
  final $Res Function(DetachableWindowState) _then;

/// Create a copy of DetachableWindowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isDetached = null,Object? selectedLanguage = freezed,Object? pdfPath = freezed,Object? isCompiling = null,Object? isGridMode = null,}) {
  return _then(_self.copyWith(
isDetached: null == isDetached ? _self.isDetached : isDetached // ignore: cast_nullable_to_non_nullable
as bool,selectedLanguage: freezed == selectedLanguage ? _self.selectedLanguage : selectedLanguage // ignore: cast_nullable_to_non_nullable
as String?,pdfPath: freezed == pdfPath ? _self.pdfPath : pdfPath // ignore: cast_nullable_to_non_nullable
as String?,isCompiling: null == isCompiling ? _self.isCompiling : isCompiling // ignore: cast_nullable_to_non_nullable
as bool,isGridMode: null == isGridMode ? _self.isGridMode : isGridMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DetachableWindowState].
extension DetachableWindowStatePatterns on DetachableWindowState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetachableWindowState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetachableWindowState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetachableWindowState value)  $default,){
final _that = this;
switch (_that) {
case _DetachableWindowState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetachableWindowState value)?  $default,){
final _that = this;
switch (_that) {
case _DetachableWindowState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isDetached,  String? selectedLanguage,  String? pdfPath,  bool isCompiling,  bool isGridMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetachableWindowState() when $default != null:
return $default(_that.isDetached,_that.selectedLanguage,_that.pdfPath,_that.isCompiling,_that.isGridMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isDetached,  String? selectedLanguage,  String? pdfPath,  bool isCompiling,  bool isGridMode)  $default,) {final _that = this;
switch (_that) {
case _DetachableWindowState():
return $default(_that.isDetached,_that.selectedLanguage,_that.pdfPath,_that.isCompiling,_that.isGridMode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isDetached,  String? selectedLanguage,  String? pdfPath,  bool isCompiling,  bool isGridMode)?  $default,) {final _that = this;
switch (_that) {
case _DetachableWindowState() when $default != null:
return $default(_that.isDetached,_that.selectedLanguage,_that.pdfPath,_that.isCompiling,_that.isGridMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DetachableWindowState extends DetachableWindowState {
  const _DetachableWindowState({this.isDetached = false, this.selectedLanguage, this.pdfPath, this.isCompiling = false, this.isGridMode = false}): super._();
  factory _DetachableWindowState.fromJson(Map<String, dynamic> json) => _$DetachableWindowStateFromJson(json);

/// Whether the preview is currently detached
@override@JsonKey() final  bool isDetached;
/// The selected language for the detached preview
@override final  String? selectedLanguage;
/// Current PDF path being displayed
@override final  String? pdfPath;
/// Whether compilation is in progress
@override@JsonKey() final  bool isCompiling;
/// Whether grid mode is enabled
@override@JsonKey() final  bool isGridMode;

/// Create a copy of DetachableWindowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetachableWindowStateCopyWith<_DetachableWindowState> get copyWith => __$DetachableWindowStateCopyWithImpl<_DetachableWindowState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DetachableWindowStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetachableWindowState&&(identical(other.isDetached, isDetached) || other.isDetached == isDetached)&&(identical(other.selectedLanguage, selectedLanguage) || other.selectedLanguage == selectedLanguage)&&(identical(other.pdfPath, pdfPath) || other.pdfPath == pdfPath)&&(identical(other.isCompiling, isCompiling) || other.isCompiling == isCompiling)&&(identical(other.isGridMode, isGridMode) || other.isGridMode == isGridMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isDetached,selectedLanguage,pdfPath,isCompiling,isGridMode);

@override
String toString() {
  return 'DetachableWindowState(isDetached: $isDetached, selectedLanguage: $selectedLanguage, pdfPath: $pdfPath, isCompiling: $isCompiling, isGridMode: $isGridMode)';
}


}

/// @nodoc
abstract mixin class _$DetachableWindowStateCopyWith<$Res> implements $DetachableWindowStateCopyWith<$Res> {
  factory _$DetachableWindowStateCopyWith(_DetachableWindowState value, $Res Function(_DetachableWindowState) _then) = __$DetachableWindowStateCopyWithImpl;
@override @useResult
$Res call({
 bool isDetached, String? selectedLanguage, String? pdfPath, bool isCompiling, bool isGridMode
});




}
/// @nodoc
class __$DetachableWindowStateCopyWithImpl<$Res>
    implements _$DetachableWindowStateCopyWith<$Res> {
  __$DetachableWindowStateCopyWithImpl(this._self, this._then);

  final _DetachableWindowState _self;
  final $Res Function(_DetachableWindowState) _then;

/// Create a copy of DetachableWindowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isDetached = null,Object? selectedLanguage = freezed,Object? pdfPath = freezed,Object? isCompiling = null,Object? isGridMode = null,}) {
  return _then(_DetachableWindowState(
isDetached: null == isDetached ? _self.isDetached : isDetached // ignore: cast_nullable_to_non_nullable
as bool,selectedLanguage: freezed == selectedLanguage ? _self.selectedLanguage : selectedLanguage // ignore: cast_nullable_to_non_nullable
as String?,pdfPath: freezed == pdfPath ? _self.pdfPath : pdfPath // ignore: cast_nullable_to_non_nullable
as String?,isCompiling: null == isCompiling ? _self.isCompiling : isCompiling // ignore: cast_nullable_to_non_nullable
as bool,isGridMode: null == isGridMode ? _self.isGridMode : isGridMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
