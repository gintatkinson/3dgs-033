import 'package:app_flutter/domain/geo_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeoLocation', () {
    test('valid GeoLocation with all fields', () {
      final gl = GeoLocation(
        timestamp: '2012-03-31T16:00:00Z',
        validUntil: '2026-12-31T23:59:59Z',
        astronomicalBody: 'mars',
        geodeticDatum: 'mars-2000',
      );
      expect(gl.timestamp, equals('2012-03-31T16:00:00Z'));
      expect(gl.validUntil, equals('2026-12-31T23:59:59Z'));
      expect(gl.astronomicalBody, equals('mars'));
      expect(gl.geodeticDatum, equals('mars-2000'));
      expect(gl.isValid(), isTrue);
    });

    test('valid GeoLocation with defaults only (earth, wgs-84)', () {
      final gl = GeoLocation();
      expect(gl.timestamp, isNull);
      expect(gl.validUntil, isNull);
      expect(gl.astronomicalBody, equals('earth'));
      expect(gl.geodeticDatum, equals('wgs-84'));
      expect(gl.isValid(), isTrue);
    });

    test('GeoLocation rejects invalid timestamp format', () {
      final gl = GeoLocation(timestamp: 'invalid-date-string');
      expect(gl.isValid(), isFalse);
    });

    test('GeoLocation rejects invalid valid-until', () {
      final gl = GeoLocation(validUntil: 'not-a-date');
      expect(gl.isValid(), isFalse);
    });

    test('validityWindow computes correctly', () {
      final gl = GeoLocation(
        timestamp: '2025-01-01T00:00:00Z',
        validUntil: '2025-01-02T00:00:00Z',
      );
      final window = gl.validityWindow();
      expect(window, isNotNull);
      expect(window!.inHours, equals(24));
    });

    test('validityWindow returns null when timestamp is missing', () {
      final gl = GeoLocation(validUntil: '2026-12-31T23:59:59Z');
      expect(gl.validityWindow(), isNull);
    });

    test('validityWindow returns null when validUntil is missing', () {
      final gl = GeoLocation(timestamp: '2012-03-31T16:00:00Z');
      expect(gl.validityWindow(), isNull);
    });

    test('isExpired returns true when valid-until is past', () {
      final gl = GeoLocation(validUntil: '2020-01-01T00:00:00Z');
      expect(gl.isExpired(DateTime(2025, 6, 1)), isTrue);
    });

    test('isExpired returns false when valid-until is future', () {
      final gl = GeoLocation(validUntil: '2030-01-01T00:00:00Z');
      expect(gl.isExpired(DateTime(2025, 6, 1)), isFalse);
    });

    test('GeoLocation with no valid-until is never expired', () {
      final gl = GeoLocation();
      expect(gl.isExpired(DateTime(2025, 6, 1)), isFalse);
      expect(gl.isExpired(DateTime(2099, 12, 31)), isFalse);
    });

    test('toString JSON roundtrip', () {
      final original = GeoLocation(
        timestamp: '2012-03-31T16:00:00Z',
        validUntil: '2026-12-31T23:59:59Z',
        astronomicalBody: 'earth',
        geodeticDatum: 'wgs-84',
      );
      final json = original.toJson();
      final restored = GeoLocation.fromJson(json);
      expect(restored.timestamp, equals(original.timestamp));
      expect(restored.validUntil, equals(original.validUntil));
      expect(restored.astronomicalBody, equals(original.astronomicalBody));
      expect(restored.geodeticDatum, equals(original.geodeticDatum));
    });

    group('GeoLocationValidationException', () {
      test('has message property', () {
        const ex = GeoLocationValidationException('test error');
        expect(ex.message, equals('test error'));
        expect(ex.toString(), contains('GeoLocationValidationException'));
      });
    });
  });
}
