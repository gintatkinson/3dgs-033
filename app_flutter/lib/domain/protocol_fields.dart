import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Thrown when [IpVersion] value falls outside the allowed range [0, 2].
@immutable
class IpVersionError implements Exception {
  final int value;
  const IpVersionError(this.value);

  @override
  String toString() => 'IpVersionError: must be 0-2, got $value';
}

/// Thrown when [Dscp] value falls outside the allowed range [0, 63].
@immutable
class DscpRangeError implements Exception {
  final int value;
  const DscpRangeError(this.value);

  @override
  String toString() => 'DscpRangeError: must be 0-63, got $value';
}

/// Thrown when [Ipv6FlowLabel] value falls outside the allowed range [0, 1048575].
@immutable
class FlowLabelError implements Exception {
  final int value;
  const FlowLabelError(this.value);

  @override
  String toString() => 'FlowLabelError: must be 0-1048575, got $value';
}

/// Thrown when [PortNumber] value falls outside the allowed range [0, 65535].
@immutable
class PortNumberError implements Exception {
  final int value;
  const PortNumberError(this.value);

  @override
  String toString() => 'PortNumberError: must be 0-65535, got $value';
}

/// Thrown when [ProtocolNumber] value falls outside the allowed range [0, 255].
@immutable
class ProtocolNumberError implements Exception {
  final int value;
  const ProtocolNumberError(this.value);

  @override
  String toString() => 'ProtocolNumberError: must be 0-255, got $value';
}

/// Thrown when [AsNumber] value falls outside the allowed range [0, 4294967295].
@immutable
class AsNumberError implements Exception {
  final int value;
  const AsNumberError(this.value);

  @override
  String toString() => 'AsNumberError: must be 0-4294967295, got $value';
}

/// Represents the Internet Protocol version field (0-2) as defined in UML::IpVersion.value.
///
/// [value] must be in the range 0 (unknown) through 2 (IPv6).
@immutable
@realizes(r'UML::IpVersion.value')
class IpVersion {
  static const int minValue = 0;
  static const int maxValue = 2;

  final int value;

  const IpVersion._(this.value);

  IpVersion(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < minValue || v > maxValue) {
      throw IpVersionError(v);
    }
    return v;
  }
}

/// Represents the Differentiated Services Code Point field (0-63) as defined in UML::Dscp.value.
///
/// [value] must be in the range [0, 63].
@immutable
@realizes(r'UML::Dscp.value')
class Dscp {
  static const int minValue = 0;
  static const int maxValue = 63;

  final int value;

  const Dscp._(this.value);

  Dscp(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < minValue || v > maxValue) {
      throw DscpRangeError(v);
    }
    return v;
  }
}

/// Represents the IPv6 Flow Label field (0-1048575) as defined in UML::Ipv6FlowLabel.value.
///
/// [value] must be in the range [0, 1048575].
@immutable
@realizes(r'UML::Ipv6FlowLabel.value')
class Ipv6FlowLabel {
  static const int minValue = 0;
  static const int maxValue = 1048575;

  final int value;

  const Ipv6FlowLabel._(this.value);

  Ipv6FlowLabel(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < minValue || v > maxValue) {
      throw FlowLabelError(v);
    }
    return v;
  }
}

/// Represents a transport-layer port number (0-65535) as defined in UML::PortNumber.value.
///
/// [value] must be in the range [0, 65535].
@immutable
@realizes(r'UML::PortNumber.value')
class PortNumber {
  static const int minValue = 0;
  static const int maxValue = 65535;

  final int value;

  const PortNumber._(this.value);

  PortNumber(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < minValue || v > maxValue) {
      throw PortNumberError(v);
    }
    return v;
  }
}

/// Represents an IP protocol number (0-255) as defined in UML::ProtocolNumber.value.
///
/// [value] must be in the range [0, 255].
@immutable
@realizes(r'UML::ProtocolNumber.value')
class ProtocolNumber {
  static const int minValue = 0;
  static const int maxValue = 255;

  final int value;

  const ProtocolNumber._(this.value);

  ProtocolNumber(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < minValue || v > maxValue) {
      throw ProtocolNumberError(v);
    }
    return v;
  }
}

/// Represents an upper-layer protocol number, extending [ProtocolNumber] with identical range.
@immutable
@realizes(r'UML::UpperLayerProtocolNumber.value')
class UpperLayerProtocolNumber extends ProtocolNumber {
  UpperLayerProtocolNumber(int value) : super(value);
}

/// Represents an Autonomous System number (0-4294967295) as defined in UML::AsNumber.value.
///
/// [value] must be in the range [0, 4294967295] (32-bit unsigned integer).
@immutable
@realizes(r'UML::AsNumber.value')
class AsNumber {
  static const int minValue = 0;
  static const int maxValue = 4294967295;

  final int value;

  const AsNumber._(this.value);

  AsNumber(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < minValue || v > maxValue) {
      throw AsNumberError(v);
    }
    return v;
  }
}
