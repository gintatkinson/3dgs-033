class IpPrefixValidationException implements Exception {
  final String message;

  const IpPrefixValidationException(this.message);

  @override
  String toString() => 'IpPrefixValidationException: $message';
}

class _PrefixBase {
  static final _ipv4Octet =
      r'([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])';
  static final _ipv4Pattern = RegExp(
    '^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\\.){3}'
    '([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'
    '(%.+)?\$',
  );

  static final _h16 = r'[0-9a-fA-F]{1,4}';
  static final _h16Colon = '$_h16:';
  static final _ls32 =
      '$_h16:$_h16|(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])';

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

  static String _stripZone(String value) {
    final idx = value.indexOf('%');
    if (idx == -1) return value;
    return value.substring(0, idx);
  }

  static int _ipv4ToInt(String address) {
    final parts = _stripZone(address).split('.');
    final a = int.parse(parts[0]);
    final b = int.parse(parts[1]);
    final c = int.parse(parts[2]);
    final d = int.parse(parts[3]);
    return (a << 24) | (b << 16) | (c << 8) | d;
  }

  static String _intToIpv4(int value) {
    final a = (value >> 24) & 0xFF;
    final b = (value >> 16) & 0xFF;
    final c = (value >> 8) & 0xFF;
    final d = value & 0xFF;
    return '$a.$b.$c.$d';
  }

  static int _ipv4NetworkMask(int prefixLength) {
    final hostBits = 0xFFFFFFFF >> prefixLength;
    return 0xFFFFFFFF ^ hostBits;
  }

  static String _ipv4ZeroHostBits(String address, int prefixLength) {
    final ipInt = _ipv4ToInt(address);
    final mask = _ipv4NetworkMask(prefixLength);
    final zeroed = ipInt & mask;
    return _intToIpv4(zeroed);
  }

  static BigInt _ipv6ToBigInt(String address) {
    final addr = _stripZone(address).toLowerCase();
    final parts = _expandIpv6(addr);
    BigInt result = BigInt.zero;
    for (int i = 0; i < 8; i++) {
      final group = int.parse(parts[i], radix: 16);
      result = (result << 16) | BigInt.from(group);
    }
    return result;
  }

