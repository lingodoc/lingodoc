// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preview_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PreviewState {

/// Currently displayed PDF file path
 String? get pdfPath;/// Whether preview is currently loading
 bool get isLoading;/// Error message if preview failed
 String? get error;/// Current page number (1-indexed)
 int get currentPage;/// Total number of pages
 int get totalPages;/// Current zoom level (1.0 = 100%)
 double get zoom;
/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreviewStateCopyWith<PreviewState> get copyWith => _$PreviewStateCopyWithImpl<PreviewState>(this as PreviewState, _$identity);

  /// Serializes this PreviewState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreviewState&&(identical(other.pdfPath, pdfPath) || other.pdfPath == pdfPath)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.zoom, zoom) || other.zoom == zoom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pdfPath,isLoading,error,currentPage,totalPages,zoom);

@override
String toString() {
  return 'PreviewState(pdfPath: $pdfPath, isLoading: $isLoading, error: $error, currentPage: $currentPage, totalPages: $totalPages, zoom: $zoom)';
}


}

/// @nodoc
abstract mixin class $PreviewStateCopyWith<$Res>  {
  factory $PreviewStateCopyWith(PreviewState value, $Res Function(PreviewState) _then) = _$PreviewStateCopyWithImpl;
@useResult
$Res call({
 String? pdfPath, bool isLoading, String? error, int currentPage, int totalPages, double zoom
});




}
/// @nodoc
class _$PreviewStateCopyWithImpl<$Res>
    implements $PreviewStateCopyWith<$Res> {
  _$PreviewStateCopyWithImpl(this._self, this._then);

  final PreviewState _self;
  final $Res Function(PreviewState) _then;

/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pdfPath = freezed,Object? isLoading = null,Object? error = freezed,Object? currentPage = null,Object? totalPages = null,Object? zoom = null,}) {
  return _then(_self.copyWith(
pdfPath: freezed == pdfPath ? _self.pdfPath : pdfPath // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,zoom: null == zoom ? _self.zoom : zoom // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PreviewState].
extension PreviewStatePatterns on PreviewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PreviewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PreviewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PreviewState value)  $default,){
final _that = this;
switch (_that) {
case _PreviewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PreviewState value)?  $default,){
final _that = this;
switch (_that) {
case _PreviewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? pdfPath,  bool isLoading,  String? error,  int currentPage,  int totalPages,  double zoom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PreviewState() when $default != null:
return $default(_that.pdfPath,_that.isLoading,_that.error,_that.currentPage,_that.totalPages,_that.zoom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? pdfPath,  bool isLoading,  String? error,  int currentPage,  int totalPages,  double zoom)  $default,) {final _that = this;
switch (_that) {
case _PreviewState():
return $default(_that.pdfPath,_that.isLoading,_that.error,_that.currentPage,_that.totalPages,_that.zoom);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? pdfPath,  bool isLoading,  String? error,  int currentPage,  int totalPages,  double zoom)?  $default,) {final _that = this;
switch (_that) {
case _PreviewState() when $default != null:
return $default(_that.pdfPath,_that.isLoading,_that.error,_that.currentPage,_that.totalPages,_that.zoom);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PreviewState extends PreviewState {
  const _PreviewState({this.pdfPath, this.isLoading = false, this.error, this.currentPage = 1, this.totalPages = 0, this.zoom = 1.0}): super._();
  factory _PreviewState.fromJson(Map<String, dynamic> json) => _$PreviewStateFromJson(json);

/// Currently displayed PDF file path
@override final  String? pdfPath;
/// Whether preview is currently loading
@override@JsonKey() final  bool isLoading;
/// Error message if preview failed
@override final  String? error;
/// Current page number (1-indexed)
@override@JsonKey() final  int currentPage;
/// Total number of pages
@override@JsonKey() final  int totalPages;
/// Current zoom level (1.0 = 100%)
@override@JsonKey() final  double zoom;

/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreviewStateCopyWith<_PreviewState> get copyWith => __$PreviewStateCopyWithImpl<_PreviewState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PreviewStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreviewState&&(identical(other.pdfPath, pdfPath) || other.pdfPath == pdfPath)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.zoom, zoom) || other.zoom == zoom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pdfPath,isLoading,error,currentPage,totalPages,zoom);

@override
String toString() {
  return 'PreviewState(pdfPath: $pdfPath, isLoading: $isLoading, error: $error, currentPage: $currentPage, totalPages: $totalPages, zoom: $zoom)';
}


}

/// @nodoc
abstract mixin class _$PreviewStateCopyWith<$Res> implements $PreviewStateCopyWith<$Res> {
  factory _$PreviewStateCopyWith(_PreviewState value, $Res Function(_PreviewState) _then) = __$PreviewStateCopyWithImpl;
@override @useResult
$Res call({
 String? pdfPath, bool isLoading, String? error, int currentPage, int totalPages, double zoom
});




}
/// @nodoc
class __$PreviewStateCopyWithImpl<$Res>
    implements _$PreviewStateCopyWith<$Res> {
  __$PreviewStateCopyWithImpl(this._self, this._then);

  final _PreviewState _self;
  final $Res Function(_PreviewState) _then;

/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pdfPath = freezed,Object? isLoading = null,Object? error = freezed,Object? currentPage = null,Object? totalPages = null,Object? zoom = null,}) {
  return _then(_PreviewState(
pdfPath: freezed == pdfPath ? _self.pdfPath : pdfPath // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,zoom: null == zoom ? _self.zoom : zoom // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
