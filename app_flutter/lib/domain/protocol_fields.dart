class ProtocolFieldValidationException implements Exception {
  final String message;

  const ProtocolFieldValidationException(this.message);

  @override
  String toString() => 'ProtocolFieldValidationException: $message';
}

class IpVersion {
  static const int minValue = 0;
  static const int maxValue = 2;

  final int value;

  const IpVersion._(this.value);

  IpVersion(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < minValue || v > maxValue) {
      throw ProtocolFieldValidationException(
        'IpVersion must be $minValue-$maxValue, got $v',
      );
    }
    return v;
  }
}

class Dscp {
  static const int minValue = 0;
  static const int maxValue = 63;

  final int value;

  const Dscp._(this.value);

  Dscp(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < minValue || v > maxValue) {
      throw ProtocolFieldValidationException(
        'Dscp must be $minValue-$maxValue, got $v',
      );
    }
    return v;
  }
}

class Ipv6FlowLabel {
  static const int minValue = 0;
  static const int maxValue = 1048575;

  final int value;

  const Ipv6FlowLabel._(this.value);

  Ipv6FlowLabel(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < minValue || v > maxValue) {
      throw ProtocolFieldValidationException(
        'Ipv6FlowLabel must be $minValue-$maxValue, got $v',
      );
    }
    return v;
  }
}

class PortNumber {
  static const int minValue = 0;
  static const int maxValue = 65535;

  final int value;

  const PortNumber._(this.value);

  PortNumber(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < minValue || v > maxValue) {
      throw ProtocolFieldValidationException(
        'PortNumber must be $minValue-$maxValue, got $v',
      );
    }
    return v;
  }
}

class ProtocolNumber {
  static const int minValue = 0;
  static const int maxValue = 255;

  final int value;

  const ProtocolNumber._(this.value);

  ProtocolNumber(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < minValue || v > maxValue) {
      throw ProtocolFieldValidationException(
        'ProtocolNumber must be $minValue-$maxValue, got $v',
      );
    }
    return v;
  }
}

class UpperLayerProtocolNumber extends ProtocolNumber {
  UpperLayerProtocolNumber(int value) : super(value);
}

class AsNumber {
  static const int minValue = 0;
  static const int maxValue = 4294967295;

  final int value;

  const AsNumber._(this.value);

  AsNumber(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < minValue || v > maxValue) {
      throw ProtocolFieldValidationException(
        'AsNumber must be $minValue-$maxValue, got $v',
      );
    }
    return v;
  }
}
