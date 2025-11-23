// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spot_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotList _$SpotListFromJson(Map<String, dynamic> json) => SpotList(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$ListCategoryEnumMap, json['category']),
  type: $enumDecode(_$ListTypeEnumMap, json['type']),
  curatorId: json['curatorId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isPublic: json['isPublic'] as bool? ?? true,
  moderationLevel:
      $enumDecodeNullable(_$ModerationLevelEnumMap, json['moderationLevel']) ??
      ModerationLevel.standard,
  isAgeRestricted: json['isAgeRestricted'] as bool? ?? false,
  allowedViewers:
      (json['allowedViewers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  spotIds:
      (json['spotIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  imageUrl: json['imageUrl'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  respectCount: (json['respectCount'] as num?)?.toInt() ?? 0,
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
  respectedBy:
      (json['respectedBy'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  followers:
      (json['followers'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  collaboratorIds:
      (json['collaboratorIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  memberIds:
      (json['memberIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  userRoles:
      (json['userRoles'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, $enumDecode(_$ListRoleEnumMap, e)),
      ) ??
      const {},
);

Map<String, dynamic> _$SpotListToJson(SpotList instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': _$ListCategoryEnumMap[instance.category]!,
  'type': _$ListTypeEnumMap[instance.type]!,
  'curatorId': instance.curatorId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isPublic': instance.isPublic,
  'moderationLevel': _$ModerationLevelEnumMap[instance.moderationLevel]!,
  'isAgeRestricted': instance.isAgeRestricted,
  'allowedViewers': instance.allowedViewers,
  'spotIds': instance.spotIds,
  'imageUrl': instance.imageUrl,
  'tags': instance.tags,
  'metadata': instance.metadata,
  'respectCount': instance.respectCount,
  'viewCount': instance.viewCount,
  'shareCount': instance.shareCount,
  'respectedBy': instance.respectedBy,
  'followers': instance.followers,
  'collaboratorIds': instance.collaboratorIds,
  'memberIds': instance.memberIds,
  'userRoles': instance.userRoles.map(
    (k, e) => MapEntry(k, _$ListRoleEnumMap[e]!),
  ),
};

const _$ListCategoryEnumMap = {
  ListCategory.general: 'general',
  ListCategory.food: 'food',
  ListCategory.entertainment: 'entertainment',
  ListCategory.shopping: 'shopping',
  ListCategory.outdoor: 'outdoor',
  ListCategory.travel: 'travel',
  ListCategory.culture: 'culture',
  ListCategory.health: 'health',
};

const _$ListTypeEnumMap = {
  ListType.public: 'public',
  ListType.private: 'private',
  ListType.curated: 'curated',
  ListType.collaborative: 'collaborative',
};

const _$ModerationLevelEnumMap = {
  ModerationLevel.relaxed: 'relaxed',
  ModerationLevel.standard: 'standard',
  ModerationLevel.strict: 'strict',
  ModerationLevel.maximum: 'maximum',
};

const _$ListRoleEnumMap = {
  ListRole.curator: 'curator',
  ListRole.collaborator: 'collaborator',
  ListRole.member: 'member',
  ListRole.viewer: 'viewer',
};
