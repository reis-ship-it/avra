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
  final List<String> tags;
  final Map<String, dynamic> metadata;

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
    this.tags = const [],
    this.metadata = const {},
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
    List<String>? tags,
    Map<String, dynamic>? metadata,
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
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
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
      'tags': tags,
      'metadata': metadata,
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
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}
