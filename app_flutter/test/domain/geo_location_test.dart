import 'package:app_flutter/domain/geo_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeoLocation', () {
    test('should be valid when all fields including timestamp are provided', () {
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

    test('should be valid with defaults when only body and datum are specified', () {
      final gl = GeoLocation();
      expect(gl.timestamp, isNull);
      expect(gl.validUntil, isNull);
      expect(gl.astronomicalBody, equals('earth'));
      expect(gl.geodeticDatum, equals('wgs-84'));
      expect(gl.isValid(), isTrue);
    });

    test('should be invalid when timestamp format is incorrect', () {
      final gl = GeoLocation(timestamp: 'invalid-date-string');
      expect(gl.isValid(), isFalse);
    });

    test('should be invalid when valid-until format is incorrect', () {
      final gl = GeoLocation(validUntil: 'not-a-date');
      expect(gl.isValid(), isFalse);
    });

    test('should compute 24-hour window when timestamps differ by one day', () {
      final gl = GeoLocation(
        timestamp: '2025-01-01T00:00:00Z',
        validUntil: '2025-01-02T00:00:00Z',
      );
      final window = gl.validityWindow();
      expect(window, isNotNull);
      expect(window!.inHours, equals(24));
    });

    test('should return null validity window when timestamp is missing', () {
      final gl = GeoLocation(validUntil: '2026-12-31T23:59:59Z');
      expect(gl.validityWindow(), isNull);
    });

    test('should return null validity window when validUntil is missing', () {
      final gl = GeoLocation(timestamp: '2012-03-31T16:00:00Z');
      expect(gl.validityWindow(), isNull);
    });

    test('should be expired when valid-until is in the past', () {
      final gl = GeoLocation(validUntil: '2020-01-01T00:00:00Z');
      expect(gl.isExpired(DateTime(2025, 6, 1)), isTrue);
    });

    test('should not be expired when valid-until is in the future', () {
      final gl = GeoLocation(validUntil: '2030-01-01T00:00:00Z');
      expect(gl.isExpired(DateTime(2025, 6, 1)), isFalse);
    });

    test('should never be expired when valid-until is null', () {
      final gl = GeoLocation();
      expect(gl.isExpired(DateTime(2025, 6, 1)), isFalse);
      expect(gl.isExpired(DateTime(2099, 12, 31)), isFalse);
    });

    test('should preserve all fields when roundtripping to JSON', () {
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
  });

  group('GeoLocationTimestampError', () {
    test('should store descriptive message', () {
      const ex = GeoLocationTimestampError('test error');
      expect(ex.message, equals('test error'));
      expect(ex.toString(), contains('GeoLocationTimestampError'));
    });
  });

  group('GeoLocationExpiryError', () {
    test('should store descriptive message', () {
      const ex = GeoLocationExpiryError('test error');
      expect(ex.message, equals('test error'));
      expect(ex.toString(), contains('GeoLocationExpiryError'));
    });
  });
}
