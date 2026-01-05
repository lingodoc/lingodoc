// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchState implements DiagnosticableTreeMixin {

 bool get isVisible; String get searchQuery; int get currentMatchIndex; int get totalMatches; bool get caseSensitive; bool get wholeWord; bool get useRegex;
/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchStateCopyWith<SearchState> get copyWith => _$SearchStateCopyWithImpl<SearchState>(this as SearchState, _$identity);

  /// Serializes this SearchState to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchState'))
    ..add(DiagnosticsProperty('isVisible', isVisible))..add(DiagnosticsProperty('searchQuery', searchQuery))..add(DiagnosticsProperty('currentMatchIndex', currentMatchIndex))..add(DiagnosticsProperty('totalMatches', totalMatches))..add(DiagnosticsProperty('caseSensitive', caseSensitive))..add(DiagnosticsProperty('wholeWord', wholeWord))..add(DiagnosticsProperty('useRegex', useRegex));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchState&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.currentMatchIndex, currentMatchIndex) || other.currentMatchIndex == currentMatchIndex)&&(identical(other.totalMatches, totalMatches) || other.totalMatches == totalMatches)&&(identical(other.caseSensitive, caseSensitive) || other.caseSensitive == caseSensitive)&&(identical(other.wholeWord, wholeWord) || other.wholeWord == wholeWord)&&(identical(other.useRegex, useRegex) || other.useRegex == useRegex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isVisible,searchQuery,currentMatchIndex,totalMatches,caseSensitive,wholeWord,useRegex);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchState(isVisible: $isVisible, searchQuery: $searchQuery, currentMatchIndex: $currentMatchIndex, totalMatches: $totalMatches, caseSensitive: $caseSensitive, wholeWord: $wholeWord, useRegex: $useRegex)';
}


}

