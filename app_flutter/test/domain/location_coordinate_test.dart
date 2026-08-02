import 'package:app_flutter/domain/location_coordinate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationCoordinateType', () {
    test('enum has ellipsoid and cartesian values', () {
      expect(LocationCoordinateType.values.length, equals(2));
      expect(LocationCoordinateType.values[0], equals(LocationCoordinateType.ellipsoid));
      expect(LocationCoordinateType.values[1], equals(LocationCoordinateType.cartesian));
    });

    test('ellipsoid enum toString returns LocationCoordinateType.ellipsoid', () {
      expect(LocationCoordinateType.ellipsoid.toString(),
          equals('LocationCoordinateType.ellipsoid'));
    });

    test('cartesian enum toString returns LocationCoordinateType.cartesian', () {
      expect(LocationCoordinateType.cartesian.toString(),
          equals('LocationCoordinateType.cartesian'));
    });
  });

  group('LocationCoordinate static helpers', () {
    test('detectType returns ellipsoid for JSON with latitude', () {
      final result = LocationCoordinate.detectType({'latitude': 40.73});
      expect(result, equals(LocationCoordinateType.ellipsoid));
    });

    test('detectType returns cartesian for JSON with x/y/z', () {
      final result = LocationCoordinate.detectType({
        'x': 1335832.5,
        'y': -4652426.0,
        'z': 4138321.5,
      });
      expect(result, equals(LocationCoordinateType.cartesian));
    });

    test('detectType returns null for empty JSON', () {
      final result = LocationCoordinate.detectType({});
      expect(result, isNull);
    });

    test('detectType returns null for JSON with unrelated keys', () {
      final result = LocationCoordinate.detectType({'astronomical-body': 'earth'});
      expect(result, isNull);
    });

    test('isEllipsoid returns true for ellipsoid JSON', () {
      expect(LocationCoordinate.isEllipsoid({'latitude': 40.73}), isTrue);
    });

    test('isCartesian returns true for cartesian JSON', () {
      expect(LocationCoordinate.isCartesian({'x': 0.0}), isTrue);
    });

    test('isEllipsoid returns false for empty JSON', () {
      expect(LocationCoordinate.isEllipsoid({}), isFalse);
    });

    test('isCartesian returns false for empty JSON', () {
      expect(LocationCoordinate.isCartesian({}), isFalse);
    });
  });
}
