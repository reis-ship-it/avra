class Spot {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String category;
  final double rating;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? address;
  final String? phoneNumber;
  final String? website;
  final String? imageUrl;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  
  // Google Places integration
  final String? googlePlaceId; // Google Place ID for syncing with Google Maps
  final DateTime? googlePlaceIdSyncedAt; // When Google Place ID was last synced

  const Spot({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.rating,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.address,
    this.phoneNumber,
    this.website,
    this.imageUrl,
    this.tags = const [],
    this.metadata = const {},
    this.googlePlaceId,
    this.googlePlaceIdSyncedAt,
  });

  Spot copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? category,
    double? rating,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? address,
    String? phoneNumber,
    String? website,
    String? imageUrl,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? googlePlaceId,
    DateTime? googlePlaceIdSyncedAt,
  }) {
    return Spot(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      googlePlaceId: googlePlaceId ?? this.googlePlaceId,
      googlePlaceIdSyncedAt: googlePlaceIdSyncedAt ?? this.googlePlaceIdSyncedAt,
    );
  }
  
  /// Check if spot has Google Place ID mapping
  bool get hasGooglePlaceId => googlePlaceId != null && googlePlaceId!.isNotEmpty;
  
  /// Check if Google Place ID sync is stale (older than 30 days)
  bool get isGooglePlaceIdStale {
    if (googlePlaceIdSyncedAt == null) return true;
    return DateTime.now().difference(googlePlaceIdSyncedAt!) > const Duration(days: 30);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'rating': rating,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'address': address,
      'phoneNumber': phoneNumber,
      'website': website,
      'imageUrl': imageUrl,
      'tags': tags,
      'metadata': metadata,
      'googlePlaceId': googlePlaceId,
      'googlePlaceIdSyncedAt': googlePlaceIdSyncedAt?.toIso8601String(),
    };
  }

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      website: json['website'],
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      googlePlaceId: json['googlePlaceId'],
      googlePlaceIdSyncedAt: json['googlePlaceIdSyncedAt'] != null
          ? DateTime.parse(json['googlePlaceIdSyncedAt'])
          : null,
    );
  }
}
