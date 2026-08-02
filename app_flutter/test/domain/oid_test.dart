import 'package:app_flutter/domain/oid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OidValue', () {
    group('parse', () {
      test('should parse valid OID with nine sub identifiers when value is "1.3.6.1.2.1.1.1.0"',
          () {
        final oid = OidValue.parse('1.3.6.1.2.1.1.1.0');
        expect(oid.subIdentifiers.length, equals(9));
        expect(
            oid.subIdentifiers, orderedEquals([1, 3, 6, 1, 2, 1, 1, 1, 0]));
      });

      test('should reject OID when first sub identifier exceeds two', () {
        try {
          OidValue.parse('3.6.1');
          fail('Expected OidFormatError');
        } on OidFormatError catch (e) {
          expect(e.section, equals('first-subid'));
          expect(e.value, equals(3));
        }
      });

      test(
          'should reject OID when second sub identifier exceeds 39 and first sub identifier is zero',
          () {
        try {
          OidValue.parse('0.40.1');
          fail('Expected OidFormatError');
        } on OidFormatError catch (e) {
          expect(e.section, equals('second-subid'));
          expect(e.value, equals(40));
        }
      });

      test('should reject OID when only single sub identifier is provided', () {
        expect(
          () => OidValue.parse('1'),
          throwsA(isA<OidLengthError>()),
        );
      });

      test('should reject OID when sub identifier value exceeds 4294967295',
          () {
        try {
          OidValue.parse('1.3.4294967296');
          fail('Expected OidFormatError');
        } on OidFormatError catch (e) {
          expect(e.section, equals('subid-overflow'));
          expect(e.value, equals(4294967296));
        }
      });

      test('should reject OID when input contains whitespace between sub identifiers',
          () {
        expect(
          () => OidValue.parse('1.3. 6.1'),
          throwsA(isA<OidFormatError>()),
        );
      });

      test('should reject OID when input contains non numeric sub identifier',
          () {
        expect(
          () => OidValue.parse('1.abc.3'),
          throwsA(isA<OidFormatError>()),
        );
      });
    });

    group('isAncestorOf', () {
      test('should return true when parent is "1.3.6.1" and child is "1.3.6.1.2.1"',
          () {
        final parent = OidValue.parse('1.3.6.1');
        final child = OidValue.parse('1.3.6.1.2.1');
        expect(parent.isAncestorOf(child), isTrue);
      });

      test('should return false when child "1.3.6.1.2.1" is longer than "1.3.6.1"',
          () {
        final child = OidValue.parse('1.3.6.1.2.1');
        final parent = OidValue.parse('1.3.6.1');
        expect(child.isAncestorOf(parent), isFalse);
      });

      test('should return false when comparing two equal OIDs', () {
        final a = OidValue.parse('1.3.6.1');
        final b = OidValue.parse('1.3.6.1');
        expect(a.isAncestorOf(b), isFalse);
        expect(b.isAncestorOf(a), isFalse);
      });

      test('should return false when comparing unrelated OIDs', () {
        final a = OidValue.parse('1.3.6.1');
        final b = OidValue.parse('2.16.840.1');
        expect(a.isAncestorOf(b), isFalse);
        expect(b.isAncestorOf(a), isFalse);
      });
    });

    group('toString', () {
      test('should roundtrip to original string when toString is called', () {
        const original = '1.3.6.1.2.1.1.1.0';
        final oid = OidValue.parse(original);
        expect(oid.toString(), equals(original));
      });
    });

    group('constructor', () {
      test('should construct OidValue when valid sub identifiers are provided',
          () {
        final oid = OidValue(const [1, 3, 6, 1]);
        expect(oid.subIdentifiers, orderedEquals([1, 3, 6, 1]));
      });

      test('should throw OidFormatError when first sub identifier exceeds two',
          () {
        expect(
          () => OidValue(const [3, 6, 1]),
          throwsA(isA<OidFormatError>()),
        );
      });

      test(
          'should throw OidFormatError when second sub identifier exceeds 39 and first is 1',
          () {
        expect(
          () => OidValue(const [1, 40, 1]),
          throwsA(isA<OidFormatError>()),
        );
      });

      test('should throw OidLengthError when only one sub identifier is provided',
          () {
        expect(
          () => OidValue(const [1]),
          throwsA(isA<OidLengthError>()),
        );
      });

      test(
          'should throw OidFormatError when sub identifier exceeds 4294967295',
          () {
        expect(
          () => OidValue(const [1, 3, 4294967296]),
          throwsA(isA<OidFormatError>()),
        );
      });
    });

    group('copyWith', () {
      test('should create copy with modified sub identifiers', () {
        final original = OidValue.parse('1.3.6.1');
        final copied = original.copyWith(subIdentifiers: const [1, 3, 6, 1, 2]);
        expect(copied.subIdentifiers, orderedEquals([1, 3, 6, 1, 2]));
      });

      test('should preserve sub identifiers when copyWith has no arguments', () {
        final original = OidValue.parse('1.3.6.1');
        final copied = original.copyWith();
        expect(copied.subIdentifiers, orderedEquals([1, 3, 6, 1]));
        expect(identical(copied, original), isFalse);
      });
    });
  });

  group('Oid128', () {
    test('should parse valid OID when exactly 128 sub identifiers are provided',
        () {
      final parts =
          List<int>.generate(128, (i) => i == 0 ? 1 : (i == 1 ? 3 : i));
      final oidStr = parts.join('.');
      final oid = Oid128.parse(oidStr);
      expect(oid.subIdentifiers.length, equals(128));
    });

    test('should throw OidLengthError when 129 sub identifiers are provided',
        () {
      final parts =
          List<int>.generate(129, (i) => i == 0 ? 1 : (i == 1 ? 3 : i));
      final oidStr = parts.join('.');
      expect(
        () => Oid128.parse(oidStr),
        throwsA(isA<OidLengthError>()),
      );
    });

    group('copyWith', () {
      test('should return Oid128 when copyWith is called on Oid128', () {
        final original = Oid128.parse('1.3.6.1');
        final copied = original.copyWith(subIdentifiers: const [1, 3, 6, 1, 2]);
        expect(copied, isA<Oid128>());
        expect(copied.subIdentifiers, orderedEquals([1, 3, 6, 1, 2]));
      });
    });
  });
}
