import 'dart:math' as math;

import 'package:app_flutter/domain/velocity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Velocity', () {
    test('should construct valid vector when all components are provided', () {
      final v = Velocity(vNorth: 3.0, vEast: 4.0, vUp: 0.1);
      expect(v.vNorth, equals(3.0));
      expect(v.vEast, equals(4.0));
      expect(v.vUp, equals(0.1));
    });

    test('should default to zero when no components are provided', () {
      final v = Velocity();
      expect(v.vNorth, equals(0.0));
      expect(v.vEast, equals(0.0));
      expect(v.vUp, equals(0.0));
    });

    test('should compute 2D horizontal magnitude when speed is requested', () {
      final v = Velocity(vNorth: 3.0, vEast: 4.0);
      expect(v.speed(), closeTo(5.0, 1e-12));
    });

    test('should return zero speed when vector is zero', () {
      final v = Velocity();
      expect(v.speed(), equals(0.0));
    });

    test('should compute angle clockwise from true north when heading is requested', () {
      final north = Velocity(vNorth: 1.0, vEast: 0.0);
      final east = Velocity(vNorth: 0.0, vEast: 1.0);
      final south = Velocity(vNorth: -1.0, vEast: 0.0);
      final west = Velocity(vNorth: 0.0, vEast: -1.0);
      final ne = Velocity(vNorth: 1.0, vEast: 1.0);

      expect(north.heading(), closeTo(0.0, 1e-12));
      expect(east.heading(), closeTo(90.0, 1e-12));
      expect(south.heading(), closeTo(180.0, 1e-12));
      expect(west.heading(), closeTo(270.0, 1e-12));
      expect(ne.heading(), closeTo(45.0, 1e-12));
    });

    test('should return zero heading when vector is stationary', () {
      final v = Velocity();
      expect(v.heading(), equals(0.0));
    });

    test('should compute 3D magnitude when speed3D is requested', () {
      final v = Velocity(vNorth: 3.0, vEast: 4.0, vUp: 12.0);
      expect(v.speed3D(), closeTo(13.0, 1e-12));
    });

    test('should return zero speed3D when vector is zero', () {
      final v = Velocity();
      expect(v.speed3D(), equals(0.0));
    });

    test('should be stationary when all components are zero', () {
      expect(Velocity().isStationary, isTrue);
      expect(Velocity(vNorth: 0.0).isStationary, isTrue);
      expect(Velocity(vNorth: 1.0).isStationary, isFalse);
      expect(Velocity(vEast: 0.001).isStationary, isFalse);
      expect(Velocity(vUp: -0.001).isStationary, isFalse);
    });

    test('should replace specified components when copyWith is called', () {
      final original = Velocity(vNorth: 1.0, vEast: 2.0, vUp: 3.0);
      final updated = original.copyWith(vNorth: 10.0, vUp: 30.0);
      expect(updated.vNorth, equals(10.0));
      expect(updated.vEast, equals(2.0));
      expect(updated.vUp, equals(30.0));
    });

    test('should preserve unchanged components when copyWith has no args', () {
      final original = Velocity(vNorth: 1.0, vEast: 2.0, vUp: 3.0);
      final unchanged = original.copyWith();
      expect(unchanged.vNorth, equals(1.0));
      expect(unchanged.vEast, equals(2.0));
      expect(unchanged.vUp, equals(3.0));
    });

    test('should preserve all fields when roundtripping to JSON', () {
      final v = Velocity(vNorth: 0.5, vEast: -1.25, vUp: 0.001);
      final json = v.toJson();
      expect(json['v-north'], equals(0.5));
      expect(json['v-east'], equals(-1.25));
      expect(json['v-up'], equals(0.001));

      final restored = Velocity.fromJson(json);
      expect(restored.vNorth, equals(v.vNorth));
      expect(restored.vEast, equals(v.vEast));
      expect(restored.vUp, equals(v.vUp));
    });

    test('should preserve 12-digit precision when roundtripping to JSON', () {
      final v = Velocity(vNorth: 0.123456789012, vEast: -0.987654321098, vUp: 0.0);
      final json = v.toJson();
      final restored = Velocity.fromJson(json);
      expect(restored.vNorth, closeTo(v.vNorth, 1e-15));
      expect(restored.vEast, closeTo(v.vEast, 1e-15));
      expect(restored.vUp, closeTo(v.vUp, 1e-15));
    });

    test('should include component values when converting to string', () {
      final v = Velocity(vNorth: 1.0, vEast: 2.0, vUp: 3.0);
      final s = v.toString();
      expect(s, contains('1.0'));
      expect(s, contains('2.0'));
      expect(s, contains('3.0'));
    });

    test('should be equal when component values are identical', () {
      final a = Velocity(vNorth: 1.0, vEast: 2.0, vUp: 3.0);
      final b = Velocity(vNorth: 1.0, vEast: 2.0, vUp: 3.0);
      final c = Velocity(vNorth: 1.0, vEast: 2.0, vUp: 3.001);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('VelocityComponentError', () {
    test('should store descriptive message', () {
      final ex = VelocityComponentError('test error message');
      expect(ex.message, equals('test error message'));
    });

    test('should include message when converted to string', () {
      final ex = VelocityComponentError('test error message');
      expect(ex.toString(), contains('test error message'));
    });
  });
}
