import 'package:app_flutter/domain/address_string.dart';
import 'package:app_flutter/domain/counter_gauge.dart';
import 'package:app_flutter/domain/date_time.dart';
import 'package:app_flutter/domain/ip_address.dart';
import 'package:app_flutter/domain/geo_location.dart';
import 'package:app_flutter/domain/ip_prefix.dart';
import 'package:app_flutter/domain/protocol_fields.dart';
import 'package:app_flutter/domain/time_duration.dart';
import 'package:app_flutter/domain/time_tracking.dart';
import 'package:app_flutter/domain/validation.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateFields', () {
    test('required field validation', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'name', label: 'Name', type: 'string', required: true),
      ];
      expect(validateFields({'name': 'John'}, desc), isTrue);
      expect(validateFields({'name': ''}, desc), isFalse);
      expect(validateFields({}, desc), isFalse);
    });

    test('optional field validation when empty', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'name', label: 'Name', type: 'string', required: false, pattern: '^[A-Z]{3}\$'),
      ];
      // Since it is optional and empty, it should pass without regex check
      expect(validateFields({}, desc), isTrue);
      expect(validateFields({'name': ''}, desc), isTrue);
      expect(validateFields({'name': 'ABC'}, desc), isTrue);
      expect(validateFields({'name': 'ab'}, desc), isFalse); // fails pattern if value present
    });

    test('integer range constraints', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'age', label: 'Age', type: 'int', required: true, minValue: 18, maxValue: 99),
      ];
      expect(validateFields({'age': 20}, desc), isTrue);
      expect(validateFields({'age': '20'}, desc), isTrue); // parses string int
      expect(validateFields({'age': 17}, desc), isFalse);
      expect(validateFields({'age': 100}, desc), isFalse);
      expect(validateFields({'age': 'not_an_int'}, desc), isFalse);
    });

    test('double range constraints', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'score', label: 'Score', type: 'double', required: true, minValue: 1.5, maxValue: 5.0),
      ];
      expect(validateFields({'score': 3.14}, desc), isTrue);
      expect(validateFields({'score': '3.14'}, desc), isTrue);
      expect(validateFields({'score': 1.4}, desc), isFalse);
      expect(validateFields({'score': 5.1}, desc), isFalse);
      expect(validateFields({'score': 'invalid'}, desc), isFalse);
    });

    test('pattern regex constraints', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'code', label: 'Code', type: 'string', required: true, pattern: '^[A-Z]{2}\$'),
      ];
      expect(validateFields({'code': 'FI'}, desc), isTrue);
      expect(validateFields({'code': 'US'}, desc), isTrue);
      expect(validateFields({'code': 'us'}, desc), isFalse);
      expect(validateFields({'code': 'USA'}, desc), isFalse);
    });

    test('enum options constraints', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(
          key: 'status',
          label: 'Status',
          type: 'enum',
          required: true,
          enumOptions: ['ACTIVE', 'INACTIVE'],
        ),
      ];
      expect(validateFields({'status': 'ACTIVE'}, desc), isTrue);
      expect(validateFields({'status': 'INACTIVE'}, desc), isTrue);
      expect(validateFields({'status': 'PENDING'}, desc), isFalse);
    });
  });

  group('OID validation', () {
    test('validateFields accepts valid OID', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'oid', label: 'OID', type: 'oid', required: true),
      ];
      expect(validateFields({'oid': '1.3.6.1.2.1.1.1.0'}, desc), isTrue);
    });

    test('validateFields rejects invalid first sub-identifier', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'oid', label: 'OID', type: 'oid', required: true),
      ];
      expect(validateFields({'oid': '3.6.1'}, desc), isFalse);
    });

    test('validateFields rejects whitespace in OID', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'oid', label: 'OID', type: 'oid', required: true),
      ];
      expect(validateFields({'oid': '1.3. 6.1'}, desc), isFalse);
    });

    test('validateFields rejects single sub-identifier', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'oid', label: 'OID', type: 'oid', required: true),
      ];
      expect(validateFields({'oid': '1'}, desc), isFalse);
    });

    test('validateFields accepts valid OID128', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'oid128', label: 'OID128', type: 'oid128', required: true),
      ];
      expect(validateFields({'oid128': '1.3.6.1.2.1'}, desc), isTrue);
    });

    test('validateFields rejects OID128 with 129 sub-identifiers', () {
      final parts = List<int>.generate(129, (i) => i == 0 ? 1 : (i == 1 ? 3 : i));
      final oidStr = parts.join('.');
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'oid128', label: 'OID128', type: 'oid128', required: true),
      ];
      expect(validateFields({'oid128': oidStr}, desc), isFalse);
    });
  });

  group('counter and gauge validation', () {
    test('counter32 accepts valid positive integer', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'ifInOctets', label: 'IfInOctets', type: 'counter32', required: true),
      ];
      expect(validateFields({'ifInOctets': 4294967295}, desc), isTrue);
    });

    test('counter32 rejects negative value', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'ifInOctets', label: 'IfInOctets', type: 'counter32', required: true),
      ];
      expect(validateFields({'ifInOctets': -1}, desc), isFalse);
    });

    test('gauge32 accepts valid value within bounds', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'ifSpeed', label: 'IfSpeed', type: 'gauge32', required: true),
      ];
      expect(validateFields({'ifSpeed': 1000000000}, desc), isTrue);
    });

    test('gauge64 accepts valid BigInt value', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'hcInOctets', label: 'HCInOctets', type: 'counter64', required: true),
      ];
      expect(validateFields({'hcInOctets': '18446744073709551615'}, desc), isTrue);
    });
  });

  group('time duration validation', () {
    test('hours32 accepts valid positive integer', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'uptime', label: 'Uptime', type: 'hours32', required: true),
      ];
      expect(validateFields({'uptime': 24}, desc), isTrue);
    });

    test('hours32 rejects negative value', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'uptime', label: 'Uptime', type: 'hours32', required: true),
      ];
      expect(validateFields({'uptime': -1}, desc), isFalse);
    });

    test('seconds32 accepts valid value', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'timeout', label: 'Timeout', type: 'seconds32', required: true),
      ];
      expect(validateFields({'timeout': 45}, desc), isTrue);
      expect(validateFields({'timeout': -1}, desc), isFalse);
    });

    test('milliseconds32 accepts valid value and rejects out of bounds', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'latency', label: 'Latency', type: 'milliseconds32', required: true),
      ];
      expect(validateFields({'latency': 500}, desc), isTrue);
      expect(validateFields({'latency': 2147483648}, desc), isFalse);
    });
  });

  group('date and time validation', () {
    test('validateFields accepts valid dateAndTime', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'timestamp', label: 'Timestamp', type: 'dateAndTime', required: true),
      ];
      expect(validateFields({'timestamp': '2025-12-22T14:30:00Z'}, desc), isTrue);
    });

    test('validateFields rejects invalid dateAndTime', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'timestamp', label: 'Timestamp', type: 'dateAndTime', required: true),
      ];
      expect(validateFields({'timestamp': '2025-13-01T00:00:00Z'}, desc), isFalse);
    });

    test('validateFields accepts valid date', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'startDate', label: 'Start Date', type: 'date', required: true),
      ];
      expect(validateFields({'startDate': '2025-12-22'}, desc), isTrue);
    });

    test('validateFields accepts valid dateNoZone', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'birthDate', label: 'Birth Date', type: 'dateNoZone', required: true),
      ];
      expect(validateFields({'birthDate': '2025-12-22'}, desc), isTrue);
    });

    test('validateFields accepts valid timeNoZone', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'startTime', label: 'Start Time', type: 'timeNoZone', required: true),
      ];
      expect(validateFields({'startTime': '14:30:00'}, desc), isTrue);
    });
  });

  group('time tracking validation', () {
    test('validateFields accepts valid timeTicks', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'sysUpTime', label: 'SysUpTime', type: 'timeTicks', required: true),
      ];
      expect(validateFields({'sysUpTime': 8640000}, desc), isTrue);
    });

    test('validateFields rejects negative timeTicks', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'sysUpTime', label: 'SysUpTime', type: 'timeTicks', required: true),
      ];
      expect(validateFields({'sysUpTime': -1}, desc), isFalse);
    });

    test('validateFields accepts valid timeStamp', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'lastChange', label: 'LastChange', type: 'timeStamp', required: true),
      ];
      expect(validateFields({'lastChange': 4320000}, desc), isTrue);
    });
  });

  group('address string validation', () {
    test('validateFields accepts valid physAddress', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'phys', label: 'Phys', type: 'physAddress', required: true),
      ];
      expect(validateFields({'phys': '00:1a:2b:3c:4d:5e'}, desc), isTrue);
    });

    test('validateFields accepts valid macAddress', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'mac', label: 'MAC', type: 'macAddress', required: true),
      ];
      expect(validateFields({'mac': 'aa:bb:cc:dd:ee:ff'}, desc), isTrue);
    });

    test('validateFields accepts valid uuid', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'id', label: 'ID', type: 'uuid', required: true),
      ];
      expect(validateFields({'id': '550e8400-e29b-41d4-a716-446655440000'}, desc), isTrue);
    });

    test('validateFields accepts valid dottedQuad', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'ip', label: 'IP', type: 'dottedQuad', required: true),
      ];
      expect(validateFields({'ip': '10.0.0.1'}, desc), isTrue);
    });
  });

  group('protocol field validation', () {
    test('validateFields accepts valid ipVersion', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'ipv', label: 'IP Version', type: 'ipVersion', required: true),
      ];
      expect(validateFields({'ipv': 1}, desc), isTrue);
      expect(validateFields({'ipv': 0}, desc), isTrue);
      expect(validateFields({'ipv': 2}, desc), isTrue);
      expect(validateFields({'ipv': 3}, desc), isFalse);
      expect(validateFields({'ipv': 'invalid'}, desc), isFalse);
    });

    test('validateFields accepts valid dscp', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'dscp', label: 'DSCP', type: 'dscp', required: true),
      ];
      expect(validateFields({'dscp': 46}, desc), isTrue);
      expect(validateFields({'dscp': 0}, desc), isTrue);
      expect(validateFields({'dscp': 63}, desc), isTrue);
      expect(validateFields({'dscp': 64}, desc), isFalse);
    });

    test('validateFields accepts valid portNumber', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'port', label: 'Port', type: 'portNumber', required: true),
      ];
      expect(validateFields({'port': 443}, desc), isTrue);
      expect(validateFields({'port': 65535}, desc), isTrue);
      expect(validateFields({'port': 65536}, desc), isFalse);
    });

    test('validateFields accepts valid asNumber', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'asn', label: 'AS Number', type: 'asNumber', required: true),
      ];
      expect(validateFields({'asn': 64496}, desc), isTrue);
      expect(validateFields({'asn': 0}, desc), isTrue);
      expect(validateFields({'asn': 4294967295}, desc), isTrue);
      expect(validateFields({'asn': 4294967296}, desc), isFalse);
    });
  });

  group('ip address validation', () {
    test('validateFields accepts valid ipAddress and rejects invalid', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'addr', label: 'Address', type: 'ipAddress', required: true),
      ];
      expect(validateFields({'addr': '192.0.2.1'}, desc), isTrue);
      expect(validateFields({'addr': '2001:db8::1'}, desc), isTrue);
      expect(validateFields({'addr': 'not-an-ip'}, desc), isFalse);
    });

    test('validateFields accepts valid ipv4Address and rejects invalid', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'addr', label: 'Address', type: 'ipv4Address', required: true),
      ];
      expect(validateFields({'addr': '10.0.0.1'}, desc), isTrue);
      expect(validateFields({'addr': '10.0.0.256'}, desc), isFalse);
    });

    test('validateFields accepts valid ipv6Address and rejects invalid', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'addr', label: 'Address', type: 'ipv6Address', required: true),
      ];
      expect(validateFields({'addr': 'fe80::1'}, desc), isTrue);
      expect(validateFields({'addr': 'not-v6'}, desc), isFalse);
    });
  });

  group('ip prefix validation', () {
    test('validateFields accepts valid ipPrefix and rejects invalid', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'pfx', label: 'Prefix', type: 'ipPrefix', required: true),
      ];
      expect(validateFields({'pfx': '192.0.2.0/24'}, desc), isTrue);
      expect(validateFields({'pfx': '2001:db8::/32'}, desc), isTrue);
      expect(validateFields({'pfx': 'invalid/33'}, desc), isFalse);
    });

    test('validateFields accepts valid ipv4Prefix and rejects bounds', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'pfx', label: 'Prefix', type: 'ipv4Prefix', required: true),
      ];
      expect(validateFields({'pfx': '10.0.0.0/8'}, desc), isTrue);
      expect(validateFields({'pfx': '10.0.0.0/33'}, desc), isFalse);
    });

    test('validateFields accepts valid ipv6Prefix and rejects bounds', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'pfx', label: 'Prefix', type: 'ipv6Prefix', required: true),
      ];
      expect(validateFields({'pfx': '2001:db8::/32'}, desc), isTrue);
      expect(validateFields({'pfx': '2001:db8::/129'}, desc), isFalse);
    });
  });

  group('domain host validation', () {
    test('validateFields accepts valid domainName and rejects invalid', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'domain', label: 'Domain', type: 'domainName', required: true),
      ];
      expect(validateFields({'domain': 'example.com'}, desc), isTrue);
      expect(validateFields({'domain': 'invalid..domain'}, desc), isFalse);
    });

    test('validateFields accepts valid host union (IP or hostname) and rejects invalid', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'host', label: 'Host', type: 'host', required: true),
      ];
      expect(validateFields({'host': '192.0.2.1'}, desc), isTrue);
      expect(validateFields({'host': 'example.com'}, desc), isTrue);
      expect(validateFields({'host': 'invalid host!'}, desc), isFalse);
    });

    test('validateFields accepts valid uri and rejects invalid', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'uri', label: 'URI', type: 'uri', required: true),
      ];
      expect(validateFields({'uri': 'https://example.com'}, desc), isTrue);
      expect(validateFields({'uri': 'not-a-uri'}, desc), isFalse);
    });

    test('validateFields accepts valid email and rejects invalid', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'email', label: 'Email', type: 'email', required: true),
      ];
      expect(validateFields({'email': 'user@example.com'}, desc), isTrue);
      expect(validateFields({'email': 'not-an-email'}, desc), isFalse);
    });
  });

  group('geoLocation validation', () {
    test('validateFields accepts valid geoLocation JSON', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'geo', label: 'Geo', type: 'geoLocation', required: true),
      ];
      expect(
        validateFields({
          'geo': '{"timestamp":"2012-03-31T16:00:00Z","validUntil":"2026-12-31T23:59:59Z","astronomicalBody":"earth","geodeticDatum":"wgs-84"}',
        }, desc),
        isTrue,
      );
    });

    test('validateFields rejects geoLocation with invalid timestamp', () {
      final desc = <FieldDescriptor>[
        const FieldDescriptor(key: 'geo', label: 'Geo', type: 'geoLocation', required: true),
      ];
      expect(
        validateFields({
          'geo': '{"timestamp":"invalid-date","astronomicalBody":"earth","geodeticDatum":"wgs-84"}',
        }, desc),
        isFalse,
      );
    });
  });
}
