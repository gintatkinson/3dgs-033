import 'package:app_flutter/domain/location_coordinate.dart';

class CoordinateValidationException implements Exception {
  final String message;

  const CoordinateValidationException(this.message);

  @override
  String toString() => 'CoordinateValidationException: $message';
}

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
      throw CoordinateValidationException(
        'Latitude must be in range [-90.0, 90.0], got $latitude',
      );
    }
    if (longitude < -180.0 || longitude > 180.0) {
      throw CoordinateValidationException(
        'Longitude must be in range [-180.0, 180.0], got $longitude',
      );
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
