// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TranslationLangState {

 String get hash; String get token;
/// Create a copy of TranslationLangState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationLangStateCopyWith<TranslationLangState> get copyWith => _$TranslationLangStateCopyWithImpl<TranslationLangState>(this as TranslationLangState, _$identity);

  /// Serializes this TranslationLangState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationLangState&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hash,token);

@override
String toString() {
  return 'TranslationLangState(hash: $hash, token: $token)';
}


}

/// @nodoc
abstract mixin class $TranslationLangStateCopyWith<$Res>  {
  factory $TranslationLangStateCopyWith(TranslationLangState value, $Res Function(TranslationLangState) _then) = _$TranslationLangStateCopyWithImpl;
@useResult
$Res call({
 String hash, String token
});




}
/// @nodoc
class _$TranslationLangStateCopyWithImpl<$Res>
    implements $TranslationLangStateCopyWith<$Res> {
  _$TranslationLangStateCopyWithImpl(this._self, this._then);

  final TranslationLangState _self;
  final $Res Function(TranslationLangState) _then;

/// Create a copy of TranslationLangState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hash = null,Object? token = null,}) {
  return _then(_self.copyWith(
hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslationLangState].
extension TranslationLangStatePatterns on TranslationLangState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationLangState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationLangState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationLangState value)  $default,){
final _that = this;
switch (_that) {
case _TranslationLangState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationLangState value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationLangState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String hash,  String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationLangState() when $default != null:
return $default(_that.hash,_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String hash,  String token)  $default,) {final _that = this;
switch (_that) {
case _TranslationLangState():
return $default(_that.hash,_that.token);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String hash,  String token)?  $default,) {final _that = this;
switch (_that) {
case _TranslationLangState() when $default != null:
return $default(_that.hash,_that.token);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranslationLangState implements TranslationLangState {
  const _TranslationLangState({required this.hash, required this.token});
  factory _TranslationLangState.fromJson(Map<String, dynamic> json) => _$TranslationLangStateFromJson(json);

@override final  String hash;
@override final  String token;

/// Create a copy of TranslationLangState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationLangStateCopyWith<_TranslationLangState> get copyWith => __$TranslationLangStateCopyWithImpl<_TranslationLangState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranslationLangStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationLangState&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hash,token);

@override
String toString() {
  return 'TranslationLangState(hash: $hash, token: $token)';
}


}

/// @nodoc
abstract mixin class _$TranslationLangStateCopyWith<$Res> implements $TranslationLangStateCopyWith<$Res> {
  factory _$TranslationLangStateCopyWith(_TranslationLangState value, $Res Function(_TranslationLangState) _then) = __$TranslationLangStateCopyWithImpl;
@override @useResult
$Res call({
 String hash, String token
});




}
/// @nodoc
class __$TranslationLangStateCopyWithImpl<$Res>
    implements _$TranslationLangStateCopyWith<$Res> {
  __$TranslationLangStateCopyWithImpl(this._self, this._then);

  final _TranslationLangState _self;
  final $Res Function(_TranslationLangState) _then;

/// Create a copy of TranslationLangState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hash = null,Object? token = null,}) {
  return _then(_TranslationLangState(
hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TranslationBlockState {

 String get latestToken; Map<String, TranslationLangState> get langs;
/// Create a copy of TranslationBlockState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationBlockStateCopyWith<TranslationBlockState> get copyWith => _$TranslationBlockStateCopyWithImpl<TranslationBlockState>(this as TranslationBlockState, _$identity);

  /// Serializes this TranslationBlockState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationBlockState&&(identical(other.latestToken, latestToken) || other.latestToken == latestToken)&&const DeepCollectionEquality().equals(other.langs, langs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latestToken,const DeepCollectionEquality().hash(langs));

@override
String toString() {
  return 'TranslationBlockState(latestToken: $latestToken, langs: $langs)';
}


}

/// @nodoc
abstract mixin class $TranslationBlockStateCopyWith<$Res>  {
  factory $TranslationBlockStateCopyWith(TranslationBlockState value, $Res Function(TranslationBlockState) _then) = _$TranslationBlockStateCopyWithImpl;
@useResult
$Res call({
 String latestToken, Map<String, TranslationLangState> langs
});




}
/// @nodoc
class _$TranslationBlockStateCopyWithImpl<$Res>
    implements $TranslationBlockStateCopyWith<$Res> {
  _$TranslationBlockStateCopyWithImpl(this._self, this._then);

  final TranslationBlockState _self;
  final $Res Function(TranslationBlockState) _then;

/// Create a copy of TranslationBlockState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latestToken = null,Object? langs = null,}) {
  return _then(_self.copyWith(
latestToken: null == latestToken ? _self.latestToken : latestToken // ignore: cast_nullable_to_non_nullable
as String,langs: null == langs ? _self.langs : langs // ignore: cast_nullable_to_non_nullable
as Map<String, TranslationLangState>,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslationBlockState].
extension TranslationBlockStatePatterns on TranslationBlockState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationBlockState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationBlockState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationBlockState value)  $default,){
final _that = this;
switch (_that) {
case _TranslationBlockState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationBlockState value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationBlockState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String latestToken,  Map<String, TranslationLangState> langs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationBlockState() when $default != null:
return $default(_that.latestToken,_that.langs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String latestToken,  Map<String, TranslationLangState> langs)  $default,) {final _that = this;
switch (_that) {
case _TranslationBlockState():
return $default(_that.latestToken,_that.langs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String latestToken,  Map<String, TranslationLangState> langs)?  $default,) {final _that = this;
switch (_that) {
case _TranslationBlockState() when $default != null:
return $default(_that.latestToken,_that.langs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranslationBlockState implements TranslationBlockState {
  const _TranslationBlockState({required this.latestToken, final  Map<String, TranslationLangState> langs = const <String, TranslationLangState>{}}): _langs = langs;
  factory _TranslationBlockState.fromJson(Map<String, dynamic> json) => _$TranslationBlockStateFromJson(json);

@override final  String latestToken;
 final  Map<String, TranslationLangState> _langs;
@override@JsonKey() Map<String, TranslationLangState> get langs {
  if (_langs is EqualUnmodifiableMapView) return _langs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_langs);
}


/// Create a copy of TranslationBlockState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationBlockStateCopyWith<_TranslationBlockState> get copyWith => __$TranslationBlockStateCopyWithImpl<_TranslationBlockState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranslationBlockStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationBlockState&&(identical(other.latestToken, latestToken) || other.latestToken == latestToken)&&const DeepCollectionEquality().equals(other._langs, _langs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latestToken,const DeepCollectionEquality().hash(_langs));

@override
String toString() {
  return 'TranslationBlockState(latestToken: $latestToken, langs: $langs)';
}


}

/// @nodoc
abstract mixin class _$TranslationBlockStateCopyWith<$Res> implements $TranslationBlockStateCopyWith<$Res> {
  factory _$TranslationBlockStateCopyWith(_TranslationBlockState value, $Res Function(_TranslationBlockState) _then) = __$TranslationBlockStateCopyWithImpl;
@override @useResult
$Res call({
 String latestToken, Map<String, TranslationLangState> langs
});




}
/// @nodoc
class __$TranslationBlockStateCopyWithImpl<$Res>
    implements _$TranslationBlockStateCopyWith<$Res> {
  __$TranslationBlockStateCopyWithImpl(this._self, this._then);

  final _TranslationBlockState _self;
  final $Res Function(_TranslationBlockState) _then;

/// Create a copy of TranslationBlockState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latestToken = null,Object? langs = null,}) {
  return _then(_TranslationBlockState(
latestToken: null == latestToken ? _self.latestToken : latestToken // ignore: cast_nullable_to_non_nullable
as String,langs: null == langs ? _self._langs : langs // ignore: cast_nullable_to_non_nullable
as Map<String, TranslationLangState>,
  ));
}


}


/// @nodoc
mixin _$TranslationFileState {

 Map<String, TranslationBlockState> get blocks;
/// Create a copy of TranslationFileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationFileStateCopyWith<TranslationFileState> get copyWith => _$TranslationFileStateCopyWithImpl<TranslationFileState>(this as TranslationFileState, _$identity);

  /// Serializes this TranslationFileState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationFileState&&const DeepCollectionEquality().equals(other.blocks, blocks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(blocks));

@override
String toString() {
  return 'TranslationFileState(blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class $TranslationFileStateCopyWith<$Res>  {
  factory $TranslationFileStateCopyWith(TranslationFileState value, $Res Function(TranslationFileState) _then) = _$TranslationFileStateCopyWithImpl;
@useResult
$Res call({
 Map<String, TranslationBlockState> blocks
});




}
/// @nodoc
class _$TranslationFileStateCopyWithImpl<$Res>
    implements $TranslationFileStateCopyWith<$Res> {
  _$TranslationFileStateCopyWithImpl(this._self, this._then);

  final TranslationFileState _self;
  final $Res Function(TranslationFileState) _then;

/// Create a copy of TranslationFileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? blocks = null,}) {
  return _then(_self.copyWith(
blocks: null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as Map<String, TranslationBlockState>,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslationFileState].
extension TranslationFileStatePatterns on TranslationFileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationFileState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationFileState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationFileState value)  $default,){
final _that = this;
switch (_that) {
case _TranslationFileState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationFileState value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationFileState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, TranslationBlockState> blocks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationFileState() when $default != null:
return $default(_that.blocks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, TranslationBlockState> blocks)  $default,) {final _that = this;
switch (_that) {
case _TranslationFileState():
return $default(_that.blocks);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, TranslationBlockState> blocks)?  $default,) {final _that = this;
switch (_that) {
case _TranslationFileState() when $default != null:
return $default(_that.blocks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranslationFileState implements TranslationFileState {
  const _TranslationFileState({final  Map<String, TranslationBlockState> blocks = const <String, TranslationBlockState>{}}): _blocks = blocks;
  factory _TranslationFileState.fromJson(Map<String, dynamic> json) => _$TranslationFileStateFromJson(json);

 final  Map<String, TranslationBlockState> _blocks;
@override@JsonKey() Map<String, TranslationBlockState> get blocks {
  if (_blocks is EqualUnmodifiableMapView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_blocks);
}


/// Create a copy of TranslationFileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationFileStateCopyWith<_TranslationFileState> get copyWith => __$TranslationFileStateCopyWithImpl<_TranslationFileState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranslationFileStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationFileState&&const DeepCollectionEquality().equals(other._blocks, _blocks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_blocks));

@override
String toString() {
  return 'TranslationFileState(blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class _$TranslationFileStateCopyWith<$Res> implements $TranslationFileStateCopyWith<$Res> {
  factory _$TranslationFileStateCopyWith(_TranslationFileState value, $Res Function(_TranslationFileState) _then) = __$TranslationFileStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, TranslationBlockState> blocks
});




}
/// @nodoc
class __$TranslationFileStateCopyWithImpl<$Res>
    implements _$TranslationFileStateCopyWith<$Res> {
  __$TranslationFileStateCopyWithImpl(this._self, this._then);

  final _TranslationFileState _self;
  final $Res Function(_TranslationFileState) _then;

/// Create a copy of TranslationFileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? blocks = null,}) {
  return _then(_TranslationFileState(
blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as Map<String, TranslationBlockState>,
  ));
}


}


/// @nodoc
mixin _$TranslationProjectState {

 int get version; Map<String, TranslationFileState> get files;
/// Create a copy of TranslationProjectState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationProjectStateCopyWith<TranslationProjectState> get copyWith => _$TranslationProjectStateCopyWithImpl<TranslationProjectState>(this as TranslationProjectState, _$identity);

  /// Serializes this TranslationProjectState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationProjectState&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.files, files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,const DeepCollectionEquality().hash(files));

@override
String toString() {
  return 'TranslationProjectState(version: $version, files: $files)';
}


}

/// @nodoc
abstract mixin class $TranslationProjectStateCopyWith<$Res>  {
  factory $TranslationProjectStateCopyWith(TranslationProjectState value, $Res Function(TranslationProjectState) _then) = _$TranslationProjectStateCopyWithImpl;
@useResult
$Res call({
 int version, Map<String, TranslationFileState> files
});




}
/// @nodoc
class _$TranslationProjectStateCopyWithImpl<$Res>
    implements $TranslationProjectStateCopyWith<$Res> {
  _$TranslationProjectStateCopyWithImpl(this._self, this._then);

  final TranslationProjectState _self;
  final $Res Function(TranslationProjectState) _then;

/// Create a copy of TranslationProjectState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? files = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as Map<String, TranslationFileState>,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslationProjectState].
extension TranslationProjectStatePatterns on TranslationProjectState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationProjectState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationProjectState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationProjectState value)  $default,){
final _that = this;
switch (_that) {
case _TranslationProjectState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationProjectState value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationProjectState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int version,  Map<String, TranslationFileState> files)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationProjectState() when $default != null:
return $default(_that.version,_that.files);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int version,  Map<String, TranslationFileState> files)  $default,) {final _that = this;
switch (_that) {
case _TranslationProjectState():
return $default(_that.version,_that.files);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int version,  Map<String, TranslationFileState> files)?  $default,) {final _that = this;
switch (_that) {
case _TranslationProjectState() when $default != null:
return $default(_that.version,_that.files);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranslationProjectState implements TranslationProjectState {
  const _TranslationProjectState({this.version = 1, final  Map<String, TranslationFileState> files = const <String, TranslationFileState>{}}): _files = files;
  factory _TranslationProjectState.fromJson(Map<String, dynamic> json) => _$TranslationProjectStateFromJson(json);

@override@JsonKey() final  int version;
 final  Map<String, TranslationFileState> _files;
@override@JsonKey() Map<String, TranslationFileState> get files {
  if (_files is EqualUnmodifiableMapView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_files);
}


/// Create a copy of TranslationProjectState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationProjectStateCopyWith<_TranslationProjectState> get copyWith => __$TranslationProjectStateCopyWithImpl<_TranslationProjectState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranslationProjectStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationProjectState&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._files, _files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,const DeepCollectionEquality().hash(_files));

@override
String toString() {
  return 'TranslationProjectState(version: $version, files: $files)';
}


}

/// @nodoc
abstract mixin class _$TranslationProjectStateCopyWith<$Res> implements $TranslationProjectStateCopyWith<$Res> {
  factory _$TranslationProjectStateCopyWith(_TranslationProjectState value, $Res Function(_TranslationProjectState) _then) = __$TranslationProjectStateCopyWithImpl;
@override @useResult
$Res call({
 int version, Map<String, TranslationFileState> files
});




}
/// @nodoc
class __$TranslationProjectStateCopyWithImpl<$Res>
    implements _$TranslationProjectStateCopyWith<$Res> {
  __$TranslationProjectStateCopyWithImpl(this._self, this._then);

  final _TranslationProjectState _self;
  final $Res Function(_TranslationProjectState) _then;

/// Create a copy of TranslationProjectState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? files = null,}) {
  return _then(_TranslationProjectState(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as Map<String, TranslationFileState>,
  ));
}


}

// dart format on
