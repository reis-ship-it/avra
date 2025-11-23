// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_location_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnifiedLocationData _$UnifiedLocationDataFromJson(Map<String, dynamic> json) =>
    UnifiedLocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$UnifiedLocationDataToJson(
  UnifiedLocationData instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'address': instance.address,
  'city': instance.city,
  'region': instance.region,
  'country': instance.country,
  'postalCode': instance.postalCode,
  'accuracy': instance.accuracy,
  'timestamp': instance.timestamp?.toIso8601String(),
};
