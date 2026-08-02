import 'package:app_flutter/domain/ellipsoid.dart';
import 'package:app_flutter/domain/location_coordinate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EllipsoidCoordinate', () {
    test('should construct with valid lat/lon when height is null', () {
      final coord = EllipsoidCoordinate(latitude: 40.73297, longitude: -74.007696);
      expect(coord.latitude, equals(40.73297));
      expect(coord.longitude, equals(-74.007696));
      expect(coord.height, isNull);
    });

    test('should construct with valid lat/lon/height when all fields provided', () {
      final coord = EllipsoidCoordinate(
        latitude: 48.8583424,
        longitude: 2.3375084,
        height: 35.0,
      );
      expect(coord.latitude, equals(48.8583424));
      expect(coord.longitude, equals(2.3375084));
      expect(coord.height, equals(35.0));
    });

    test('should throw LatitudeRangeError when latitude exceeds 90', () {
      expect(
        () => EllipsoidCoordinate(latitude: 91.0, longitude: 0.0),
        throwsA(isA<LatitudeRangeError>()),
      );
    });

    test('should throw LatitudeRangeError when latitude is below -90', () {
      expect(
        () => EllipsoidCoordinate(latitude: -90.1, longitude: 0.0),
        throwsA(isA<LatitudeRangeError>()),
      );
    });

    test('should throw LongitudeRangeError when longitude exceeds 180', () {
      expect(
        () => EllipsoidCoordinate(latitude: 0.0, longitude: 180.1),
        throwsA(isA<LongitudeRangeError>()),
      );
    });

    test('should throw LongitudeRangeError when longitude is below -180', () {
      expect(
        () => EllipsoidCoordinate(latitude: 0.0, longitude: -180.1),
        throwsA(isA<LongitudeRangeError>()),
      );
    });

    test('should allow null height when coordinate is 2D', () {
      final coord = EllipsoidCoordinate(latitude: 0.0, longitude: 0.0);
      expect(coord.height, isNull);
      expect(coord.isValid(), isTrue);
    });

    test('should allow zero and positive height values', () {
      final coordZero = EllipsoidCoordinate(latitude: 0.0, longitude: 0.0, height: 0.0);
      expect(coordZero.height, equals(0.0));
      final coordPos = EllipsoidCoordinate(latitude: 0.0, longitude: 0.0, height: 8848.0);
      expect(coordPos.height, equals(8848.0));
    });

    test('should return ellipsoid when checking coordinate type', () {
      final coord = EllipsoidCoordinate(latitude: 0.0, longitude: 0.0);
      expect(coord.type, equals(LocationCoordinateType.ellipsoid));
    });

    test('should preserve all fields when roundtripping to JSON', () {
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
