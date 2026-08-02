import 'package:app_flutter/domain/rack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rack', () {
    test('should be valid when all fields are provided', () {
      final rack = Rack(
        id: 'Rack-101-A',
        rackClass: 'rack-standard',
        height: 2200,
        width: 600,
        depth: 1200,
        maxVoltage: 240,
        maxAllocatedPower: 8000,
        timestamp: '2026-01-15T10:00:00Z',
        validUntil: '2028-01-15T10:00:00Z',
      );

      expect(rack.id, equals('Rack-101-A'));
      expect(rack.rackClass, equals('rack-standard'));
      expect(rack.height, equals(2200));
      expect(rack.width, equals(600));
      expect(rack.depth, equals(1200));
      expect(rack.maxVoltage, equals(240));
      expect(rack.maxAllocatedPower, equals(8000));
      expect(rack.timestamp, equals('2026-01-15T10:00:00Z'));
      expect(rack.validUntil, equals('2028-01-15T10:00:00Z'));
      expect(rack.isValid(), isTrue);
    });

    test('should throw RackClassError when id is empty', () {
      expect(
        () => Rack(id: ''),
        throwsA(isA<RackClassError>()),
      );
      expect(
        () => Rack(id: '  '),
        throwsA(isA<RackClassError>()),
      );
    });

    test('should throw RackClassError when rackClass is invalid', () {
      expect(
        () => Rack(id: 'Rack-1', rackClass: 'invalid-class'),
        throwsA(isA<RackClassError>()),
      );
    });

    test('should accept valid rackClass values when rack class is standard', () {
      for (final cls in [
        'rack-standard',
        'rack-secure-baseline',
        'rack-secure-medium',
        'rack-secure-high',
      ]) {
        final rack = Rack(id: 'Rack-1', rackClass: cls);
        expect(rack.rackClass, equals(cls));
        expect(rack.isValid(), isTrue);
      }
    });

    test('should be expired when validUntil is in the past', () {
      final rack = Rack(
        id: 'Rack-Expired',
        validUntil: '2020-01-01T00:00:00Z',
      );

      expect(rack.isExpired(DateTime(2026, 8, 2)), isTrue);
    });

    test('should not be expired when validUntil is in the future', () {
      final rack = Rack(
        id: 'Rack-Valid',
        validUntil: '2030-12-31T23:59:59Z',
      );

      expect(rack.isExpired(DateTime(2026, 8, 2)), isFalse);
    });

    test('should not be expired when validUntil is null', () {
      final rack = Rack(id: 'Rack-NoExpiry');

      expect(rack.isExpired(DateTime(2026, 8, 2)), isFalse);
    });

    /// @traces US-18
    test('should be expired at exact boundary instant', () {
      final rack = Rack(
        id: 'Rack-Boundary',
        validUntil: '2025-06-01T12:00:00Z',
      );

      expect(
        rack.isExpired(DateTime.utc(2025, 6, 1, 12, 0, 0)),
        isTrue,
      );
    });

    /// @traces US-18
    test('should not be expired one second before boundary', () {
      final rack = Rack(
        id: 'Rack-PreBoundary',
        validUntil: '2025-06-01T12:00:00Z',
      );

      expect(
        rack.isExpired(DateTime.utc(2025, 6, 1, 11, 59, 59)),
        isFalse,
      );
    });

    /// @traces US-18
    test('should allow revalidation by extending validUntil', () {
      final expiredRack = Rack(
        id: 'Rack-Revalidate',
        validUntil: '2020-01-01T00:00:00Z',
      );
      expect(expiredRack.isExpired(DateTime(2025, 6, 1)), isTrue);

      final revalidated = expiredRack.copyWith(
        validUntil: '2030-01-01T00:00:00Z',
      );
      expect(revalidated.isExpired(DateTime(2025, 6, 1)), isFalse);
      expect(revalidated.id, equals('Rack-Revalidate'));
    });

    /// @traces US-25
    test('should be unclassified when rackClass is null', () {
      final rack = Rack(id: 'Rack-Unclassified');
      expect(rack.rackClass, isNull);
      expect(rack.isValid(), isTrue);
    });

    test('should preserve all fields when roundtripping to JSON', () {
      final rack = Rack(
        id: 'Rack-101-A',
        rackClass: 'rack-standard',
        height: 2200,
        width: 600,
        depth: 1200,
        maxVoltage: 240,
        maxAllocatedPower: 8000,
        timestamp: '2026-01-15T10:00:00Z',
        validUntil: '2028-01-15T10:00:00Z',
      );

      final json = rack.toJson();
      final restored = Rack.fromJson(json);

      expect(restored.id, equals(rack.id));
      expect(restored.rackClass, equals(rack.rackClass));
      expect(restored.height, equals(rack.height));
      expect(restored.width, equals(rack.width));
      expect(restored.depth, equals(rack.depth));
      expect(restored.maxVoltage, equals(rack.maxVoltage));
      expect(restored.maxAllocatedPower, equals(rack.maxAllocatedPower));
      expect(restored.timestamp, equals(rack.timestamp));
      expect(restored.validUntil, equals(rack.validUntil));
    });

    test('should preserve null optional fields when roundtripping minimal rack', () {
      final rack = Rack(id: 'Rack-Minimal');

      final json = rack.toJson();
      final restored = Rack.fromJson(json);

      expect(restored.id, equals('Rack-Minimal'));
      expect(restored.rackClass, isNull);
      expect(restored.height, isNull);
      expect(restored.width, isNull);
      expect(restored.depth, isNull);
      expect(restored.maxVoltage, isNull);
      expect(restored.maxAllocatedPower, isNull);
      expect(restored.timestamp, isNull);
      expect(restored.validUntil, isNull);
    });

    test('should be equal when all fields are identical', () {
      final a = Rack(
        id: 'Rack-A',
        height: 2200,
        timestamp: '2026-01-15T10:00:00Z',
      );
      final b = Rack(
        id: 'Rack-A',
        height: 2200,
        timestamp: '2026-01-15T10:00:00Z',
      );
      final c = Rack(id: 'Rack-B');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