/// @nodoc
abstract mixin class $SearchStateCopyWith<$Res>  {
  factory $SearchStateCopyWith(SearchState value, $Res Function(SearchState) _then) = _$SearchStateCopyWithImpl;
@useResult
$Res call({
 bool isVisible, String searchQuery, int currentMatchIndex, int totalMatches, bool caseSensitive, bool wholeWord, bool useRegex
});




}
/// @nodoc
class _$SearchStateCopyWithImpl<$Res>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._self, this._then);

  final SearchState _self;
  final $Res Function(SearchState) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isVisible = null,Object? searchQuery = null,Object? currentMatchIndex = null,Object? totalMatches = null,Object? caseSensitive = null,Object? wholeWord = null,Object? useRegex = null,}) {
  return _then(_self.copyWith(
isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,currentMatchIndex: null == currentMatchIndex ? _self.currentMatchIndex : currentMatchIndex // ignore: cast_nullable_to_non_nullable
as int,totalMatches: null == totalMatches ? _self.totalMatches : totalMatches // ignore: cast_nullable_to_non_nullable
as int,caseSensitive: null == caseSensitive ? _self.caseSensitive : caseSensitive // ignore: cast_nullable_to_non_nullable
as bool,wholeWord: null == wholeWord ? _self.wholeWord : wholeWord // ignore: cast_nullable_to_non_nullable
as bool,useRegex: null == useRegex ? _self.useRegex : useRegex // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchState].
extension SearchStatePatterns on SearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchState value)  $default,){
final _that = this;
switch (_that) {
case _SearchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchState value)?  $default,){
final _that = this;
switch (_that) {
case _SearchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isVisible,  String searchQuery,  int currentMatchIndex,  int totalMatches,  bool caseSensitive,  bool wholeWord,  bool useRegex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that.isVisible,_that.searchQuery,_that.currentMatchIndex,_that.totalMatches,_that.caseSensitive,_that.wholeWord,_that.useRegex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isVisible,  String searchQuery,  int currentMatchIndex,  int totalMatches,  bool caseSensitive,  bool wholeWord,  bool useRegex)  $default,) {final _that = this;
switch (_that) {
case _SearchState():
return $default(_that.isVisible,_that.searchQuery,_that.currentMatchIndex,_that.totalMatches,_that.caseSensitive,_that.wholeWord,_that.useRegex);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isVisible,  String searchQuery,  int currentMatchIndex,  int totalMatches,  bool caseSensitive,  bool wholeWord,  bool useRegex)?  $default,) {final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that.isVisible,_that.searchQuery,_that.currentMatchIndex,_that.totalMatches,_that.caseSensitive,_that.wholeWord,_that.useRegex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchState extends SearchState with DiagnosticableTreeMixin {
  const _SearchState({this.isVisible = false, this.searchQuery = '', this.currentMatchIndex = 0, this.totalMatches = 0, this.caseSensitive = false, this.wholeWord = false, this.useRegex = false}): super._();
  factory _SearchState.fromJson(Map<String, dynamic> json) => _$SearchStateFromJson(json);

@override@JsonKey() final  bool isVisible;
@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  int currentMatchIndex;
@override@JsonKey() final  int totalMatches;
@override@JsonKey() final  bool caseSensitive;
@override@JsonKey() final  bool wholeWord;
@override@JsonKey() final  bool useRegex;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchStateCopyWith<_SearchState> get copyWith => __$SearchStateCopyWithImpl<_SearchState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchStateToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchState'))
    ..add(DiagnosticsProperty('isVisible', isVisible))..add(DiagnosticsProperty('searchQuery', searchQuery))..add(DiagnosticsProperty('currentMatchIndex', currentMatchIndex))..add(DiagnosticsProperty('totalMatches', totalMatches))..add(DiagnosticsProperty('caseSensitive', caseSensitive))..add(DiagnosticsProperty('wholeWord', wholeWord))..add(DiagnosticsProperty('useRegex', useRegex));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchState&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.currentMatchIndex, currentMatchIndex) || other.currentMatchIndex == currentMatchIndex)&&(identical(other.totalMatches, totalMatches) || other.totalMatches == totalMatches)&&(identical(other.caseSensitive, caseSensitive) || other.caseSensitive == caseSensitive)&&(identical(other.wholeWord, wholeWord) || other.wholeWord == wholeWord)&&(identical(other.useRegex, useRegex) || other.useRegex == useRegex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isVisible,searchQuery,currentMatchIndex,totalMatches,caseSensitive,wholeWord,useRegex);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchState(isVisible: $isVisible, searchQuery: $searchQuery, currentMatchIndex: $currentMatchIndex, totalMatches: $totalMatches, caseSensitive: $caseSensitive, wholeWord: $wholeWord, useRegex: $useRegex)';
}


}

/// @nodoc
abstract mixin class _$SearchStateCopyWith<$Res> implements $SearchStateCopyWith<$Res> {
  factory _$SearchStateCopyWith(_SearchState value, $Res Function(_SearchState) _then) = __$SearchStateCopyWithImpl;
@override @useResult
$Res call({
 bool isVisible, String searchQuery, int currentMatchIndex, int totalMatches, bool caseSensitive, bool wholeWord, bool useRegex
});




}
/// @nodoc
class __$SearchStateCopyWithImpl<$Res>
    implements _$SearchStateCopyWith<$Res> {
  __$SearchStateCopyWithImpl(this._self, this._then);

  final _SearchState _self;
  final $Res Function(_SearchState) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isVisible = null,Object? searchQuery = null,Object? currentMatchIndex = null,Object? totalMatches = null,Object? caseSensitive = null,Object? wholeWord = null,Object? useRegex = null,}) {
  return _then(_SearchState(
isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,currentMatchIndex: null == currentMatchIndex ? _self.currentMatchIndex : currentMatchIndex // ignore: cast_nullable_to_non_nullable
as int,totalMatches: null == totalMatches ? _self.totalMatches : totalMatches // ignore: cast_nullable_to_non_nullable
as int,caseSensitive: null == caseSensitive ? _self.caseSensitive : caseSensitive // ignore: cast_nullable_to_non_nullable
as bool,wholeWord: null == wholeWord ? _self.wholeWord : wholeWord // ignore: cast_nullable_to_non_nullable
as bool,useRegex: null == useRegex ? _self.useRegex : useRegex // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
