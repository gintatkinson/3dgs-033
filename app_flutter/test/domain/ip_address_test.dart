import 'package:app_flutter/domain/ip_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ipv4Address', () {
    test('should accept valid dotted-quad when address is "192.0.2.1"', () {
      final addr = Ipv4Address('192.0.2.1');
      expect(addr.value, equals('192.0.2.1'));
      expect(addr.zoneIndex, isNull);
      expect(addr.toCanonical(), equals('192.0.2.1'));
    });

    test('should throw Ipv4FormatError when octet exceeds 255', () {
      expect(
        () => Ipv4Address('192.0.2.256'),
        throwsA(isA<Ipv4FormatError>()),
      );
    });

    test('should extract zone index when address contains "%eth0"', () {
      final addr = Ipv4Address('169.254.1.1%eth0');
      expect(addr.value, equals('169.254.1.1%eth0'));
      expect(addr.zoneIndex, equals('eth0'));
    });
  });

  group('Ipv6Address', () {
    test('should accept full notation when address is "2001:0db8:0000:0000:0000:0000:0000:0001"', () {
      final addr = Ipv6Address('2001:0db8:0000:0000:0000:0000:0000:0001');
      expect(addr.value,
          equals('2001:0db8:0000:0000:0000:0000:0000:0001'));
      expect(addr.zoneIndex, isNull);
    });

    test('should accept shortened notation when address is "2001:db8::1"', () {
      final addr = Ipv6Address('2001:db8::1');
      expect(addr.value, equals('2001:db8::1'));
      expect(addr.zoneIndex, isNull);
    });

    test('should extract zone index when address contains "%eth0"', () {
      final addr = Ipv6Address('fe80::1%eth0');
      expect(addr.value, equals('fe80::1%eth0'));
      expect(addr.zoneIndex, equals('eth0'));
    });

    test('should apply RFC 5952 canonicalization when address has leading zeros', () {
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
    test('should accept "192.0.2.1" when address has no zone', () {
      final addr = Ipv4AddressNoZone('192.0.2.1');
      expect(addr.value, equals('192.0.2.1'));
      expect(addr.zoneIndex, isNull);
    });

    test('should throw ZoneIndexError when address contains "%eth0"', () {
      expect(
        () => Ipv4AddressNoZone('192.0.2.1%eth0'),
        throwsA(isA<ZoneIndexError>()),
      );
    });
  });

  group('Ipv6AddressNoZone', () {
    test('should accept "2001:db8::1" when address has no zone', () {
      final addr = Ipv6AddressNoZone('2001:db8::1');
      expect(addr.value, equals('2001:db8::1'));
      expect(addr.zoneIndex, isNull);
    });

    test('should throw ZoneIndexError when address contains "%eth0"', () {
      expect(
        () => Ipv6AddressNoZone('2001:db8::1%eth0'),
        throwsA(isA<ZoneIndexError>()),
      );
    });
  });

  group('Ipv4AddressLinkLocal', () {
    test('should accept "169.254.1.1" when address is link-local', () {
      final addr = Ipv4AddressLinkLocal('169.254.1.1');
      expect(addr.value, equals('169.254.1.1'));
      expect(addr.zoneIndex, isNull);
    });

    test('should throw LinkLocalRangeError when address is non-link-local "192.0.2.1"', () {
      expect(
        () => Ipv4AddressLinkLocal('192.0.2.1'),
        throwsA(isA<LinkLocalRangeError>()),
      );
    });
  });

  group('Ipv6AddressLinkLocal', () {
    test('should accept "fe80::1" when address is link-local', () {
      final addr = Ipv6AddressLinkLocal('fe80::1');
      expect(addr.value, equals('fe80::1'));
      expect(addr.zoneIndex, isNull);
    });

    test('should throw LinkLocalRangeError when address is non-link-local "2001:db8::1"', () {
      expect(
        () => Ipv6AddressLinkLocal('2001:db8::1'),
        throwsA(isA<LinkLocalRangeError>()),
      );
    });
  });

  group('IpAddress', () {
    test('should accept IPv4 "192.0.2.1" when address is a dotted-quad', () {
      final v4 = IpAddress('192.0.2.1');
      expect(v4.value, equals('192.0.2.1'));
      expect(v4.zoneIndex, isNull);
      expect(v4.toCanonical(), equals('192.0.2.1'));
    });

    test('should accept IPv6 "2001:db8::1" when address is shortened notation', () {
      final v6 = IpAddress('2001:db8::1');
      expect(v6.value, equals('2001:db8::1'));
      expect(v6.zoneIndex, isNull);
      expect(v6.toCanonical(), equals('2001:db8::1'));
    });

    test('should resolve zone index when address is "fe80::1%eth0"', () {
      final addr = IpAddress('fe80::1%eth0');
      expect(addr.value, equals('fe80::1%eth0'));
      expect(addr.zoneIndex, equals('eth0'));
    });

    test('should throw Ipv4FormatError when address is "not-an-ip"', () {
      expect(
        () => IpAddress('not-an-ip'),
        throwsA(isA<Ipv4FormatError>()),
      );
    });
  });

  group('IpAddressNoZone', () {
    test('should accept "192.0.2.1" when address is valid IPv4', () {
      final addr = IpAddressNoZone('192.0.2.1');
      expect(addr.value, equals('192.0.2.1'));
      expect(addr.zoneIndex, isNull);
      expect(addr.toCanonical(), equals('192.0.2.1'));
    });

    test('should throw ZoneIndexError when address contains zone', () {
      expect(
        () => IpAddressNoZone('192.0.2.1%eth0'),
        throwsA(isA<ZoneIndexError>()),
      );
    });

    test('should throw Ipv4FormatError when address is invalid', () {
      expect(
        () => IpAddressNoZone('not.an.ip'),
        throwsA(isA<Ipv4FormatError>()),
      );
    });
  });

  group('IpAddressLinkLocal', () {
    test('should accept "169.254.1.1" when address is link-local IPv4', () {
      final addr = IpAddressLinkLocal('169.254.1.1');
      expect(addr.value, equals('169.254.1.1'));
      expect(addr.zoneIndex, isNull);
    });

    test('should accept "fe80::1" when address is link-local IPv6', () {
      final addr = IpAddressLinkLocal('fe80::1');
      expect(addr.value, equals('fe80::1'));
      expect(addr.zoneIndex, isNull);
    });

    test('should throw LinkLocalRangeError when address is non-link-local', () {
      expect(
        () => IpAddressLinkLocal('192.0.2.1'),
        throwsA(isA<LinkLocalRangeError>()),
      );
      expect(
        () => IpAddressLinkLocal('2001:db8::1'),
        throwsA(isA<LinkLocalRangeError>()),
      );
    });
  });
}
