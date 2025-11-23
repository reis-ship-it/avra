// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  displayName: json['displayName'] as String?,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  isAgeVerified: json['isAgeVerified'] as bool? ?? false,
  followedLists:
      (json['followedLists'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  curatedLists:
      (json['curatedLists'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  collaboratedLists:
      (json['collaboratedLists'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  avatarUrl: json['avatarUrl'] as String?,
  bio: json['bio'] as String?,
  location: json['location'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  expertise:
      (json['expertise'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  friends:
      (json['friends'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isOnline: json['isOnline'] as bool?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'displayName': instance.displayName,
  'role': _$UserRoleEnumMap[instance.role]!,
  'isAgeVerified': instance.isAgeVerified,
  'followedLists': instance.followedLists,
  'curatedLists': instance.curatedLists,
  'collaboratedLists': instance.collaboratedLists,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'avatarUrl': instance.avatarUrl,
  'bio': instance.bio,
  'location': instance.location,
  'tags': instance.tags,
  'expertise': instance.expertise,
  'friends': instance.friends,
  'isOnline': instance.isOnline,
};

const _$UserRoleEnumMap = {
  UserRole.follower: 'follower',
  UserRole.collaborator: 'collaborator',
  UserRole.curator: 'curator',
  UserRole.admin: 'admin',
};
