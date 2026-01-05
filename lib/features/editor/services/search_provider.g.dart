// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchState _$SearchStateFromJson(Map<String, dynamic> json) => _SearchState(
  isVisible: json['isVisible'] as bool? ?? false,
  searchQuery: json['searchQuery'] as String? ?? '',
  currentMatchIndex: (json['currentMatchIndex'] as num?)?.toInt() ?? 0,
  totalMatches: (json['totalMatches'] as num?)?.toInt() ?? 0,
  caseSensitive: json['caseSensitive'] as bool? ?? false,
  wholeWord: json['wholeWord'] as bool? ?? false,
  useRegex: json['useRegex'] as bool? ?? false,
);

Map<String, dynamic> _$SearchStateToJson(_SearchState instance) =>
    <String, dynamic>{
      'isVisible': instance.isVisible,
      'searchQuery': instance.searchQuery,
      'currentMatchIndex': instance.currentMatchIndex,
      'totalMatches': instance.totalMatches,
      'caseSensitive': instance.caseSensitive,
      'wholeWord': instance.wholeWord,
      'useRegex': instance.useRegex,
    };
