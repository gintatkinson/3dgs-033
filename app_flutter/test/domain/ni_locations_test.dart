import 'package:app_flutter/domain/ni_locations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NiLocation', () {
    test('should be valid when all fields are provided', () {
      final loc = NiLocation(
        id: 'Building-A',
        type: 'equipment room',
        parent: 'Site-X',
        timestamp: '2026-01-15T08:30:00Z',
        validUntil: '2030-12-31T23:59:59Z',
        address: '123 Main St, Anytown',
      );

      expect(loc.id, equals('Building-A'));
      expect(loc.type, equals('equipment room'));
      expect(loc.parent, equals('Site-X'));
      expect(loc.timestamp, equals('2026-01-15T08:30:00Z'));
      expect(loc.validUntil, equals('2030-12-31T23:59:59Z'));
      expect(loc.address, equals('123 Main St, Anytown'));
      expect(loc.isValid(), isTrue);
    });

    test('should throw LocationIdError when id is empty', () {
      expect(
        () => NiLocation(id: ''),
        throwsA(isA<LocationIdError>()),
      );
      expect(
        () => NiLocation(id: '  '),
        throwsA(isA<LocationIdError>()),
      );
    });

    test('should support hierarchical reference when parent is set', () {
      final building = NiLocation(
        id: 'Building-A',
        type: 'building',
      );
      final room = NiLocation(
        id: 'Room-101',
        type: 'equipment room',
        parent: 'Building-A',
      );

      expect(building.parent, isNull);
      expect(room.parent, equals('Building-A'));
      expect(room.isValid(), isTrue);
    });

    test('should be expired when validUntil is in the past', () {
      final loc = NiLocation(
        id: 'Site-Expired',
        validUntil: '2020-01-01T00:00:00Z',
      );

      expect(loc.isExpired(DateTime(2026, 8, 2)), isTrue);
    });

    test('should not be expired when validUntil is in the future', () {
      final loc = NiLocation(
        id: 'Site-Valid',
        validUntil: '2030-12-31T23:59:59Z',
      );

      expect(loc.isExpired(DateTime(2026, 8, 2)), isFalse);
    });

    test('should not be expired when validUntil is null', () {
      final loc = NiLocation(id: 'Site-NoExpiry');

      expect(loc.isExpired(DateTime(2026, 8, 2)), isFalse);
    });

    test('should accept ISO 8601 format when timestamp is valid', () {
      final loc = NiLocation(
        id: 'Site-TS',
        timestamp: '2026-01-15T08:30:00Z',
      );

      expect(loc.timestamp, equals('2026-01-15T08:30:00Z'));
    });

    test('should preserve all fields when roundtripping to JSON', () {
      final loc = NiLocation(
        id: 'Foo-Enterprise-Campus',
        type: 'site',
        parent: null,
        timestamp: '2026-01-15T08:30:00Z',
        validUntil: '2030-12-31T23:59:59Z',
        address: '1 Enterprise Way',
      );

      final json = loc.toJson();
      final restored = NiLocation.fromJson(json);

      expect(restored.id, equals(loc.id));
      expect(restored.type, equals(loc.type));
      expect(restored.parent, equals(loc.parent));
      expect(restored.timestamp, equals(loc.timestamp));
      expect(restored.validUntil, equals(loc.validUntil));
      expect(restored.address, equals(loc.address));
    });

    test('should be equal when all fields are identical', () {
      final a = NiLocation(id: 'Site-A', timestamp: '2026-01-15T08:30:00Z');
      final b = NiLocation(id: 'Site-A', timestamp: '2026-01-15T08:30:00Z');
      final c = NiLocation(id: 'Site-B');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
