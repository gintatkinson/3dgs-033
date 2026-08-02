class IpAddressValidationException implements Exception {
  final String message;

  const IpAddressValidationException(this.message);

  @override
  String toString() => 'IpAddressValidationException: $message';
}

class _IpAddressBase {
  static final _ipv4Octet =
      r'([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])';
  static final _ipv4Pattern = RegExp(
    '^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\\.){3}'
    '([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'
    '(%.+)?\$',
  );
  static final _ipv4NoZonePattern = RegExp(
    '^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\\.){3}'
    '([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\$',
  );

  static final _h16 = r'[0-9a-fA-F]{1,4}';
  static final _h16Colon = '$_h16:';
  static final _ls32 = '$_h16:$_h16|(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])';

  static final _ipv6Pattern = RegExp(
    '^((($_h16Colon){6}$_ls32)|'
    '(::($_h16Colon){5}$_ls32)|'
    '($_h16Colon?::($_h16Colon){4}$_ls32)|'
    '((($_h16Colon){0,1}$_h16)?::($_h16Colon){3}$_ls32)|'
    '((($_h16Colon){0,2}$_h16)?::($_h16Colon){2}$_ls32)|'
    '((($_h16Colon){0,3}$_h16)?::$_h16Colon$_ls32)|'
    '((($_h16Colon){0,4}$_h16)?::$_ls32)|'
    '((($_h16Colon){0,5}$_h16)?::$_h16)|'
    '((($_h16Colon){0,6}$_h16)?::))'
    '(%.+)?\$',
  );

  static final _ipv6NoZonePattern = RegExp(
    '^((($_h16Colon){6}$_ls32)|'
    '(::($_h16Colon){5}$_ls32)|'
    '($_h16Colon?::($_h16Colon){4}$_ls32)|'
    '((($_h16Colon){0,1}$_h16)?::($_h16Colon){3}$_ls32)|'
    '((($_h16Colon){0,2}$_h16)?::($_h16Colon){2}$_ls32)|'
    '((($_h16Colon){0,3}$_h16)?::$_h16Colon$_ls32)|'
    '((($_h16Colon){0,4}$_h16)?::$_ls32)|'
    '((($_h16Colon){0,5}$_h16)?::$_h16)|'
    '((($_h16Colon){0,6}$_h16)?::))\$',
  );

  static String? _extractZone(String value) {
    final idx = value.indexOf('%');
    if (idx == -1) return null;
    return value.substring(idx + 1);
  }

  static String _stripZone(String value) {
    final idx = value.indexOf('%');
    if (idx == -1) return value;
    return value.substring(0, idx);
  }

  static String _ipv6Canonical(String address) {
    final addr = _stripZone(address).toLowerCase();
    final parts = _expandIpv6(addr);

    // Longest zero run compression
    int bestStart = -1;
    int bestLen = 0;
    int currentStart = -1;
    int currentLen = 0;

    for (int i = 0; i < 8; i++) {
      if (int.parse(parts[i], radix: 16) == 0) {
        if (currentStart == -1) currentStart = i;
        currentLen++;
      } else {
        if (currentLen > bestLen) {
          bestStart = currentStart;
          bestLen = currentLen;
        }
        currentStart = -1;
        currentLen = 0;
      }
    }
    if (currentLen > bestLen) {
      bestStart = currentStart;
      bestLen = currentLen;
    }

    if (bestLen > 1) {
      final left = parts.sublist(0, bestStart).map(_suppressLeadingZeros).join(':');
      final right = parts.sublist(bestStart + bestLen).map(_suppressLeadingZeros).join(':');
      if (left.isEmpty && right.isEmpty) return '::';
      if (left.isEmpty) return '::$right';
      if (right.isEmpty) return '$left::';
      return '$left::$right';
    }

    return parts.map(_suppressLeadingZeros).join(':');
  }

  static List<String> _expandIpv6(String addr) {
    final parts = <String>[];
    if (addr.contains('::')) {
      final sides = addr.split('::');
      final left = sides[0].isEmpty ? <String>[] : sides[0].split(':');
      final right = sides.length > 1 && sides[1].isNotEmpty
          ? sides[1].split(':')
          : <String>[];
      final missing = 8 - left.length - right.length;
      parts.addAll(left);
      for (int i = 0; i < missing; i++) {
        parts.add('0');
      }
      parts.addAll(right);
    } else {
      parts.addAll(addr.split(':'));
    }
    return parts;
  }

  static String _suppressLeadingZeros(String group) {
    if (group == '0') return '0';
    final stripped = group.replaceFirst(RegExp(r'^0+'), '');
    return stripped.isEmpty ? '0' : stripped;
  }

  static bool _isIpv4(String value) {
    return _ipv4Pattern.hasMatch(value);
  }

  static bool _isIpv4LinkLocal(String value) {
    final addr = _stripZone(value);
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)\.(\d+)$').firstMatch(addr);
    if (match == null) return false;
    final a = int.parse(match.group(1)!);
    final b = int.parse(match.group(2)!);
    return a == 169 && b == 254;
  }
}

class Ipv4Address {
  final String value;

  Ipv4Address(this.value) {
    if (!_IpAddressBase._ipv4Pattern.hasMatch(value)) {
      throw IpAddressValidationException('Invalid ipv4-address: "$value"');
    }
  }

  String? get zoneIndex => _IpAddressBase._extractZone(value);

