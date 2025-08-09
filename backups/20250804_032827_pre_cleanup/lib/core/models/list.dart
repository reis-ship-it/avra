import 'package:spots/core/models/spot.dart';

class SpotList {
  final String id;
  final String title;
  final String description;
  final List<Spot> spots;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? category;
  final bool isPublic;
  final List<String> spotIds;
  final int respectCount;

  const SpotList({
    required this.id,
    required this.title,
    required this.description,
    required this.spots,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.isPublic = true,
    this.spotIds = const [],
    this.respectCount = 0,
  });

  SpotList copyWith({
    String? id,
    String? title,
    String? description,
    List<Spot>? spots,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    bool? isPublic,
    List<String>? spotIds,
    int? respectCount,
  }) {
    return SpotList(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      spots: spots ?? this.spots,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
      spotIds: spotIds ?? this.spotIds,
      respectCount: respectCount ?? this.respectCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'spots': spots.map((spot) => spot.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'category': category,
      'isPublic': isPublic,
      'spotIds': spotIds,
      'respectCount': respectCount,
    };
  }

  factory SpotList.fromJson(Map<String, dynamic> json) {
    return SpotList(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      spots: (json['spots'] as List<dynamic>?)
          ?.map((spotJson) => Spot.fromJson(spotJson))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      category: json['category'],
      isPublic: json['isPublic'] ?? true,
      spotIds: List<String>.from(json['spotIds'] ?? []),
      respectCount: json['respectCount'] ?? 0,
    );
  }

  // Convenience methods
  Map<String, dynamic> toMap() => toJson();
  factory SpotList.fromMap(Map<String, dynamic> map) => SpotList.fromJson(map);
}
