import 'package:app_flutter/domain/protocol_fields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IpVersion', () {
    test('IpVersion 0 valid (unknown)', () {
      final ipv = IpVersion(0);
      expect(ipv.value, 0);
    });

    test('IpVersion 1 valid (ipv4)', () {
      final ipv = IpVersion(1);
      expect(ipv.value, 1);
    });

    test('IpVersion 2 valid (ipv6)', () {
      final ipv = IpVersion(2);
      expect(ipv.value, 2);
    });

    test('IpVersion 3 rejects (out of range)', () {
      expect(
        () => IpVersion(3),
        throwsA(isA<ProtocolFieldValidationException>()),
      );
    });

    test('IpVersion rejects negative value', () {
      expect(
        () => IpVersion(-1),
        throwsA(isA<ProtocolFieldValidationException>()),
      );
    });
  });

  group('Dscp', () {
    test('Dscp 0 valid', () {
      final dscp = Dscp(0);
      expect(dscp.value, 0);
    });

    test('Dscp 63 valid', () {
      final dscp = Dscp(63);
      expect(dscp.value, 63);
    });

    test('Dscp 64 rejects (out of range)', () {
      expect(
        () => Dscp(64),
        throwsA(isA<ProtocolFieldValidationException>()),
      );
    });

    test('Dscp rejects negative value', () {
      expect(
        () => Dscp(-1),
        throwsA(isA<ProtocolFieldValidationException>()),
      );
    });
  });

  group('Ipv6FlowLabel', () {
    test('Ipv6FlowLabel 0 valid', () {
      final label = Ipv6FlowLabel(0);
      expect(label.value, 0);
    });

    test('Ipv6FlowLabel 1048575 valid', () {
      final label = Ipv6FlowLabel(1048575);
      expect(label.value, 1048575);
    });

    test('Ipv6FlowLabel 1048576 rejects (out of range)', () {
      expect(
        () => Ipv6FlowLabel(1048576),
        throwsA(isA<ProtocolFieldValidationException>()),
      );
    });

    test('Ipv6FlowLabel rejects negative value', () {
      expect(
        () => Ipv6FlowLabel(-1),
        throwsA(isA<ProtocolFieldValidationException>()),
      );
    });
  });

  group('PortNumber', () {
    test('PortNumber 80 valid', () {
      final port = PortNumber(80);
      expect(port.value, 80);
    });

    test('PortNumber 0 valid', () {
      final port = PortNumber(0);
      expect(port.value, 0);
    });

    test('PortNumber 65535 valid (max)', () {
      final port = PortNumber(65535);
      expect(port.value, 65535);
    });

    test('PortNumber 65536 rejects (out of range)', () {
      expect(
        () => PortNumber(65536),
        throwsA(isA<ProtocolFieldValidationException>()),
      );
    });

    test('PortNumber rejects negative value', () {
      expect(
        () => PortNumber(-1),
        throwsA(isA<ProtocolFieldValidationException>()),
      );
    });
  });

  group('ProtocolNumber', () {
    test('ProtocolNumber 6 valid (TCP)', () {
      final proto = ProtocolNumber(6);
      expect(proto.value, 6);
    });

    test('ProtocolNumber 0 valid', () {
      final proto = ProtocolNumber(0);
      expect(proto.value, 0);
    });

    test('ProtocolNumber 255 valid (max)', () {
      final proto = ProtocolNumber(255);
      expect(proto.value, 255);
    });

    test('ProtocolNumber 256 rejects (out of range)', () {
      expect(
        () => ProtocolNumber(256),
        throwsA(isA<ProtocolFieldValidationException>()),
      );
    });

    test('ProtocolNumber rejects negative value', () {
      expect(
        () => ProtocolNumber(-1),
        throwsA(isA<ProtocolFieldValidationException>()),
      );
    });
  });

  group('UpperLayerProtocolNumber', () {
    test('UpperLayerProtocolNumber extends ProtocolNumber', () {
      final ulpn = UpperLayerProtocolNumber(17);
      expect(ulpn, isA<ProtocolNumber>());
      expect(ulpn.value, 17);
    });

    test('UpperLayerProtocolNumber rejects value above 255', () {
      expect(
        () => UpperLayerProtocolNumber(256),
        throwsA(isA<ProtocolFieldValidationException>()),
      );
    });
  });

  group('AsNumber', () {
    test('AsNumber 64512 valid', () {
      final asn = AsNumber(64512);
      expect(asn.value, 64512);
    });

    test('AsNumber 0 valid', () {
      final asn = AsNumber(0);
      expect(asn.value, 0);
    });

    test('AsNumber 4294967295 valid (max 32-bit)', () {
      final asn = AsNumber(4294967295);
      expect(asn.value, 4294967295);
    });

    test('AsNumber 4294967296 rejects (exceeds 32-bit)', () {
      expect(
        () => AsNumber(4294967296),
        throwsA(isA<ProtocolFieldValidationException>()),
      );
    });

    test('AsNumber rejects negative value', () {
      expect(
        () => AsNumber(-1),
        throwsA(isA<ProtocolFieldValidationException>()),
      );
    });
  });
}