  String toCanonical() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Ipv4Address && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class Ipv6Address {
  final String value;

  Ipv6Address(this.value) {
    if (!_IpAddressBase._ipv6Pattern.hasMatch(value)) {
      throw IpAddressValidationException('Invalid ipv6-address: "$value"');
    }
  }

  String? get zoneIndex => _IpAddressBase._extractZone(value);

  String toCanonical() {
    final canonical = _IpAddressBase._ipv6Canonical(value);
    final zone = zoneIndex;
    if (zone != null) return '$canonical%$zone';
    return canonical;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Ipv6Address && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class IpAddress {
  final String value;
  final bool _isV6;

  IpAddress(this.value)
      : _isV6 = value.contains(':') {
    if (_isV6) {
      if (!_IpAddressBase._ipv6Pattern.hasMatch(value)) {
        throw IpAddressValidationException('Invalid ip-address: "$value"');
      }
    } else {
      if (!_IpAddressBase._ipv4Pattern.hasMatch(value)) {
        throw IpAddressValidationException('Invalid ip-address: "$value"');
      }
    }
  }

  factory IpAddress.parse(String value) => IpAddress(value);

  String? get zoneIndex => _IpAddressBase._extractZone(value);

  String toCanonical() {
    if (_isV6) return _IpAddressBase._ipv6Canonical(value);
    return value;
  }

  bool get isV4 => !_isV6;
  bool get isV6 => _isV6;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is IpAddress && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class IpAddressNoZone {
  final String value;
  final bool _isV6;

  IpAddressNoZone(this.value)
      : _isV6 = value.contains(':') {
    if (value.contains('%')) {
      throw IpAddressValidationException(
          'zone index not allowed in ip-address-no-zone: "$value"');
    }
    if (_isV6) {
      if (!_IpAddressBase._ipv6NoZonePattern.hasMatch(value)) {
        throw IpAddressValidationException(
            'Invalid ip-address-no-zone: "$value"');
      }
    } else {
      if (!_IpAddressBase._ipv4NoZonePattern.hasMatch(value)) {
        throw IpAddressValidationException(
            'Invalid ip-address-no-zone: "$value"');
      }
    }
  }

  String? get zoneIndex => null;

  String toCanonical() {
    if (_isV6) return _IpAddressBase._ipv6Canonical(value);
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IpAddressNoZone && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class Ipv4AddressNoZone {
  final String value;

  Ipv4AddressNoZone(this.value) {
    if (value.contains('%')) {
      throw IpAddressValidationException(
          'zone index not allowed in ipv4-address-no-zone: "$value"');
    }
    if (!_IpAddressBase._ipv4NoZonePattern.hasMatch(value)) {
      throw IpAddressValidationException(
          'Invalid ipv4-address-no-zone: "$value"');
    }
  }

  String? get zoneIndex => null;

  String toCanonical() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ipv4AddressNoZone && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class Ipv6AddressNoZone {
  final String value;

  Ipv6AddressNoZone(this.value) {
    if (value.contains('%')) {
      throw IpAddressValidationException(
          'zone index not allowed in ipv6-address-no-zone: "$value"');
    }
    if (!_IpAddressBase._ipv6NoZonePattern.hasMatch(value)) {
      throw IpAddressValidationException(
          'Invalid ipv6-address-no-zone: "$value"');
    }
  }

  String? get zoneIndex => null;

  String toCanonical() => _IpAddressBase._ipv6Canonical(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ipv6AddressNoZone && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class IpAddressLinkLocal {
  final String value;
  final bool _isV6;

  IpAddressLinkLocal(this.value)
      : _isV6 = value.contains(':') {
    if (_isV6) {
      if (!_IpAddressBase._ipv6Pattern.hasMatch(value)) {
        throw IpAddressValidationException(
            'Invalid ip-address-link-local: "$value"');
      }
      final addr = _IpAddressBase._stripZone(value).toLowerCase();
      if (!addr.startsWith('fe80:')) {
        throw IpAddressValidationException(
            'Not a link-local IPv6 address: "$value"');
      }
    } else {
      if (!_IpAddressBase._ipv4Pattern.hasMatch(value)) {
        throw IpAddressValidationException(
            'Invalid ip-address-link-local: "$value"');
      }
      if (!_IpAddressBase._isIpv4LinkLocal(value)) {
        throw IpAddressValidationException(
            'Not a link-local IPv4 address: "$value"');
      }
    }
  }

  String? get zoneIndex => _IpAddressBase._extractZone(value);

  String toCanonical() {
    if (_isV6) return _IpAddressBase._ipv6Canonical(value);
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IpAddressLinkLocal && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class Ipv4AddressLinkLocal {
  final String value;

  Ipv4AddressLinkLocal(this.value) {
    if (!_IpAddressBase._ipv4Pattern.hasMatch(value)) {
      throw IpAddressValidationException(
          'Invalid ipv4-address-link-local: "$value"');
    }
    if (!_IpAddressBase._isIpv4LinkLocal(value)) {
      throw IpAddressValidationException(
          'Not a link-local IPv4 address: "$value"');
    }
  }

  String? get zoneIndex => _IpAddressBase._extractZone(value);

  String toCanonical() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ipv4AddressLinkLocal && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class Ipv6AddressLinkLocal {
  final String value;

  Ipv6AddressLinkLocal(this.value) {
    if (!_IpAddressBase._ipv6Pattern.hasMatch(value)) {
      throw IpAddressValidationException(
          'Invalid ipv6-address-link-local: "$value"');
    }
    final addr = _IpAddressBase._stripZone(value).toLowerCase();
    if (!addr.startsWith('fe80:')) {
      throw IpAddressValidationException(
          'Not a link-local IPv6 address: "$value"');
    }
  }

  String? get zoneIndex => _IpAddressBase._extractZone(value);

  String toCanonical() => _IpAddressBase._ipv6Canonical(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ipv6AddressLinkLocal && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
