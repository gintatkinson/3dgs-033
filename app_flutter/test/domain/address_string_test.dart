import 'package:app_flutter/domain/address_string.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhysAddress', () {
    test('accepts valid "aa:bb:cc:dd:ee:ff"', () {
      final addr = PhysAddress('aa:bb:cc:dd:ee:ff');
      expect(addr.value, equals('aa:bb:cc:dd:ee:ff'));
    });

    test('rejects "zz:bb:cc" (invalid hex digits)', () {
      expect(
        () => PhysAddress('zz:bb:cc'),
        throwsA(isA<AddressStringValidationException>()),
      );
    });
  });

  group('MacAddress', () {
    test('accepts valid "00:11:22:33:44:55"', () {
      final addr = MacAddress('00:11:22:33:44:55');
      expect(addr.value, equals('00:11:22:33:44:55'));
    });

    test('rejects "00:11:22:33:44" (only 5 octets)', () {
      expect(
        () => MacAddress('00:11:22:33:44'),
        throwsA(isA<AddressStringValidationException>()),
      );
    });
  });

  group('Uuid', () {
    test('accepts "550e8400-e29b-41d4-a716-446655440000"', () {
      final uuid = Uuid('550e8400-e29b-41d4-a716-446655440000');
      expect(uuid.value, equals('550e8400-e29b-41d4-a716-446655440000'));
    });

    test('rejects "not-a-uuid"', () {
      expect(
        () => Uuid('not-a-uuid'),
        throwsA(isA<AddressStringValidationException>()),
      );
    });
  });

  group('DottedQuad', () {
    test('accepts "192.168.1.1"', () {
      final dq = DottedQuad('192.168.1.1');
      expect(dq.value, equals('192.168.1.1'));
    });

    test('rejects "256.1.1.1" (octet >255)', () {
      expect(
        () => DottedQuad('256.1.1.1'),
        throwsA(isA<AddressStringValidationException>()),
      );
    });
  });

  group('HexString', () {
    test('accepts "4A:7f"', () {
      final hs = HexString('4A:7f');
      expect(hs.value, equals('4A:7f'));
    });
  });

  group('LanguageTag', () {
    test('accepts "en-US"', () {
      final lt = LanguageTag('en-US');
      expect(lt.value, equals('en-US'));
    });
  });

  group('YangIdentifier', () {
    test('accepts valid name "my-interface_1.0"', () {
      final yi = YangIdentifier('my-interface_1.0');
      expect(yi.value, equals('my-interface_1.0'));
    });
  });

  group('Empty phys-address', () {
    test('empty string is valid (optional)', () {
      final addr = PhysAddress('');
      expect(addr.value, equals(''));
    });
  });
}
