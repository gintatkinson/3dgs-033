import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Thrown when a rack id is empty or a rack class value is invalid.
@immutable
class RackClassError implements Exception {
  final String message;
  const RackClassError(this.message);

  @override
  String toString() => 'RackClassError: $message';
}

const _validRackClasses = {
  'rack-standard',
  'rack-secure-baseline',
  'rack-secure-medium',
  'rack-secure-high',
};

/// Represents a physical rack as defined in UML::Rack.
///
/// [id] is a required identifier.
/// [rackClass] must be one of the predefined rack classes.
/// [height], [width], [depth] are physical dimensions in mm.
/// [maxVoltage] and [maxAllocatedPower] are electrical limits.
@immutable
@realizes(r'UML::Rack')
class Rack {
  final String id;
  final String? rackClass;
  final int? height;
  final int? width;
  final int? depth;
  final int? maxVoltage;
  final int? maxAllocatedPower;
  final String? timestamp;
  final String? validUntil;

  Rack({
    required this.id,
    this.rackClass,
    this.height,
    this.width,
    this.depth,
    this.maxVoltage,
    this.maxAllocatedPower,
    this.timestamp,
    this.validUntil,
  }) {
    if (id.trim().isEmpty) {
      throw const RackClassError('id must not be empty');
    }
    if (rackClass != null && !_validRackClasses.contains(rackClass)) {
      throw RackClassError(
        'invalid rack-class: "$rackClass", must be one of: ${_validRackClasses.join(", ")}',
      );
    }
  }

  bool isValid() => id.trim().isNotEmpty;

  bool isExpired(DateTime now) {
    if (validUntil == null) return false;
    try {
      final expiry = DateTime.parse(validUntil!);
      return !expiry.isAfter(now);
    } on FormatException {
      return false;
    }
  }

  Rack copyWith({
    String? id,
    String? rackClass,
    int? height,
    int? width,
    int? depth,
    int? maxVoltage,
    int? maxAllocatedPower,
    String? timestamp,
    String? validUntil,
  }) {
    return Rack(
      id: id ?? this.id,
      rackClass: rackClass ?? this.rackClass,
      height: height ?? this.height,
      width: width ?? this.width,
      depth: depth ?? this.depth,
      maxVoltage: maxVoltage ?? this.maxVoltage,
      maxAllocatedPower: maxAllocatedPower ?? this.maxAllocatedPower,
      timestamp: timestamp ?? this.timestamp,
      validUntil: validUntil ?? this.validUntil,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (rackClass != null) 'rack_class': rackClass,
        if (height != null) 'height': height,
        if (width != null) 'width': width,
        if (depth != null) 'depth': depth,
        if (maxVoltage != null) 'max_voltage': maxVoltage,
        if (maxAllocatedPower != null) 'max_allocated_power': maxAllocatedPower,
        if (timestamp != null) 'timestamp': timestamp,
        if (validUntil != null) 'valid_until': validUntil,
      };

  factory Rack.fromJson(Map<String, dynamic> json) {
    return Rack(
      id: json['id'] as String,
      rackClass: json['rack_class'] as String?,
      height: json['height'] as int?,
      width: json['width'] as int?,
      depth: json['depth'] as int?,
      maxVoltage: json['max_voltage'] as int?,
      maxAllocatedPower: json['max_allocated_power'] as int?,
      timestamp: json['timestamp'] as String?,
      validUntil: json['valid_until'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rack &&
          other.id == id &&
          other.rackClass == rackClass &&
          other.height == height &&
          other.width == width &&
          other.depth == depth &&
          other.maxVoltage == maxVoltage &&
          other.maxAllocatedPower == maxAllocatedPower &&
          other.timestamp == timestamp &&
          other.validUntil == validUntil;

  @override
  int get hashCode => Object.hash(
        id,
        rackClass,
        height,
        width,
        depth,
        maxVoltage,
        maxAllocatedPower,
        timestamp,
        validUntil,
      );

  @override
  String toString() => 'Rack(id: $id, rackClass: $rackClass)';
}
