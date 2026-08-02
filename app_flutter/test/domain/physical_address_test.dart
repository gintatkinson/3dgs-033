import 'package:app_flutter/domain/physical_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhysicalAddress', () {
    test('should be valid when all fields of a US address are provided', () {
      final pa = PhysicalAddress(
        address: '1600 Amphitheatre Parkway',
        postalCode: '94043',
        state: 'CA',
        city: 'Mountain View',
        countryCode: 'US',
      );
      expect(pa.address, equals('1600 Amphitheatre Parkway'));
      expect(pa.postalCode, equals('94043'));
      expect(pa.state, equals('CA'));
      expect(pa.city, equals('Mountain View'));
      expect(pa.countryCode, equals('US'));
      expect(pa.isValid(), isTrue);
    });

    test('should be invalid when country code is "US1"', () {
      final pa = PhysicalAddress(
        countryCode: 'US1',
      );
      expect(pa.isValid(), isFalse);
    });

    test('should be invalid when all fields are null', () {
      final pa = PhysicalAddress();
      expect(pa.address, isNull);
      expect(pa.postalCode, isNull);
      expect(pa.state, isNull);
      expect(pa.city, isNull);
      expect(pa.countryCode, isNull);
      expect(pa.isValid(), isFalse);
    });

    test('should format full address when all fields are set', () {
      final pa = PhysicalAddress(
        address: '123 Foo Street, Floor 2 East Corridor',
        postalCode: '12345',
        state: 'Foo-State',
        city: 'Foo-City',
        countryCode: 'ZZ',
      );
      final formatted = pa.formatted();
      expect(
        formatted,
        equals(
          '123 Foo Street, Floor 2 East Corridor, 12345 Foo-City, Foo-State, ZZ',
        ),
      );
    });

    test('should be valid when only city is set', () {
      final pa = PhysicalAddress(city: 'Paris');
      expect(pa.address, isNull);
      expect(pa.postalCode, isNull);
      expect(pa.state, isNull);
      expect(pa.city, equals('Paris'));
      expect(pa.countryCode, isNull);
      expect(pa.isValid(), isTrue);
    });

    test('should preserve all fields when roundtripping to JSON', () {
      final original = PhysicalAddress(
        address: '123 Foo Street',
        postalCode: '54321',
        state: 'Bar-State',
        city: 'Bar-City',
        countryCode: 'FR',
      );
      final json = original.toJson();
      final restored = PhysicalAddress.fromJson(json);
      expect(restored.address, equals(original.address));
      expect(restored.postalCode, equals(original.postalCode));
      expect(restored.state, equals(original.state));
      expect(restored.city, equals(original.city));
      expect(restored.countryCode, equals(original.countryCode));
      expect(restored.isValid(), isTrue);
    });
  });

  group('CountryCodeFormatError', () {
    test('should store descriptive message', () {
      const ex = CountryCodeFormatError('test error');
      expect(ex.message, equals('test error'));
      expect(ex.toString(), contains('CountryCodeFormatError'));
    });
  });
}
