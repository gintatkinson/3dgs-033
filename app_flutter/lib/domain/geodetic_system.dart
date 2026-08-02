import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Thrown when a geodetic datum name contains invalid characters.
@immutable
class GeodeticDatumError implements Exception {
  final String value;
  const GeodeticDatumError(this.value);

  @override
  String toString() => 'GeodeticDatumError: invalid geodetic-datum: "$value"';
}

/// Thrown when an accuracy value exceeds the allowed 6 fraction-digit precision.
@immutable
class AccuracyRangeError implements Exception {
  final String fieldName;
  const AccuracyRangeError(this.fieldName);

  @override
  String toString() => 'AccuracyRangeError: $fieldName exceeds 6 fraction-digit precision';
}

/// Represents a geodetic system (datum and accuracy) as defined in UML::GeodeticSystem.
///
/// [geodeticDatum] is the reference datum (default: "wgs-84").
/// [coordAccuracy] and [heightAccuracy] are optional values limited to 6 decimal places.
@immutable
@realizes(r'UML::GeodeticSystem')
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
      throw GeodeticDatumError(value);
    }
    return normalized;
  }

  static void _validateAccuracy(double? value, String fieldName) {
    if (value == null) return;
    if (value.isNaN || value.isInfinite) {
      throw AccuracyRangeError(fieldName);
    }
    final scaled = value * 1000000;
    final diff = (scaled - scaled.round()).abs();
    if (diff > 1e-9) {
      throw AccuracyRangeError(fieldName);
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
