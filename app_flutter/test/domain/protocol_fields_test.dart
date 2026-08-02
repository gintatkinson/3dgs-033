import 'package:app_flutter/domain/protocol_fields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IpVersion', () {
    test('should accept 0 when version is unknown', () {
      final ipv = IpVersion(0);
      expect(ipv.value, 0);
    });

    test('should accept 1 when version is ipv4', () {
      final ipv = IpVersion(1);
      expect(ipv.value, 1);
    });

    test('should accept 2 when version is ipv6', () {
      final ipv = IpVersion(2);
      expect(ipv.value, 2);
    });

    test('should throw IpVersionError when value exceeds maxValue', () {
      expect(
        () => IpVersion(3),
        throwsA(isA<IpVersionError>()),
      );
    });

    test('should throw IpVersionError when value is negative', () {
      expect(
        () => IpVersion(-1),
        throwsA(isA<IpVersionError>()),
      );
    });
  });

  group('Dscp', () {
    test('should accept 0 when value is at minimum', () {
      final dscp = Dscp(0);
      expect(dscp.value, 0);
    });

    test('should accept 63 when value is at maximum', () {
      final dscp = Dscp(63);
      expect(dscp.value, 63);
    });

    test('should throw DscpRangeError when value exceeds maxValue', () {
      expect(
        () => Dscp(64),
        throwsA(isA<DscpRangeError>()),
      );
    });

    test('should throw DscpRangeError when value is negative', () {
      expect(
        () => Dscp(-1),
        throwsA(isA<DscpRangeError>()),
      );
    });
  });

  group('Ipv6FlowLabel', () {
    test('should accept 0 when value is at minimum', () {
      final label = Ipv6FlowLabel(0);
      expect(label.value, 0);
    });

    test('should accept 1048575 when value is at maximum', () {
      final label = Ipv6FlowLabel(1048575);
      expect(label.value, 1048575);
    });

    test('should throw FlowLabelError when value exceeds maxValue', () {
      expect(
        () => Ipv6FlowLabel(1048576),
        throwsA(isA<FlowLabelError>()),
      );
    });

    test('should throw FlowLabelError when value is negative', () {
      expect(
        () => Ipv6FlowLabel(-1),
        throwsA(isA<FlowLabelError>()),
      );
    });
  });

  group('PortNumber', () {
    test('should accept 80 when port is HTTP', () {
      final port = PortNumber(80);
      expect(port.value, 80);
    });

    test('should accept 0 when value is at minimum', () {
      final port = PortNumber(0);
      expect(port.value, 0);
    });

    test('should accept 65535 when value is at maximum', () {
      final port = PortNumber(65535);
      expect(port.value, 65535);
    });

    test('should throw PortNumberError when value exceeds maxValue', () {
      expect(
        () => PortNumber(65536),
        throwsA(isA<PortNumberError>()),
      );
    });

    test('should throw PortNumberError when value is negative', () {
      expect(
        () => PortNumber(-1),
        throwsA(isA<PortNumberError>()),
      );
    });
  });

  group('ProtocolNumber', () {
    test('should accept 6 when protocol is TCP', () {
      final proto = ProtocolNumber(6);
      expect(proto.value, 6);
    });

    test('should accept 0 when value is at minimum', () {
      final proto = ProtocolNumber(0);
      expect(proto.value, 0);
    });

    test('should accept 255 when value is at maximum', () {
      final proto = ProtocolNumber(255);
      expect(proto.value, 255);
    });

    test('should throw ProtocolNumberError when value exceeds maxValue', () {
      expect(
        () => ProtocolNumber(256),
        throwsA(isA<ProtocolNumberError>()),
      );
    });

    test('should throw ProtocolNumberError when value is negative', () {
      expect(
        () => ProtocolNumber(-1),
        throwsA(isA<ProtocolNumberError>()),
      );
    });
  });

  group('UpperLayerProtocolNumber', () {
    test('should extend ProtocolNumber when constructed with valid value', () {
      final ulpn = UpperLayerProtocolNumber(17);
      expect(ulpn, isA<ProtocolNumber>());
      expect(ulpn.value, 17);
    });

    test('should throw ProtocolNumberError when value exceeds 255', () {
      expect(
        () => UpperLayerProtocolNumber(256),
        throwsA(isA<ProtocolNumberError>()),
      );
    });
  });

  group('AsNumber', () {
    test('should accept 64512 when value is within range', () {
      final asn = AsNumber(64512);
      expect(asn.value, 64512);
    });

    test('should accept 0 when value is at minimum', () {
      final asn = AsNumber(0);
      expect(asn.value, 0);
    });

    test('should accept 4294967295 when value is at maximum 32-bit', () {
      final asn = AsNumber(4294967295);
      expect(asn.value, 4294967295);
    });

    test('should throw AsNumberError when value exceeds 32-bit range', () {
      expect(
        () => AsNumber(4294967296),
        throwsA(isA<AsNumberError>()),
      );
    });

    test('should throw AsNumberError when value is negative', () {
      expect(
        () => AsNumber(-1),
        throwsA(isA<AsNumberError>()),
      );
    });
  });
}
