import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Thrown when a location id is empty or whitespace-only.
@immutable
class LocationIdError implements Exception {
  final String message;
  const LocationIdError(this.message);

  @override
  String toString() => 'LocationIdError: $message';
}

/// Represents a network inventory location as defined in UML::NiLocation.
///
/// [id] is a required unique identifier.
/// [type] is the location type (e.g. "site", "building", "equipment room").
/// [parent] references the parent location for hierarchical structures.
@immutable
@realizes(r'UML::NiLocation')
class NiLocation {
  final String id;
  final String? type;
  final String? parent;
  final String? timestamp;
  final String? validUntil;
  final String? address;

  NiLocation({
    required this.id,
    this.type,
    this.parent,
    this.timestamp,
    this.validUntil,
    this.address,
  }) {
    if (id.trim().isEmpty) {
      throw const LocationIdError('id must not be empty');
    }
  }

  bool isValid() => id.trim().isNotEmpty;

  bool isExpired(DateTime now) {
    if (validUntil == null) return false;
    try {
      final expiry = DateTime.parse(validUntil!);
      return expiry.isBefore(now);
    } on FormatException {
      return false;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (type != null) 'type': type,
        if (parent != null) 'parent': parent,
        if (timestamp != null) 'timestamp': timestamp,
        if (validUntil != null) 'valid_until': validUntil,
        if (address != null) 'address': address,
      };

  factory NiLocation.fromJson(Map<String, dynamic> json) {
    return NiLocation(
      id: json['id'] as String,
      type: json['type'] as String?,
      parent: json['parent'] as String?,
      timestamp: json['timestamp'] as String?,
      validUntil: json['valid_until'] as String?,
      address: json['address'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NiLocation &&
          other.id == id &&
          other.type == type &&
          other.parent == parent &&
          other.timestamp == timestamp &&
          other.validUntil == validUntil &&
          other.address == address;

  @override
  int get hashCode => Object.hash(id, type, parent, timestamp, validUntil, address);

  @override
  String toString() => 'NiLocation(id: $id, type: $type)';
}
