// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialContext _$SocialContextFromJson(Map<String, dynamic> json) =>
    SocialContext(
      type: $enumDecode(_$SocialContextTypeEnumMap, json['type']),
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 1,
      participantIds:
          (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$SocialContextToJson(SocialContext instance) =>
    <String, dynamic>{
      'type': _$SocialContextTypeEnumMap[instance.type]!,
      'participantCount': instance.participantCount,
      'participantIds': instance.participantIds,
      'metadata': instance.metadata,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'description': instance.description,
    };

const _$SocialContextTypeEnumMap = {
  SocialContextType.solo: 'solo',
  SocialContextType.couple: 'couple',
  SocialContextType.group: 'group',
  SocialContextType.family: 'family',
  SocialContextType.business: 'business',
  SocialContextType.event: 'event',
};
