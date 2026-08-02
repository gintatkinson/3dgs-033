import 'package:app_flutter/domain/oid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OidValue', () {
    group('parse', () {
      test('parse valid OID "1.3.6.1.2.1.1.1.0" returns 9 sub-identifiers', () {
        final oid = OidValue.parse('1.3.6.1.2.1.1.1.0');
        expect(oid.subIdentifiers.length, equals(9));
        expect(oid.subIdentifiers, orderedEquals([1, 3, 6, 1, 2, 1, 1, 1, 0]));
      });

      test('reject invalid first sub-identifier "3.6.1"', () {
        expect(
          () => OidValue.parse('3.6.1'),
          throwsA(isA<OidValidationException>()),
        );
      });

      test('reject second sub-identifier out of range "0.40.1"', () {
        expect(
          () => OidValue.parse('0.40.1'),
          throwsA(isA<OidValidationException>()),
        );
      });

      test('reject single sub-identifier "1"', () {
        expect(
          () => OidValue.parse('1'),
          throwsA(isA<OidValidationException>()),
        );
      });

      test('reject sub-identifier overflow (value > 4294967295)', () {
        expect(
          () => OidValue.parse('1.3.4294967296'),
          throwsA(isA<OidValidationException>()),
        );
      });

      test('reject whitespace in OID "1.3. 6.1"', () {
        expect(
          () => OidValue.parse('1.3. 6.1'),
          throwsA(isA<OidValidationException>()),
        );
      });

      test('reject non-numeric input', () {
        expect(
          () => OidValue.parse('1.abc.3'),
          throwsA(isA<OidValidationException>()),
        );
      });
    });

    group('isAncestorOf', () {
      test('"1.3.6.1" is ancestor of "1.3.6.1.2.1"', () {
        final parent = OidValue.parse('1.3.6.1');
        final child = OidValue.parse('1.3.6.1.2.1');
        expect(parent.isAncestorOf(child), isTrue);
      });

      test('"1.3.6.1.2.1" is NOT ancestor of "1.3.6.1"', () {
        final child = OidValue.parse('1.3.6.1.2.1');
        final parent = OidValue.parse('1.3.6.1');
        expect(child.isAncestorOf(parent), isFalse);
      });

      test('equal OIDs are not ancestors of each other', () {
        final a = OidValue.parse('1.3.6.1');
        final b = OidValue.parse('1.3.6.1');
        expect(a.isAncestorOf(b), isFalse);
        expect(b.isAncestorOf(a), isFalse);
      });

      test('unrelated OIDs are not ancestors', () {
        final a = OidValue.parse('1.3.6.1');
        final b = OidValue.parse('2.16.840.1');
        expect(a.isAncestorOf(b), isFalse);
        expect(b.isAncestorOf(a), isFalse);
      });
    });

    group('toString', () {
      test('roundtrip toString() equals original parsed string', () {
        const original = '1.3.6.1.2.1.1.1.0';
        final oid = OidValue.parse(original);
        expect(oid.toString(), equals(original));
      });
    });

    group('constructor validation', () {
      test('valid sub-identifiers construct without error', () {
        final oid = OidValue(const [1, 3, 6, 1]);
        expect(oid.subIdentifiers, orderedEquals([1, 3, 6, 1]));
      });

      test('constructor rejects invalid first sub-identifier', () {
        expect(
          () => OidValue(const [3, 6, 1]),
          throwsA(isA<OidValidationException>()),
        );
      });

      test('constructor rejects second sub-id out of range when first is 1', () {
        expect(
          () => OidValue(const [1, 40, 1]),
          throwsA(isA<OidValidationException>()),
        );
      });

      test('constructor rejects single sub-identifier', () {
        expect(
          () => OidValue(const [1]),
          throwsA(isA<OidValidationException>()),
        );
      });

      test('constructor rejects sub-id exceeding 2^32-1', () {
        expect(
          () => OidValue(const [1, 3, 4294967296]),
          throwsA(isA<OidValidationException>()),
        );
      });
    });
  });

  group('Oid128', () {
    test('parse valid 128-sub-identifier OID', () {
      final parts = List<int>.generate(128, (i) => i == 0 ? 1 : (i == 1 ? 3 : i));
      final oidStr = parts.join('.');
      final oid = Oid128.parse(oidStr);
      expect(oid.subIdentifiers.length, equals(128));
    });

    test('reject OID with 129 sub-identifiers', () {
      final parts = List<int>.generate(129, (i) => i == 0 ? 1 : (i == 1 ? 3 : i));
      final oidStr = parts.join('.');
      expect(
        () => Oid128.parse(oidStr),
        throwsA(isA<OidValidationException>()),
      );
    });
  });
}
