class OidValidationException implements Exception {
  final String message;

  const OidValidationException(this.message);

  @override
  String toString() => 'OidValidationException: $message';
}

class OidValue {
  static const int _maxSubId = 4294967295;

  final List<int> subIdentifiers;

  OidValue(this.subIdentifiers) {
    _validate(subIdentifiers);
  }

  factory OidValue.parse(String oid) {
    if (oid.contains(' ')) {
      throw const OidValidationException(
        'OID must not contain whitespace between sub-identifiers',
      );
    }

    final partsStr = oid.split('.');
    final parts = <int>[];
    for (final part in partsStr) {
      final parsed = int.tryParse(part);
      if (parsed == null) {
        throw OidValidationException(
          'Invalid sub-identifier: "$part" in OID "$oid"',
        );
      }
      parts.add(parsed);
    }

    return OidValue(parts);
  }

  static void _validate(List<int> subIds) {
    if (subIds.length < 2) {
      throw const OidValidationException(
        'OID must have at least two sub-identifiers',
      );
    }

    final first = subIds[0];
    if (first != 0 && first != 1 && first != 2) {
      throw OidValidationException(
        'First sub-identifier must be 0, 1, or 2, got $first',
      );
    }

    final second = subIds[1];
    if ((first == 0 || first == 1) && second > 39) {
      throw OidValidationException(
        'Second sub-identifier must be in range 0..39 when first is 0 or 1, got $second',
      );
    }

    for (int i = 0; i < subIds.length; i++) {
      if (subIds[i] < 0) {
        throw OidValidationException(
          'Sub-identifier at index $i must be non-negative, got ${subIds[i]}',
        );
      }
      if (subIds[i] > _maxSubId) {
        throw OidValidationException(
          'Sub-identifier at index $i exceeds maximum value $_maxSubId, got ${subIds[i]}',
        );
      }
    }
  }

  bool isAncestorOf(OidValue other) {
    if (subIdentifiers.length >= other.subIdentifiers.length) {
      return false;
    }
    for (int i = 0; i < subIdentifiers.length; i++) {
      if (subIdentifiers[i] != other.subIdentifiers[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() => subIdentifiers.join('.');
}

class Oid128 extends OidValue {
  static const int _maxSubIds = 128;

  Oid128(super.subIdentifiers) {
    if (subIdentifiers.length > _maxSubIds) {
      throw OidValidationException(
        'object-identifier-128 must not exceed $_maxSubIds sub-identifiers, '
        'got ${subIdentifiers.length}',
      );
    }
  }

  factory Oid128.parse(String oid) {
    final oidValue = OidValue.parse(oid);
    if (oidValue.subIdentifiers.length > _maxSubIds) {
      throw OidValidationException(
        'object-identifier-128 must not exceed $_maxSubIds sub-identifiers, '
        'got ${oidValue.subIdentifiers.length}',
      );
    }
    return Oid128(oidValue.subIdentifiers);
  }
}
