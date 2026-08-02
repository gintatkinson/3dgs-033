import 'package:app_flutter/domain/address_string.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MacAddressFormatError', () {
    test('should include value and message when created', () {
      const ex = MacAddressFormatError('invalid mac');
      expect(ex.message, equals('invalid mac'));
      expect(ex.toString(), contains('MacAddressFormatError'));
    });
  });

  group('PhysAddress', () {
    test('should accept valid colon separated hex octets as value', () {
      final addr = PhysAddress('aa:bb:cc:dd:ee:ff');
      expect(addr.value, equals('aa:bb:cc:dd:ee:ff'));
    });

    test('should throw MacAddressFormatError when invalid hex characters are used',
        () {
      expect(
        () => PhysAddress('zz:bb:cc'),
        throwsA(isA<MacAddressFormatError>()),
      );
    });

    test('should accept empty string as valid optional address', () {
      final addr = PhysAddress('');
      expect(addr.value, equals(''));
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = PhysAddress('aa:bb:cc');
        final copied = original.copyWith(value: 'dd:ee:ff');
        expect(copied.value, equals('dd:ee:ff'));
      });
    });
  });

  group('MacAddress', () {
    test('should accept valid 48 bit MAC address as value', () {
      final addr = MacAddress('00:11:22:33:44:55');
      expect(addr.value, equals('00:11:22:33:44:55'));
    });

    test('should throw MacAddressFormatError when only 5 octets are provided', () {
      expect(
        () => MacAddress('00:11:22:33:44'),
        throwsA(isA<MacAddressFormatError>()),
      );
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = MacAddress('00:11:22:33:44:55');
        final copied = original.copyWith(value: 'aa:bb:cc:dd:ee:ff');
        expect(copied.value, equals('aa:bb:cc:dd:ee:ff'));
      });
    });
  });

  group('Uuid', () {
    test('should accept valid RFC 9562 UUID string', () {
      final uuid = Uuid('550e8400-e29b-41d4-a716-446655440000');
      expect(uuid.value, equals('550e8400-e29b-41d4-a716-446655440000'));
    });

    test('should throw UuidFormatError when string is not a valid UUID', () {
      expect(
        () => Uuid('not-a-uuid'),
        throwsA(isA<UuidFormatError>()),
      );
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = Uuid('550e8400-e29b-41d4-a716-446655440000');
        final copied =
            original.copyWith(value: 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6');
        expect(copied.value,
            equals('f81d4fae-7dec-11d0-a765-00a0c91e6bf6'));
      });
    });
  });

  group('DottedQuad', () {
    test('should accept valid dotted decimal IPv4 quad', () {
      final dq = DottedQuad('192.168.1.1');
      expect(dq.value, equals('192.168.1.1'));
    });

    test('should throw DottedQuadFormatError when octet exceeds 255', () {
      expect(
        () => DottedQuad('256.1.1.1'),
        throwsA(isA<DottedQuadFormatError>()),
      );
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = DottedQuad('192.168.1.1');
        final copied = original.copyWith(value: '10.0.0.1');
        expect(copied.value, equals('10.0.0.1'));
      });
    });
  });

  group('HexString', () {
    test('should accept valid colon separated hex string', () {
      final hs = HexString('4A:7f');
      expect(hs.value, equals('4A:7f'));
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = HexString('4A:7f');
        final copied = original.copyWith(value: 'FF:00');
        expect(copied.value, equals('FF:00'));
      });
    });
  });

  group('LanguageTag', () {
    test('should accept valid BCP 47 language tag', () {
      final lt = LanguageTag('en-US');
      expect(lt.value, equals('en-US'));
    });

    test('should throw LanguageTagFormatError when tag is invalid', () {
      expect(
        () => LanguageTag(''),
        throwsA(isA<LanguageTagFormatError>()),
      );
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = LanguageTag('en-US');
        final copied = original.copyWith(value: 'fr-FR');
        expect(copied.value, equals('fr-FR'));
      });
    });
  });

  group('YangIdentifier', () {
    test('should accept valid YANG identifier with underscore and dot', () {
      final yi = YangIdentifier('my-interface_1.0');
      expect(yi.value, equals('my-interface_1.0'));
    });

    test('should throw LanguageTagFormatError when identifier is invalid', () {
      expect(
        () => YangIdentifier(''),
        throwsA(isA<LanguageTagFormatError>()),
      );
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = YangIdentifier('my-interface_1.0');
        final copied = original.copyWith(value: 'another-interface');
        expect(copied.value, equals('another-interface'));
      });
    });
  });
}
