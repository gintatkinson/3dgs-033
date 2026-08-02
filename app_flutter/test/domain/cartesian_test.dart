import 'package:app_flutter/domain/cartesian.dart';
import 'package:app_flutter/domain/location_coordinate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartesianCoordinate', () {
    test('constructs with valid x, y, z coordinates', () {
      final coord = CartesianCoordinate(
        x: 1335832.5,
        y: -4652426.0,
        z: 4138321.5,
      );
      expect(coord.x, equals(1335832.5));
      expect(coord.y, equals(-4652426.0));
      expect(coord.z, equals(4138321.5));
    });

    test('accepts zero values for x, y, z', () {
      final coord = CartesianCoordinate(x: 0.0, y: 0.0, z: 0.0);
      expect(coord.x, equals(0.0));
      expect(coord.y, equals(0.0));
      expect(coord.z, equals(0.0));
    });

    test('accepts negative values', () {
      final coord = CartesianCoordinate(
        x: -1335832.5,
        y: -4652426.0,
        z: -4138321.5,
      );
      expect(coord.x, equals(-1335832.5));
      expect(coord.y, equals(-4652426.0));
      expect(coord.z, equals(-4138321.5));
    });

    test('type returns LocationCoordinateType.cartesian', () {
      final coord = CartesianCoordinate(x: 0.0, y: 0.0, z: 0.0);
      expect(coord.type, equals(LocationCoordinateType.cartesian));
    });

    test('JSON roundtrip preserves all fields', () {
      final coord = CartesianCoordinate(
        x: 1335832.5,
        y: -4652426.0,
        z: 4138321.5,
      );
      final json = coord.toJson();
      expect(json['x'], equals(1335832.5));
      expect(json['y'], equals(-4652426.0));
      expect(json['z'], equals(4138321.5));

      final restored = CartesianCoordinate.fromJson(json);
      expect(restored.x, equals(coord.x));
      expect(restored.y, equals(coord.y));
      expect(restored.z, equals(coord.z));
      expect(restored.type, equals(coord.type));
    });
  });
}