  static List<String> _expandIpv6(String addr) {
    final parts = <String>[];
    if (addr.contains('::')) {
      final sides = addr.split('::');
      final left =
          sides[0].isEmpty ? <String>[] : sides[0].split(':');
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

  static String _ipv6Canonical(String address) {
    final ipInt = _ipv6ToBigInt(address);
    final groups = <int>[];
    for (int i = 7; i >= 0; i--) {
      groups.add(((ipInt >> (i * 16)) & BigInt.from(0xFFFF)).toInt());
    }
    return _compressIpv6(groups);
  }

  static String _compressIpv6(List<int> groups) {
    int bestStart = -1;
    int bestLen = 0;
    int currentStart = -1;
    int currentLen = 0;

    for (int i = 0; i < 8; i++) {
      if (groups[i] == 0) {
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

    final suppressed = groups.map((v) => v.toRadixString(16)).toList();

    if (bestLen > 1) {
      final left = suppressed.sublist(0, bestStart);
      final right = suppressed.sublist(bestStart + bestLen);
      if (left.isEmpty && right.isEmpty) return '::';
      final leftStr = left.join(':');
      final rightStr = right.join(':');
      if (left.isEmpty) return '::$rightStr';
      if (right.isEmpty) return '$leftStr::';
      return '$leftStr::$rightStr';
    }

    return suppressed.join(':');
  }

  static BigInt _ipv6NetworkMask(int prefixLength) {
    final hostMask = (BigInt.one << (128 - prefixLength)) - BigInt.one;
    final maxValue = (BigInt.one << 128) - BigInt.one;
    return maxValue ^ hostMask;
  }

  static String _ipv6ZeroHostBits(String address, int prefixLength) {
    final ipInt = _ipv6ToBigInt(address);
    final mask = _ipv6NetworkMask(prefixLength);
    final zeroed = ipInt & mask;
    return _ipv6CanonicalFromBigInt(zeroed);
  }

  static String _ipv6CanonicalFromBigInt(BigInt value) {
    final groups = <int>[];
    for (int i = 7; i >= 0; i--) {
      groups.add(((value >> (i * 16)) & BigInt.from(0xFFFF)).toInt());
    }
    return _compressIpv6(groups);
  }

  static (String, int) _splitPrefix(String value) {
    final slashIdx = value.lastIndexOf('/');
    if (slashIdx == -1) {
      throw IpPrefixValidationException(
          'Missing prefix length in: "$value"');
    }
    final address = value.substring(0, slashIdx);
    final lenStr = value.substring(slashIdx + 1);
    final len = int.tryParse(lenStr);
    if (len == null) {
      throw IpPrefixValidationException(
          'Invalid prefix length: "$lenStr"');
    }
    return (address, len);
  }

  static bool _isIpv6Address(String address) {
    return address.contains(':');
  }
}

class Ipv4Prefix {
  final String value;
  final int prefixLength;

  Ipv4Prefix(this.value)
      : prefixLength = _parseAndValidate(value);

  static int _parseAndValidate(String value) {
    final (address, len) = _PrefixBase._splitPrefix(value);
    if (len < 0 || len > 32) {
      throw IpPrefixValidationException(
          'Prefix length must be 0-32, got $len in: "$value"');
    }
    if (!_PrefixBase._ipv4Pattern.hasMatch(address)) {
      throw IpPrefixValidationException(
          'Invalid ipv4-prefix: "$value"');
    }
    return len;
  }

  String toCanonical() {
    final (address, _) = _PrefixBase._splitPrefix(value);
    final zeroed = _PrefixBase._ipv4ZeroHostBits(address, prefixLength);
    return '$zeroed/$prefixLength';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ipv4Prefix &&
          other.value == value &&
          other.prefixLength == prefixLength;

  @override
  int get hashCode => Object.hash(value, prefixLength);
}

class Ipv6Prefix {
  final String value;
  final int prefixLength;

  Ipv6Prefix(this.value)
      : prefixLength = _parseAndValidate(value);

  static int _parseAndValidate(String value) {
    final (address, len) = _PrefixBase._splitPrefix(value);
    if (len < 0 || len > 128) {
      throw IpPrefixValidationException(
          'Prefix length must be 0-128, got $len in: "$value"');
    }
    if (!_PrefixBase._ipv6Pattern.hasMatch(address)) {
      throw IpPrefixValidationException(
          'Invalid ipv6-prefix: "$value"');
    }
    return len;
  }

  String toCanonical() {
    final (address, _) = _PrefixBase._splitPrefix(value);
    final zeroed =
        _PrefixBase._ipv6ZeroHostBits(address, prefixLength);
    return '$zeroed/$prefixLength';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ipv6Prefix &&
          other.value == value &&
          other.prefixLength == prefixLength;

  @override
  int get hashCode => Object.hash(value, prefixLength);
}

class IpPrefix {
  final String value;
  final int prefixLength;
  final bool _isV6;

  IpPrefix._(this.value, this.prefixLength, this._isV6);

  factory IpPrefix.parse(String value) {
    final (address, _) = _PrefixBase._splitPrefix(value);
    if (_PrefixBase._isIpv6Address(address)) {
      final p = Ipv6Prefix(value);
      return IpPrefix._(p.value, p.prefixLength, true);
    } else {
      final p = Ipv4Prefix(value);
      return IpPrefix._(p.value, p.prefixLength, false);
    }
  }

  bool get isV4 => !_isV6;
  bool get isV6 => _isV6;

  String toCanonical() {
    final (address, _) = _PrefixBase._splitPrefix(value);
    if (_isV6) {
      final zeroed =
          _PrefixBase._ipv6ZeroHostBits(address, prefixLength);
      return '$zeroed/$prefixLength';
    }
    final zeroed = _PrefixBase._ipv4ZeroHostBits(address, prefixLength);
    return '$zeroed/$prefixLength';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IpPrefix &&
          other.value == value &&
          other.prefixLength == prefixLength;

  @override
  int get hashCode => Object.hash(value, prefixLength);
}

class Ipv4AddressAndPrefix {
  final String value;
  final int prefixLength;

  Ipv4AddressAndPrefix(this.value)
      : prefixLength = _parseAndValidate(value);

  static int _parseAndValidate(String value) {
    final (address, len) = _PrefixBase._splitPrefix(value);
    if (len < 0 || len > 32) {
      throw IpPrefixValidationException(
          'Prefix length must be 0-32, got $len in: "$value"');
    }
    if (!_PrefixBase._ipv4Pattern.hasMatch(address)) {
      throw IpPrefixValidationException(
          'Invalid ipv4-address-and-prefix: "$value"');
    }
    return len;
  }

  String toCanonical() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ipv4AddressAndPrefix &&
          other.value == value &&
          other.prefixLength == prefixLength;

  @override
  int get hashCode => Object.hash(value, prefixLength);
}

class Ipv6AddressAndPrefix {
  final String value;
  final int prefixLength;

  Ipv6AddressAndPrefix(this.value)
      : prefixLength = _parseAndValidate(value);

  static int _parseAndValidate(String value) {
    final (address, len) = _PrefixBase._splitPrefix(value);
    if (len < 0 || len > 128) {
      throw IpPrefixValidationException(
          'Prefix length must be 0-128, got $len in: "$value"');
    }
    if (!_PrefixBase._ipv6Pattern.hasMatch(address)) {
      throw IpPrefixValidationException(
          'Invalid ipv6-address-and-prefix: "$value"');
    }
    return len;
  }

  String toCanonical() {
    final (address, _) = _PrefixBase._splitPrefix(value);
    final canonical = _PrefixBase._ipv6Canonical(address);
    return '$canonical/$prefixLength';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ipv6AddressAndPrefix &&
          other.value == value &&
          other.prefixLength == prefixLength;

  @override
  int get hashCode => Object.hash(value, prefixLength);
}

class IpAddressAndPrefix {
  final String value;
  final int prefixLength;
  final bool _isV6;

  IpAddressAndPrefix._(this.value, this.prefixLength, this._isV6);

  factory IpAddressAndPrefix.parse(String value) {
    final (address, _) = _PrefixBase._splitPrefix(value);
    if (_PrefixBase._isIpv6Address(address)) {
      final p = Ipv6AddressAndPrefix(value);
      return IpAddressAndPrefix._(p.value, p.prefixLength, true);
    } else {
      final p = Ipv4AddressAndPrefix(value);
      return IpAddressAndPrefix._(p.value, p.prefixLength, false);
    }
  }

  bool get isV4 => !_isV6;
  bool get isV6 => _isV6;

  String toCanonical() {
    if (_isV6) {
      final (address, _) = _PrefixBase._splitPrefix(value);
      final canonical = _PrefixBase._ipv6Canonical(address);
      return '$canonical/$prefixLength';
    }
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IpAddressAndPrefix &&
          other.value == value &&
          other.prefixLength == prefixLength;

  @override
  int get hashCode => Object.hash(value, prefixLength);
}
