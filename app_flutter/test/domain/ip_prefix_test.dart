import 'package:app_flutter/domain/ip_prefix.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ipv4Prefix', () {
    test('parse valid IPv4 prefix "192.0.2.0/24"', () {
      final p = Ipv4Prefix('192.0.2.0/24');
      expect(p.value, equals('192.0.2.0/24'));
      expect(p.prefixLength, equals(24));
    });

    test('reject invalid prefix length >32 "192.0.2.0/33"', () {
      expect(
        () => Ipv4Prefix('192.0.2.0/33'),
        throwsA(isA<IpPrefixValidationException>()),
      );
    });

    test('reject malformed address portion "not.an.ip/24"', () {
      expect(
        () => Ipv4Prefix('not.an.ip/24'),
        throwsA(isA<IpPrefixValidationException>()),
      );
    });

    test('host-bit zeroing in toCanonical() "192.0.2.1/24" -> "192.0.2.0/24"', () {
      final p = Ipv4Prefix('192.0.2.1/24');
      expect(p.toCanonical(), equals('192.0.2.0/24'));
    });

    test('prefix length bounds: accepts 0, 32; rejects -1, 33', () {
      expect(() => Ipv4Prefix('10.0.0.0/0'), returnsNormally);
      expect(() => Ipv4Prefix('10.0.0.0/32'), returnsNormally);
      expect(
        () => Ipv4Prefix('10.0.0.0/-1'),
        throwsA(isA<IpPrefixValidationException>()),
      );
      expect(
        () => Ipv4Prefix('10.0.0.0/33'),
        throwsA(isA<IpPrefixValidationException>()),
      );
    });

    test('canonical output format "192.0.2.0/16"', () {
      final p = Ipv4Prefix('192.0.2.128/16');
      expect(p.toCanonical(), equals('192.0.0.0/16'));
    });
  });

  group('Ipv6Prefix', () {
    test('parse valid IPv6 prefix "2001:db8::/32"', () {
      final p = Ipv6Prefix('2001:db8::/32');
      expect(p.value, equals('2001:db8::/32'));
      expect(p.prefixLength, equals(32));
    });

    test('reject invalid prefix length >128 "2001:db8::/129"', () {
      expect(
        () => Ipv6Prefix('2001:db8::/129'),
        throwsA(isA<IpPrefixValidationException>()),
      );
    });

    test('host-bit zeroing in toCanonical()', () {
      final p = Ipv6Prefix('2001:db8:0:0:0:0:0:1/64');
      final c = p.toCanonical();
      expect(c, equals('2001:db8::/64'));
    });

    test('prefix length bounds: accepts 0, 128; rejects -1, 129', () {
      expect(() => Ipv6Prefix('::/0'), returnsNormally);
      expect(() => Ipv6Prefix('::/128'), returnsNormally);
      expect(
        () => Ipv6Prefix('::/-1'),
        throwsA(isA<IpPrefixValidationException>()),
      );
      expect(
        () => Ipv6Prefix('::/129'),
        throwsA(isA<IpPrefixValidationException>()),
      );
    });
  });

  group('IpPrefix union', () {
    test('parses IPv4 and IPv6 via factory', () {
      final v4 = IpPrefix.parse('10.0.0.0/8');
      expect(v4.value, equals('10.0.0.0/8'));
      final v6 = IpPrefix.parse('2001:db8::/32');
      expect(v6.value, equals('2001:db8::/32'));
    });

    test('rejects malformed union input', () {
      expect(
        () => IpPrefix.parse('not-a-prefix'),
        throwsA(isA<IpPrefixValidationException>()),
      );
    });
  });
}
