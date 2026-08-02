import 'package:app_flutter/domain/ip_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ipv4Address', () {
    test('accepts valid dotted-quad "192.0.2.1"', () {
      final addr = Ipv4Address('192.0.2.1');
      expect(addr.value, equals('192.0.2.1'));
      expect(addr.zoneIndex, isNull);
      expect(addr.toCanonical(), equals('192.0.2.1'));
    });

    test('rejects octet exceeding 255 "192.0.2.256"', () {
      expect(
        () => Ipv4Address('192.0.2.256'),
        throwsA(isA<IpAddressValidationException>()),
      );
    });

    test('extracts zone index from "169.254.1.1%eth0"', () {
      final addr = Ipv4Address('169.254.1.1%eth0');
      expect(addr.value, equals('169.254.1.1%eth0'));
      expect(addr.zoneIndex, equals('eth0'));
    });
  });

  group('Ipv6Address', () {
    test('accepts full notation "2001:0db8:0000:0000:0000:0000:0000:0001"', () {
      final addr = Ipv6Address('2001:0db8:0000:0000:0000:0000:0000:0001');
      expect(addr.value,
          equals('2001:0db8:0000:0000:0000:0000:0000:0001'));
      expect(addr.zoneIndex, isNull);
    });

    test('accepts shortened notation "2001:db8::1"', () {
      final addr = Ipv6Address('2001:db8::1');
      expect(addr.value, equals('2001:db8::1'));
      expect(addr.zoneIndex, isNull);
    });

    test('extracts zone index from "fe80::1%eth0"', () {
      final addr = Ipv6Address('fe80::1%eth0');
      expect(addr.value, equals('fe80::1%eth0'));
      expect(addr.zoneIndex, equals('eth0'));
    });

    test('toCanonical() applies RFC 5952 lowercase and zero-compression', () {
      expect(
        Ipv6Address('2001:0db8:0000:0000:0000:0000:0000:0001')
            .toCanonical(),
        equals('2001:db8::1'),
      );
      expect(
        Ipv6Address('2001:db8:0:0:0:0:0:1').toCanonical(),
        equals('2001:db8::1'),
      );
      expect(
        Ipv6Address('2001:db8::0:1').toCanonical(),
        equals('2001:db8::1'),
      );
      expect(
        Ipv6Address('2001:0db8:0000:0000:0000:0000:0000:0000')
            .toCanonical(),
        equals('2001:db8::'),
      );
    });
  });

  group('Ipv4AddressNoZone', () {
    test('accepts "192.0.2.1" and rejects zone "192.0.2.1%eth0"', () {
      final addr = Ipv4AddressNoZone('192.0.2.1');
      expect(addr.value, equals('192.0.2.1'));
      expect(addr.zoneIndex, isNull);

      expect(
        () => Ipv4AddressNoZone('192.0.2.1%eth0'),
        throwsA(isA<IpAddressValidationException>()),
      );
    });
  });

  group('Ipv6AddressNoZone', () {
    test('accepts "2001:db8::1" and rejects zone "2001:db8::1%eth0"', () {
      final addr = Ipv6AddressNoZone('2001:db8::1');
      expect(addr.value, equals('2001:db8::1'));
      expect(addr.zoneIndex, isNull);

      expect(
        () => Ipv6AddressNoZone('2001:db8::1%eth0'),
        throwsA(isA<IpAddressValidationException>()),
      );
    });
  });

  group('Ipv4AddressLinkLocal', () {
    test('accepts "169.254.1.1" and rejects non-link-local "192.0.2.1"', () {
      final addr = Ipv4AddressLinkLocal('169.254.1.1');
      expect(addr.value, equals('169.254.1.1'));
      expect(addr.zoneIndex, isNull);

      expect(
        () => Ipv4AddressLinkLocal('192.0.2.1'),
        throwsA(isA<IpAddressValidationException>()),
      );
    });
  });

  group('Ipv6AddressLinkLocal', () {
    test('accepts "fe80::1" and rejects non-link-local "2001:db8::1"', () {
      final addr = Ipv6AddressLinkLocal('fe80::1');
      expect(addr.value, equals('fe80::1'));
      expect(addr.zoneIndex, isNull);

      expect(
        () => Ipv6AddressLinkLocal('2001:db8::1'),
        throwsA(isA<IpAddressValidationException>()),
      );
    });
  });

  group('IpAddress union', () {
    test('accepts both IPv4 "192.0.2.1" and IPv6 "2001:db8::1"', () {
      final v4 = IpAddress('192.0.2.1');
      expect(v4.value, equals('192.0.2.1'));
      expect(v4.zoneIndex, isNull);
      expect(v4.toCanonical(), equals('192.0.2.1'));

      final v6 = IpAddress('2001:db8::1');
      expect(v6.value, equals('2001:db8::1'));
      expect(v6.zoneIndex, isNull);
      expect(v6.toCanonical(), equals('2001:db8::1'));
    });

    test('resolves Ipv6 with zone index via union', () {
      final addr = IpAddress('fe80::1%eth0');
      expect(addr.value, equals('fe80::1%eth0'));
      expect(addr.zoneIndex, equals('eth0'));
    });

    test('rejects invalid address "not-an-ip"', () {
      expect(
        () => IpAddress('not-an-ip'),
        throwsA(isA<IpAddressValidationException>()),
      );
    });
  });
}
