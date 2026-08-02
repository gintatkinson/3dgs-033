class GeodeticSystemValidationException implements Exception {
  final String message;

  const GeodeticSystemValidationException(this.message);

  @override
  String toString() => 'GeodeticSystemValidationException: $message';
}

class GeodeticSystem {
  static const String defaultGeodeticDatum = 'wgs-84';

  static final _pattern = RegExp(r'^[\x20-\x40\x5b-\x7e]*$');

  final String geodeticDatum;
  final double? coordAccuracy;
  final double? heightAccuracy;

  GeodeticSystem({
    String? geodeticDatum,
    this.coordAccuracy,
    this.heightAccuracy,
  }) : geodeticDatum = _normalize(geodeticDatum ?? defaultGeodeticDatum) {
    _validateAccuracy(coordAccuracy, 'coord-accuracy');
    _validateAccuracy(heightAccuracy, 'height-accuracy');
  }

  static String _normalize(String value) {
    final normalized = value.toLowerCase().replaceAll(' ', '-');
    if (!_pattern.hasMatch(normalized)) {
      throw GeodeticSystemValidationException(
        'Invalid geodetic-datum: "$value" contains invalid characters',
      );
    }
    return normalized;
  }

  static void _validateAccuracy(double? value, String fieldName) {
    if (value == null) return;
    if (value.isNaN || value.isInfinite) {
      throw GeodeticSystemValidationException(
        '$fieldName must be a finite number',
      );
    }
    final scaled = value * 1000000;
    final diff = (scaled - scaled.round()).abs();
    if (diff > 1e-9) {
      throw GeodeticSystemValidationException(
        '$fieldName exceeds 6 fraction-digit precision',
      );
    }
  }

  GeodeticSystem copyWith({
    String? geodeticDatum,
    double? coordAccuracy,
    double? heightAccuracy,
  }) {
    return GeodeticSystem(
      geodeticDatum: geodeticDatum ?? this.geodeticDatum,
      coordAccuracy: coordAccuracy ?? this.coordAccuracy,
      heightAccuracy: heightAccuracy ?? this.heightAccuracy,
    );
  }

  Map<String, dynamic> toJson() => {
        'geodetic-datum': geodeticDatum,
        if (coordAccuracy != null) 'coord-accuracy': coordAccuracy,
        if (heightAccuracy != null) 'height-accuracy': heightAccuracy,
      };

  factory GeodeticSystem.fromJson(Map<String, dynamic> json) {
    return GeodeticSystem(
      geodeticDatum: json['geodetic-datum'] as String?,
      coordAccuracy: json['coord-accuracy'] as double?,
      heightAccuracy: json['height-accuracy'] as double?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeodeticSystem &&
          other.geodeticDatum == geodeticDatum &&
          other.coordAccuracy == coordAccuracy &&
          other.heightAccuracy == heightAccuracy;

  @override
  int get hashCode => Object.hash(geodeticDatum, coordAccuracy, heightAccuracy);
}
