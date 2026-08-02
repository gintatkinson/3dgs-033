import 'package:app_flutter/domain/rack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rack', () {
    test('valid rack with all fields', () {
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

    test('missing id throws RackValidationException', () {
      expect(
        () => Rack(id: ''),
        throwsA(isA<RackValidationException>()),
      );
      expect(
        () => Rack(id: '  '),
        throwsA(isA<RackValidationException>()),
      );
    });

    test('invalid rackClass throws RackValidationException', () {
      expect(
        () => Rack(id: 'Rack-1', rackClass: 'invalid-class'),
        throwsA(isA<RackValidationException>()),
      );
    });

    test('valid rackClass values are accepted', () {
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

    test('isExpired returns true when validUntil is past', () {
      final rack = Rack(
        id: 'Rack-Expired',
        validUntil: '2020-01-01T00:00:00Z',
      );

      expect(rack.isExpired(DateTime(2026, 8, 2)), isTrue);
    });

    test('isExpired returns false when validUntil is in the future', () {
      final rack = Rack(
        id: 'Rack-Valid',
        validUntil: '2030-12-31T23:59:59Z',
      );

      expect(rack.isExpired(DateTime(2026, 8, 2)), isFalse);
    });

    test('isExpired returns false when validUntil is null', () {
      final rack = Rack(id: 'Rack-NoExpiry');

      expect(rack.isExpired(DateTime(2026, 8, 2)), isFalse);
    });

    test('JSON roundtrip preserves all fields', () {
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

    test('JSON roundtrip with null optional fields', () {
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

    test('equality and hashCode', () {
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
