// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compilation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
CompilationResult _$CompilationResultFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'success':
          return _CompilationSuccess.fromJson(
            json
          );
                case 'error':
          return _CompilationError.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'CompilationResult',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$CompilationResult {

 String? get languageCode;
/// Create a copy of CompilationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompilationResultCopyWith<CompilationResult> get copyWith => _$CompilationResultCopyWithImpl<CompilationResult>(this as CompilationResult, _$identity);

  /// Serializes this CompilationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompilationResult&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,languageCode);

@override
String toString() {
  return 'CompilationResult(languageCode: $languageCode)';
}


}

/// @nodoc
abstract mixin class $CompilationResultCopyWith<$Res>  {
  factory $CompilationResultCopyWith(CompilationResult value, $Res Function(CompilationResult) _then) = _$CompilationResultCopyWithImpl;
@useResult
$Res call({
 String? languageCode
});




}
/// @nodoc
class _$CompilationResultCopyWithImpl<$Res>
    implements $CompilationResultCopyWith<$Res> {
  _$CompilationResultCopyWithImpl(this._self, this._then);

  final CompilationResult _self;
  final $Res Function(CompilationResult) _then;

/// Create a copy of CompilationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? languageCode = freezed,}) {
  return _then(_self.copyWith(
languageCode: freezed == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompilationResult].
extension CompilationResultPatterns on CompilationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CompilationSuccess value)?  success,TResult Function( _CompilationError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompilationSuccess() when success != null:
return success(_that);case _CompilationError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CompilationSuccess value)  success,required TResult Function( _CompilationError value)  error,}){
final _that = this;
switch (_that) {
case _CompilationSuccess():
return success(_that);case _CompilationError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CompilationSuccess value)?  success,TResult? Function( _CompilationError value)?  error,}){
final _that = this;
switch (_that) {
case _CompilationSuccess() when success != null:
return success(_that);case _CompilationError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String pdfPath,  String? languageCode,  DateTime compiledAt)?  success,TResult Function( String message,  String? languageCode,  String? stderr,  int? exitCode)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompilationSuccess() when success != null:
return success(_that.pdfPath,_that.languageCode,_that.compiledAt);case _CompilationError() when error != null:
return error(_that.message,_that.languageCode,_that.stderr,_that.exitCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String pdfPath,  String? languageCode,  DateTime compiledAt)  success,required TResult Function( String message,  String? languageCode,  String? stderr,  int? exitCode)  error,}) {final _that = this;
switch (_that) {
case _CompilationSuccess():
return success(_that.pdfPath,_that.languageCode,_that.compiledAt);case _CompilationError():
return error(_that.message,_that.languageCode,_that.stderr,_that.exitCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String pdfPath,  String? languageCode,  DateTime compiledAt)?  success,TResult? Function( String message,  String? languageCode,  String? stderr,  int? exitCode)?  error,}) {final _that = this;
switch (_that) {
case _CompilationSuccess() when success != null:
return success(_that.pdfPath,_that.languageCode,_that.compiledAt);case _CompilationError() when error != null:
return error(_that.message,_that.languageCode,_that.stderr,_that.exitCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompilationSuccess extends CompilationResult {
  const _CompilationSuccess({required this.pdfPath, this.languageCode, required this.compiledAt, final  String? $type}): $type = $type ?? 'success',super._();
  factory _CompilationSuccess.fromJson(Map<String, dynamic> json) => _$CompilationSuccessFromJson(json);

 final  String pdfPath;
@override final  String? languageCode;
 final  DateTime compiledAt;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CompilationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompilationSuccessCopyWith<_CompilationSuccess> get copyWith => __$CompilationSuccessCopyWithImpl<_CompilationSuccess>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompilationSuccessToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompilationSuccess&&(identical(other.pdfPath, pdfPath) || other.pdfPath == pdfPath)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.compiledAt, compiledAt) || other.compiledAt == compiledAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pdfPath,languageCode,compiledAt);

@override
String toString() {
  return 'CompilationResult.success(pdfPath: $pdfPath, languageCode: $languageCode, compiledAt: $compiledAt)';
}


}

/// @nodoc
abstract mixin class _$CompilationSuccessCopyWith<$Res> implements $CompilationResultCopyWith<$Res> {
  factory _$CompilationSuccessCopyWith(_CompilationSuccess value, $Res Function(_CompilationSuccess) _then) = __$CompilationSuccessCopyWithImpl;
@override @useResult
$Res call({
 String pdfPath, String? languageCode, DateTime compiledAt
});




}
/// @nodoc
class __$CompilationSuccessCopyWithImpl<$Res>
    implements _$CompilationSuccessCopyWith<$Res> {
  __$CompilationSuccessCopyWithImpl(this._self, this._then);

  final _CompilationSuccess _self;
  final $Res Function(_CompilationSuccess) _then;

/// Create a copy of CompilationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pdfPath = null,Object? languageCode = freezed,Object? compiledAt = null,}) {
  return _then(_CompilationSuccess(
pdfPath: null == pdfPath ? _self.pdfPath : pdfPath // ignore: cast_nullable_to_non_nullable
as String,languageCode: freezed == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String?,compiledAt: null == compiledAt ? _self.compiledAt : compiledAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _CompilationError extends CompilationResult {
  const _CompilationError({required this.message, this.languageCode, this.stderr, this.exitCode, final  String? $type}): $type = $type ?? 'error',super._();
  factory _CompilationError.fromJson(Map<String, dynamic> json) => _$CompilationErrorFromJson(json);

 final  String message;
@override final  String? languageCode;
 final  String? stderr;
 final  int? exitCode;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CompilationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompilationErrorCopyWith<_CompilationError> get copyWith => __$CompilationErrorCopyWithImpl<_CompilationError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompilationErrorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompilationError&&(identical(other.message, message) || other.message == message)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.stderr, stderr) || other.stderr == stderr)&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,languageCode,stderr,exitCode);

@override
String toString() {
  return 'CompilationResult.error(message: $message, languageCode: $languageCode, stderr: $stderr, exitCode: $exitCode)';
}


}

/// @nodoc
abstract mixin class _$CompilationErrorCopyWith<$Res> implements $CompilationResultCopyWith<$Res> {
  factory _$CompilationErrorCopyWith(_CompilationError value, $Res Function(_CompilationError) _then) = __$CompilationErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String? languageCode, String? stderr, int? exitCode
});




}
/// @nodoc
class __$CompilationErrorCopyWithImpl<$Res>
    implements _$CompilationErrorCopyWith<$Res> {
  __$CompilationErrorCopyWithImpl(this._self, this._then);

  final _CompilationError _self;
  final $Res Function(_CompilationError) _then;

/// Create a copy of CompilationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? languageCode = freezed,Object? stderr = freezed,Object? exitCode = freezed,}) {
  return _then(_CompilationError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,languageCode: freezed == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String?,stderr: freezed == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String?,exitCode: freezed == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
