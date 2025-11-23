// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_vibe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserVibe _$UserVibeFromJson(Map<String, dynamic> json) => UserVibe(
  hashedSignature: json['hashedSignature'] as String,
  anonymizedDimensions: (json['anonymizedDimensions'] as Map<String, dynamic>)
      .map((k, e) => MapEntry(k, (e as num).toDouble())),
  overallEnergy: (json['overallEnergy'] as num).toDouble(),
  socialPreference: (json['socialPreference'] as num).toDouble(),
  explorationTendency: (json['explorationTendency'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  privacyLevel: (json['privacyLevel'] as num).toDouble(),
  temporalContext: json['temporalContext'] as String,
);

Map<String, dynamic> _$UserVibeToJson(UserVibe instance) => <String, dynamic>{
  'hashedSignature': instance.hashedSignature,
  'anonymizedDimensions': instance.anonymizedDimensions,
  'overallEnergy': instance.overallEnergy,
  'socialPreference': instance.socialPreference,
  'explorationTendency': instance.explorationTendency,
  'createdAt': instance.createdAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
  'privacyLevel': instance.privacyLevel,
  'temporalContext': instance.temporalContext,
};
