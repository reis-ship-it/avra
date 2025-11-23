// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Spot _$SpotFromJson(Map<String, dynamic> json) => Spot(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  category: json['category'] as String,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  address: json['address'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  website: json['website'] as String?,
  imageUrl: json['imageUrl'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  priceLevel: $enumDecodeNullable(_$PriceLevelEnumMap, json['priceLevel']),
  verificationLevel:
      $enumDecodeNullable(
        _$VerificationLevelEnumMap,
        json['verificationLevel'],
      ) ??
      VerificationLevel.none,
  moderationStatus:
      $enumDecodeNullable(
        _$ModerationStatusEnumMap,
        json['moderationStatus'],
      ) ??
      ModerationStatus.pending,
  isAgeRestricted: json['isAgeRestricted'] as bool? ?? false,
  listId: json['listId'] as String?,
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  respectCount: (json['respectCount'] as num?)?.toInt() ?? 0,
  shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
  respectedBy:
      (json['respectedBy'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$SpotToJson(Spot instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'category': instance.category,
  'rating': instance.rating,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'address': instance.address,
  'phoneNumber': instance.phoneNumber,
  'website': instance.website,
  'imageUrl': instance.imageUrl,
  'tags': instance.tags,
  'metadata': instance.metadata,
  'priceLevel': _$PriceLevelEnumMap[instance.priceLevel],
  'verificationLevel': _$VerificationLevelEnumMap[instance.verificationLevel]!,
  'moderationStatus': _$ModerationStatusEnumMap[instance.moderationStatus]!,
  'isAgeRestricted': instance.isAgeRestricted,
  'listId': instance.listId,
  'viewCount': instance.viewCount,
  'respectCount': instance.respectCount,
  'shareCount': instance.shareCount,
  'respectedBy': instance.respectedBy,
};

const _$PriceLevelEnumMap = {
  PriceLevel.free: 'free',
  PriceLevel.low: 'low',
  PriceLevel.moderate: 'moderate',
  PriceLevel.high: 'high',
  PriceLevel.luxury: 'luxury',
};

const _$VerificationLevelEnumMap = {
  VerificationLevel.none: 'none',
  VerificationLevel.basic: 'basic',
  VerificationLevel.verified: 'verified',
  VerificationLevel.expert: 'expert',
};

const _$ModerationStatusEnumMap = {
  ModerationStatus.pending: 'pending',
  ModerationStatus.approved: 'approved',
  ModerationStatus.rejected: 'rejected',
  ModerationStatus.flagged: 'flagged',
};
