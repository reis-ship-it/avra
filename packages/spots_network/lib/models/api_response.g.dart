// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ApiResponse<T>(
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  success: json['success'] as bool,
  error: json['error'] as String?,
  errorCode: json['errorCode'] as String?,
  errorDetails: json['errorDetails'] as Map<String, dynamic>?,
  metadata: json['metadata'] == null
      ? null
      : ResponseMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'success': instance.success,
  'error': instance.error,
  'errorCode': instance.errorCode,
  'errorDetails': instance.errorDetails,
  'metadata': instance.metadata,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

ResponseMetadata _$ResponseMetadataFromJson(Map<String, dynamic> json) =>
    ResponseMetadata(
      page: (json['page'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      cursor: json['cursor'] as String?,
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool?,
      requestDuration: json['requestDuration'] == null
          ? null
          : Duration(microseconds: (json['requestDuration'] as num).toInt()),
      requestId: json['requestId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      extra: json['extra'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ResponseMetadataToJson(ResponseMetadata instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'cursor': instance.cursor,
      'nextCursor': instance.nextCursor,
      'hasMore': instance.hasMore,
      'requestDuration': instance.requestDuration?.inMicroseconds,
      'requestId': instance.requestId,
      'timestamp': instance.timestamp.toIso8601String(),
      'extra': instance.extra,
    };
