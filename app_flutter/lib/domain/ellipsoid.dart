import 'package:app_flutter/domain/annotations.dart';
import 'package:app_flutter/domain/location_coordinate.dart';
import 'package:meta/meta.dart';

/// Thrown when a latitude value falls outside the allowed range [-90.0, 90.0].
@immutable
class LatitudeRangeError implements Exception {
  final double value;
  const LatitudeRangeError(this.value);

  @override
  String toString() => 'LatitudeRangeError: must be -90.0 to 90.0, got $value';
}

/// Thrown when a longitude value falls outside the allowed range [-180.0, 180.0].
@immutable
class LongitudeRangeError implements Exception {
  final double value;
  const LongitudeRangeError(this.value);

  @override
  String toString() => 'LongitudeRangeError: must be -180.0 to 180.0, got $value';
}

/// Represents an ellipsoid (WGS 84) coordinate as defined in UML::Ellipsoid.
///
/// [latitude] must be in [-90.0, 90.0].
/// [longitude] must be in [-180.0, 180.0].
/// [height] is optional elevation in meters.
@immutable
@realizes(r'UML::Ellipsoid')
class EllipsoidCoordinate extends LocationCoordinate {
  final double latitude;
  final double longitude;
  final double? height;

  EllipsoidCoordinate({
    required this.latitude,
    required this.longitude,
    this.height,
  }) {
    if (latitude < -90.0 || latitude > 90.0) {
      throw LatitudeRangeError(latitude);
    }
    if (longitude < -180.0 || longitude > 180.0) {
      throw LongitudeRangeError(longitude);
    }
  }

  @override
  LocationCoordinateType get type => LocationCoordinateType.ellipsoid;

  bool isValid() {
    return latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (height != null) 'height': height,
    };
  }

  factory EllipsoidCoordinate.fromJson(Map<String, dynamic> json) {
    return EllipsoidCoordinate(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      height: json['height'] as double?,
    );
  }
}
