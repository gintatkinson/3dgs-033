import 'package:app_flutter/domain/ellipsoid.dart';
import 'package:app_flutter/domain/location_coordinate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EllipsoidCoordinate', () {
    test('constructs with valid lat/lon and no height', () {
      final coord = EllipsoidCoordinate(latitude: 40.73297, longitude: -74.007696);
      expect(coord.latitude, equals(40.73297));
      expect(coord.longitude, equals(-74.007696));
      expect(coord.height, isNull);
    });

    test('constructs with valid lat/lon/height', () {
      final coord = EllipsoidCoordinate(
        latitude: 48.8583424,
        longitude: 2.3375084,
        height: 35.0,
      );
      expect(coord.latitude, equals(48.8583424));
      expect(coord.longitude, equals(2.3375084));
      expect(coord.height, equals(35.0));
    });

    test('throws CoordinateValidationException when latitude > 90', () {
      expect(
        () => EllipsoidCoordinate(latitude: 91.0, longitude: 0.0),
        throwsA(isA<CoordinateValidationException>()),
      );
    });

    test('throws CoordinateValidationException when latitude < -90', () {
      expect(
        () => EllipsoidCoordinate(latitude: -90.1, longitude: 0.0),
        throwsA(isA<CoordinateValidationException>()),
      );
    });

    test('throws CoordinateValidationException when longitude > 180', () {
      expect(
        () => EllipsoidCoordinate(latitude: 0.0, longitude: 180.1),
        throwsA(isA<CoordinateValidationException>()),
      );
    });

    test('throws CoordinateValidationException when longitude < -180', () {
      expect(
        () => EllipsoidCoordinate(latitude: 0.0, longitude: -180.1),
        throwsA(isA<CoordinateValidationException>()),
      );
    });

    test('allows null height', () {
      final coord = EllipsoidCoordinate(latitude: 0.0, longitude: 0.0);
      expect(coord.height, isNull);
      expect(coord.isValid(), isTrue);
    });

    test('allows zero and positive height', () {
      final coordZero = EllipsoidCoordinate(latitude: 0.0, longitude: 0.0, height: 0.0);
      expect(coordZero.height, equals(0.0));
      final coordPos = EllipsoidCoordinate(latitude: 0.0, longitude: 0.0, height: 8848.0);
      expect(coordPos.height, equals(8848.0));
    });

    test('type returns LocationCoordinateType.ellipsoid', () {
      final coord = EllipsoidCoordinate(latitude: 0.0, longitude: 0.0);
      expect(coord.type, equals(LocationCoordinateType.ellipsoid));
    });

    test('JSON roundtrip preserves all fields', () {
      final coord = EllipsoidCoordinate(
        latitude: 40.73297,
        longitude: -74.007696,
        height: 35.0,
      );
      final json = coord.toJson();
      expect(json['latitude'], equals(40.73297));
      expect(json['longitude'], equals(-74.007696));
      expect(json['height'], equals(35.0));

      final restored = EllipsoidCoordinate.fromJson(json);
      expect(restored.latitude, equals(coord.latitude));
      expect(restored.longitude, equals(coord.longitude));
      expect(restored.height, equals(coord.height));
      expect(restored.type, equals(coord.type));
    });
  });
}
