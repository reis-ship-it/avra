// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackendConfig _$BackendConfigFromJson(Map<String, dynamic> json) =>
    BackendConfig(
      type: $enumDecode(_$BackendTypeEnumMap, json['type']),
      name: json['name'] as String,
      config: json['config'] as Map<String, dynamic>,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$BackendConfigToJson(BackendConfig instance) =>
    <String, dynamic>{
      'type': _$BackendTypeEnumMap[instance.type]!,
      'name': instance.name,
      'config': instance.config,
      'isDefault': instance.isDefault,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$BackendTypeEnumMap = {
  BackendType.firebase: 'firebase',
  BackendType.supabase: 'supabase',
  BackendType.custom: 'custom',
};
