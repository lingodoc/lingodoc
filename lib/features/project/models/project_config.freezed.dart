// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectConfig {

 List<LanguageConfig> get languages; List<String> get languageOrder; String get viewMode; EditorSettings get editorSettings; ProjectSettings get projectSettings;
/// Create a copy of ProjectConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectConfigCopyWith<ProjectConfig> get copyWith => _$ProjectConfigCopyWithImpl<ProjectConfig>(this as ProjectConfig, _$identity);

  /// Serializes this ProjectConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectConfig&&const DeepCollectionEquality().equals(other.languages, languages)&&const DeepCollectionEquality().equals(other.languageOrder, languageOrder)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.editorSettings, editorSettings) || other.editorSettings == editorSettings)&&(identical(other.projectSettings, projectSettings) || other.projectSettings == projectSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(languages),const DeepCollectionEquality().hash(languageOrder),viewMode,editorSettings,projectSettings);

@override
String toString() {
  return 'ProjectConfig(languages: $languages, languageOrder: $languageOrder, viewMode: $viewMode, editorSettings: $editorSettings, projectSettings: $projectSettings)';
}


}

/// @nodoc
abstract mixin class $ProjectConfigCopyWith<$Res>  {
  factory $ProjectConfigCopyWith(ProjectConfig value, $Res Function(ProjectConfig) _then) = _$ProjectConfigCopyWithImpl;
@useResult
$Res call({
 List<LanguageConfig> languages, List<String> languageOrder, String viewMode, EditorSettings editorSettings, ProjectSettings projectSettings
});


$EditorSettingsCopyWith<$Res> get editorSettings;$ProjectSettingsCopyWith<$Res> get projectSettings;

}
/// @nodoc
class _$ProjectConfigCopyWithImpl<$Res>
    implements $ProjectConfigCopyWith<$Res> {
  _$ProjectConfigCopyWithImpl(this._self, this._then);

  final ProjectConfig _self;
  final $Res Function(ProjectConfig) _then;

/// Create a copy of ProjectConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? languages = null,Object? languageOrder = null,Object? viewMode = null,Object? editorSettings = null,Object? projectSettings = null,}) {
  return _then(_self.copyWith(
languages: null == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<LanguageConfig>,languageOrder: null == languageOrder ? _self.languageOrder : languageOrder // ignore: cast_nullable_to_non_nullable
as List<String>,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as String,editorSettings: null == editorSettings ? _self.editorSettings : editorSettings // ignore: cast_nullable_to_non_nullable
as EditorSettings,projectSettings: null == projectSettings ? _self.projectSettings : projectSettings // ignore: cast_nullable_to_non_nullable
as ProjectSettings,
  ));
}
/// Create a copy of ProjectConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EditorSettingsCopyWith<$Res> get editorSettings {
  
  return $EditorSettingsCopyWith<$Res>(_self.editorSettings, (value) {
    return _then(_self.copyWith(editorSettings: value));
  });
}/// Create a copy of ProjectConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectSettingsCopyWith<$Res> get projectSettings {
  
  return $ProjectSettingsCopyWith<$Res>(_self.projectSettings, (value) {
    return _then(_self.copyWith(projectSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProjectConfig].
extension ProjectConfigPatterns on ProjectConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectConfig value)  $default,){
final _that = this;
switch (_that) {
case _ProjectConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LanguageConfig> languages,  List<String> languageOrder,  String viewMode,  EditorSettings editorSettings,  ProjectSettings projectSettings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectConfig() when $default != null:
return $default(_that.languages,_that.languageOrder,_that.viewMode,_that.editorSettings,_that.projectSettings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LanguageConfig> languages,  List<String> languageOrder,  String viewMode,  EditorSettings editorSettings,  ProjectSettings projectSettings)  $default,) {final _that = this;
switch (_that) {
case _ProjectConfig():
return $default(_that.languages,_that.languageOrder,_that.viewMode,_that.editorSettings,_that.projectSettings);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LanguageConfig> languages,  List<String> languageOrder,  String viewMode,  EditorSettings editorSettings,  ProjectSettings projectSettings)?  $default,) {final _that = this;
switch (_that) {
case _ProjectConfig() when $default != null:
return $default(_that.languages,_that.languageOrder,_that.viewMode,_that.editorSettings,_that.projectSettings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectConfig extends ProjectConfig {
  const _ProjectConfig({required final  List<LanguageConfig> languages, required final  List<String> languageOrder, this.viewMode = 'Sequential', this.editorSettings = const EditorSettings(), required this.projectSettings}): _languages = languages,_languageOrder = languageOrder,super._();
  factory _ProjectConfig.fromJson(Map<String, dynamic> json) => _$ProjectConfigFromJson(json);

 final  List<LanguageConfig> _languages;
@override List<LanguageConfig> get languages {
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languages);
}

 final  List<String> _languageOrder;
@override List<String> get languageOrder {
  if (_languageOrder is EqualUnmodifiableListView) return _languageOrder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languageOrder);
}

@override@JsonKey() final  String viewMode;
@override@JsonKey() final  EditorSettings editorSettings;
@override final  ProjectSettings projectSettings;

/// Create a copy of ProjectConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectConfigCopyWith<_ProjectConfig> get copyWith => __$ProjectConfigCopyWithImpl<_ProjectConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectConfig&&const DeepCollectionEquality().equals(other._languages, _languages)&&const DeepCollectionEquality().equals(other._languageOrder, _languageOrder)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.editorSettings, editorSettings) || other.editorSettings == editorSettings)&&(identical(other.projectSettings, projectSettings) || other.projectSettings == projectSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_languages),const DeepCollectionEquality().hash(_languageOrder),viewMode,editorSettings,projectSettings);

@override
String toString() {
  return 'ProjectConfig(languages: $languages, languageOrder: $languageOrder, viewMode: $viewMode, editorSettings: $editorSettings, projectSettings: $projectSettings)';
}


}

/// @nodoc
abstract mixin class _$ProjectConfigCopyWith<$Res> implements $ProjectConfigCopyWith<$Res> {
  factory _$ProjectConfigCopyWith(_ProjectConfig value, $Res Function(_ProjectConfig) _then) = __$ProjectConfigCopyWithImpl;
@override @useResult
$Res call({
 List<LanguageConfig> languages, List<String> languageOrder, String viewMode, EditorSettings editorSettings, ProjectSettings projectSettings
});


@override $EditorSettingsCopyWith<$Res> get editorSettings;@override $ProjectSettingsCopyWith<$Res> get projectSettings;

}
/// @nodoc
class __$ProjectConfigCopyWithImpl<$Res>
    implements _$ProjectConfigCopyWith<$Res> {
  __$ProjectConfigCopyWithImpl(this._self, this._then);

  final _ProjectConfig _self;
  final $Res Function(_ProjectConfig) _then;

/// Create a copy of ProjectConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? languages = null,Object? languageOrder = null,Object? viewMode = null,Object? editorSettings = null,Object? projectSettings = null,}) {
  return _then(_ProjectConfig(
languages: null == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<LanguageConfig>,languageOrder: null == languageOrder ? _self._languageOrder : languageOrder // ignore: cast_nullable_to_non_nullable
as List<String>,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as String,editorSettings: null == editorSettings ? _self.editorSettings : editorSettings // ignore: cast_nullable_to_non_nullable
as EditorSettings,projectSettings: null == projectSettings ? _self.projectSettings : projectSettings // ignore: cast_nullable_to_non_nullable
as ProjectSettings,
  ));
}

/// Create a copy of ProjectConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EditorSettingsCopyWith<$Res> get editorSettings {
  
  return $EditorSettingsCopyWith<$Res>(_self.editorSettings, (value) {
    return _then(_self.copyWith(editorSettings: value));
  });
}/// Create a copy of ProjectConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectSettingsCopyWith<$Res> get projectSettings {
  
  return $ProjectSettingsCopyWith<$Res>(_self.projectSettings, (value) {
    return _then(_self.copyWith(projectSettings: value));
  });
}
}

// dart format on
