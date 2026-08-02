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

    /// @traces US-10
    /// @traces US-10
    test('should be expired at boundary instant when valid-until equals current time',
        () {
      final gl = GeoLocation(validUntil: '2025-06-01T12:00:00Z');
      expect(gl.isExpired(DateTime.utc(2025, 6, 1, 12, 0, 0)), isTrue);
    });

    /// @traces US-10
    test('should not be expired at boundary minus one second', () {
      final gl = GeoLocation(validUntil: '2025-06-01T12:00:00Z');
      expect(
        gl.isExpired(DateTime.utc(2025, 6, 1, 11, 59, 59)),
        isFalse,
      );
    });

    /// @traces US-10
    test('should allow revalidation when valid-until is extended to future', () {
      final gl = GeoLocation(validUntil: '2020-01-01T00:00:00Z');
      expect(gl.isExpired(DateTime(2025, 6, 1)), isTrue);
      final revalidated = GeoLocation(
        validUntil: '2030-01-01T00:00:00Z',
      );
      expect(revalidated.isExpired(DateTime(2025, 6, 1)), isFalse);
    });

    /// @traces US-10
    test('should have readable data when expired for forensic access', () {
      final gl = GeoLocation(
        timestamp: '2012-03-31T16:00:00Z',
        validUntil: '2020-01-01T00:00:00Z',
        astronomicalBody: 'earth',
        geodeticDatum: 'wgs-84',
      );
      expect(gl.isExpired(DateTime(2025, 6, 1)), isTrue);
      expect(gl.timestamp, equals('2012-03-31T16:00:00Z'));
      expect(gl.astronomicalBody, equals('earth'));
      expect(gl.geodeticDatum, equals('wgs-84'));
    });

    /// @traces US-15
    test(
        'should compute negative-duration window when valid-until is before timestamp',
        () {
      final gl = GeoLocation(
        timestamp: '2026-06-01T12:00:00Z',
        validUntil: '2026-01-01T00:00:00Z',
      );
      final window = gl.validityWindow();
      expect(window, isNotNull);
      expect(window!.inHours, lessThan(0));
    });

    /// @traces US-15
    test('should compute zero-duration window when timestamp equals valid-until', () {
      final gl = GeoLocation(
        timestamp: '2026-06-01T12:00:00Z',
        validUntil: '2026-06-01T12:00:00Z',
      );
      final window = gl.validityWindow();
      expect(window, isNotNull);
      expect(window!.inSeconds, equals(0));
    });

    /// @traces US-15
    test('should handle timezone-aware date-comparison for expiry', () {
      final gl = GeoLocation(validUntil: '2026-06-01T07:00:00+05:00');
      final utcEq = DateTime.utc(2026, 6, 1, 2, 0, 0);
      expect(gl.isExpired(utcEq), isTrue);
      final utcBefore = DateTime.utc(2026, 6, 1, 1, 59, 59);
      expect(gl.isExpired(utcBefore), isFalse);
    });

  group('GeoLocationExpiryError', () {
    test('should store descriptive message', () {
      const ex = GeoLocationExpiryError('test error');
      expect(ex.message, equals('test error'));
      expect(ex.toString(), contains('GeoLocationExpiryError'));
    });
  });
}
