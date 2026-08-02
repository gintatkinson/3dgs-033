class RackValidationException implements Exception {
  final String message;

  const RackValidationException(this.message);

  @override
  String toString() => 'RackValidationException: $message';
}

const _validRackClasses = {
  'rack-standard',
  'rack-secure-baseline',
  'rack-secure-medium',
  'rack-secure-high',
};

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
      throw const RackValidationException('id must not be empty');
    }
    if (rackClass != null && !_validRackClasses.contains(rackClass)) {
      throw RackValidationException(
        'invalid rack-class: "$rackClass", must be one of: ${_validRackClasses.join(", ")}',
      );
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
