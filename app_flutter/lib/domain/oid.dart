import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Error thrown when an OID sub-identifier has an invalid format.
///
/// [section] identifies which validation rule failed (e.g. "first-subid",
/// "second-subid", "subid-overflow", "whitespace", "non-numeric", "negative-subid").
/// [value] is the offending value that triggered the error.
@immutable
class OidFormatError implements Exception {
  final String section;
  final int value;

  const OidFormatError({required this.section, required this.value});

  @override
  String toString() => 'OidFormatError: $section invalid with value $value';
}

/// Error thrown when the OID has an invalid number of sub-identifiers.
///
/// [count] is the actual number of sub-identifiers.
/// [max] is the required bound (minimum or maximum depending on context).
@immutable
class OidLengthError implements Exception {
  final int count;
  final int max;

  const OidLengthError({required this.count, required this.max});

  @override
  String toString() => 'OidLengthError: count $count exceeds bound $max';
}

/// Represents an administratively assigned name in a registration-hierarchical-name
/// tree (OID tree) per ASN.1 constraints.
///
/// Sub-identifiers are separated by dots. The first sub-identifier must be 0, 1, or 2.
/// When the first is 0 or 1, the second must be in the range 0..39.
/// At least two sub-identifiers are required; each must not exceed 2^32-1.
@immutable
@realizes(r'UML::ObjectIdentifier.value')
sealed class OidValue {
  static const int _maxSubId = 4294967295;

  /// The sequence of OID sub-identifiers.
  final List<int> subIdentifiers;

  const OidValue._(this.subIdentifiers);

  /// Creates an [OidValue] from a list of sub-identifier values.
  ///
  /// Throws [OidFormatError] if sub-identifier values violate ASN.1 constraints.
  /// Throws [OidLengthError] if fewer than two sub-identifiers or more than 128
  /// sub-identifiers are provided.
  factory OidValue(List<int> subIdentifiers) {
    _validate(subIdentifiers);
    _validateMax128(subIdentifiers);
    return Oid128._raw(subIdentifiers);
  }

  /// Creates an [OidValue] from a dotted decimal string.
  ///
  /// Throws [OidFormatError] if the string contains whitespace, non-numeric values,
  /// or sub-identifier values that violate ASN.1 constraints.
  /// Throws [OidLengthError] if fewer than two sub-identifiers or more than 128
  /// sub-identifiers are present.
  factory OidValue.parse(String oid) {
    if (oid.contains(' ')) {
      throw const OidFormatError(section: 'whitespace', value: 0);
    }

    final partsStr = oid.split('.');
    final parts = <int>[];
    for (final part in partsStr) {
      final parsed = int.tryParse(part);
      if (parsed == null) {
        throw const OidFormatError(section: 'non-numeric', value: 0);
      }
      parts.add(parsed);
    }

    _validate(parts);
    _validateMax128(parts);
    return Oid128._raw(List<int>.unmodifiable(parts));
  }

  static void _validate(List<int> subIds) {
    if (subIds.length < 2) {
      throw OidLengthError(count: subIds.length, max: 2);
    }

    final first = subIds[0];
    if (first != 0 && first != 1 && first != 2) {
      throw OidFormatError(section: 'first-subid', value: first);
    }

    final second = subIds[1];
    if ((first == 0 || first == 1) && second > 39) {
      throw OidFormatError(section: 'second-subid', value: second);
    }

    for (int i = 0; i < subIds.length; i++) {
      if (subIds[i] < 0) {
        throw OidFormatError(section: 'negative-subid', value: subIds[i]);
      }
      if (subIds[i] > _maxSubId) {
        throw OidFormatError(section: 'subid-overflow', value: subIds[i]);
      }
    }
  }

  static void _validateMax128(List<int> subIds) {
    if (subIds.length > 128) {
      throw OidLengthError(count: subIds.length, max: 128);
    }
  }

  /// Returns `true` if this OID is an ancestor of [other] in the OID tree.
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

  /// Creates a copy of this [OidValue] with optionally modified fields.
  OidValue copyWith({List<int>? subIdentifiers});

  @override
  String toString() => subIdentifiers.join('.');
}

/// Represents an OID restricted to a maximum of 128 sub-identifiers
/// for SMIv2 compatibility.
@immutable
@realizes(r'UML::ObjectIdentifier128.value')
final class Oid128 extends OidValue {
  static const int maxSubIds = 128;

  const Oid128._raw(List<int> subIdentifiers) : super._(subIdentifiers);

  /// Creates an [Oid128] from a list of sub-identifier values.
  ///
  /// Throws [OidLengthError] if more than 128 sub-identifiers are provided.
  /// Throws [OidFormatError] if sub-identifier values violate ASN.1 constraints.
  factory Oid128(List<int> subIdentifiers) {
    OidValue._validate(subIdentifiers);
    OidValue._validateMax128(subIdentifiers);
    return Oid128._raw(List<int>.unmodifiable(subIdentifiers));
  }

  /// Creates an [Oid128] from a dotted decimal string.
  ///
  /// Throws [OidLengthError] if more than 128 sub-identifiers are present.
  /// Throws [OidFormatError] if the string format or values are invalid.
  factory Oid128.parse(String oid) {
    if (oid.contains(' ')) {
      throw const OidFormatError(section: 'whitespace', value: 0);
    }

    final partsStr = oid.split('.');
    final parts = <int>[];
    for (final part in partsStr) {
      final parsed = int.tryParse(part);
      if (parsed == null) {
        throw const OidFormatError(section: 'non-numeric', value: 0);
      }
      parts.add(parsed);
    }

    OidValue._validate(parts);
    OidValue._validateMax128(parts);

    return Oid128._raw(List<int>.unmodifiable(parts));
  }

  @override
  Oid128 copyWith({List<int>? subIdentifiers}) {
    return Oid128._raw(List<int>.unmodifiable(
        subIdentifiers ?? List<int>.of(this.subIdentifiers)));
  }
}
