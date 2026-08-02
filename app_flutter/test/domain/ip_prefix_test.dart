import 'package:app_flutter/domain/ip_prefix.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ipv4Prefix', () {
    test('should parse "192.0.2.0/24" when prefix is valid IPv4', () {
      final p = Ipv4Prefix('192.0.2.0/24');
      expect(p.value, equals('192.0.2.0/24'));
      expect(p.prefixLength, equals(24));
    });

    test('should throw PrefixLengthError when length exceeds 32', () {
      expect(
        () => Ipv4Prefix('192.0.2.0/33'),
        throwsA(isA<PrefixLengthError>()),
      );
    });

    test('should throw PrefixFormatError when address portion is malformed', () {
      expect(
        () => Ipv4Prefix('not.an.ip/24'),
        throwsA(isA<PrefixFormatError>()),
      );
    });

    test('should zero host bits when converting "192.0.2.1/24" to canonical', () {
      final p = Ipv4Prefix('192.0.2.1/24');
      expect(p.toCanonical(), equals('192.0.2.0/24'));
    });

    test('should accept boundary lengths 0 and 32 when prefix is at limits', () {
      expect(() => Ipv4Prefix('10.0.0.0/0'), returnsNormally);
      expect(() => Ipv4Prefix('10.0.0.0/32'), returnsNormally);
    });

    test('should throw PrefixLengthError when length is negative', () {
      expect(
        () => Ipv4Prefix('10.0.0.0/-1'),
        throwsA(isA<PrefixLengthError>()),
      );
    });

    test('should canonicalize "192.0.2.128/16" to "192.0.0.0/16"', () {
      final p = Ipv4Prefix('192.0.2.128/16');
      expect(p.toCanonical(), equals('192.0.0.0/16'));
    });
  });

  group('Ipv6Prefix', () {
    test('should parse "2001:db8::/32" when prefix is valid IPv6', () {
      final p = Ipv6Prefix('2001:db8::/32');
      expect(p.value, equals('2001:db8::/32'));
      expect(p.prefixLength, equals(32));
    });

    test('should throw PrefixLengthError when length exceeds 128', () {
      expect(
        () => Ipv6Prefix('2001:db8::/129'),
        throwsA(isA<PrefixLengthError>()),
      );
    });

    test('should zero host bits when converting to canonical', () {
      final p = Ipv6Prefix('2001:db8:0:0:0:0:0:1/64');
      final c = p.toCanonical();
      expect(c, equals('2001:db8::/64'));
    });

    test('should accept boundary lengths 0 and 128 when prefix is at limits', () {
      expect(() => Ipv6Prefix('::/0'), returnsNormally);
      expect(() => Ipv6Prefix('::/128'), returnsNormally);
    });

    test('should throw PrefixLengthError when length is negative', () {
      expect(
        () => Ipv6Prefix('::/-1'),
        throwsA(isA<PrefixLengthError>()),
      );
    });
  });

  group('IpPrefix', () {
    test('should parse IPv4 and IPv6 via factory when input is valid', () {
      final v4 = IpPrefix.parse('10.0.0.0/8');
      expect(v4.value, equals('10.0.0.0/8'));
      final v6 = IpPrefix.parse('2001:db8::/32');
      expect(v6.value, equals('2001:db8::/32'));
    });

    test('should throw PrefixFormatError when input has no prefix length', () {
      expect(
        () => IpPrefix.parse('not-a-prefix'),
        throwsA(isA<PrefixFormatError>()),
      );
    });
  });
}
