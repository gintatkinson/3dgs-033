import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Error thrown when a MAC address or hex octet string has an invalid format.
@immutable
class MacAddressFormatError implements Exception {
  final String message;

  const MacAddressFormatError(this.message);

  @override
  String toString() => 'MacAddressFormatError: $message';
}

/// Error thrown when a UUID string does not conform to RFC 9562 format.
@immutable
class UuidFormatError implements Exception {
  final String message;

  const UuidFormatError(this.message);

  @override
  String toString() => 'UuidFormatError: $message';
}

/// Error thrown when a dotted-quad IPv4 string has octets out of range.
@immutable
class DottedQuadFormatError implements Exception {
  final String message;

  const DottedQuadFormatError(this.message);

  @override
  String toString() => 'DottedQuadFormatError: $message';
}

/// Error thrown when a language tag does not conform to BCP 47.
@immutable
class LanguageTagFormatError implements Exception {
  final String message;

  const LanguageTagFormatError(this.message);

  @override
  String toString() => 'LanguageTagFormatError: $message';
}

/// Represents a media- or physical-level address as a sequence of hex octets
/// separated by colons. Empty string is allowed for optional addresses.
@immutable
@realizes(r'UML::PhysAddress.value')
class PhysAddress {
  static final _pattern = RegExp(r'^([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?$');

  final String value;

  PhysAddress(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw MacAddressFormatError('Invalid phys-address: "$value"');
    }
  }

  /// Creates a copy with an optionally modified value.
  PhysAddress copyWith({String? value}) {
    return PhysAddress(value ?? this.value);
  }
}

/// Represents a 48-bit IEEE 802 MAC address as six colon-separated hex octets.
@immutable
@realizes(r'UML::MacAddress.value')
class MacAddress {
  static final _pattern = RegExp(r'^[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}$');

  final String value;

  MacAddress(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw MacAddressFormatError('Invalid mac-address: "$value"');
    }
  }

  /// Creates a copy with an optionally modified value.
  MacAddress copyWith({String? value}) {
    return MacAddress(value ?? this.value);
  }
}

/// Represents an XPath 1.0 expression string.
@immutable
@realizes(r'UML::Xpath10.value')
class Xpath10 {
  final String value;

  const Xpath10(this.value);

  /// Creates a copy with an optionally modified value.
  Xpath10 copyWith({String? value}) {
    return Xpath10(value ?? this.value);
  }
}

/// Represents a hex-encoded octet string separated by colons.
/// Empty string is allowed for optional values.
@immutable
@realizes(r'UML::HexString.value')
class HexString {
  static final _pattern = RegExp(r'^([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?$');

  final String value;

  HexString(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw MacAddressFormatError('Invalid hex-string: "$value"');
    }
  }

  /// Creates a copy with an optionally modified value.
  HexString copyWith({String? value}) {
    return HexString(value ?? this.value);
  }
}

/// Represents a Universally Unique Identifier in the string representation
/// defined in RFC 9562.
@immutable
@realizes(r'UML::Uuid.value')
class Uuid {
  static final _pattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  final String value;

  Uuid(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw UuidFormatError('Invalid uuid: "$value"');
    }
  }

  /// Creates a copy with an optionally modified value.
  Uuid copyWith({String? value}) {
    return Uuid(value ?? this.value);
  }
}

/// Represents an unsigned 32-bit number expressed in dotted-quad notation
/// (four octets written as decimal numbers separated by dots).
@immutable
@realizes(r'UML::DottedQuad.value')
class DottedQuad {
  static final _pattern = RegExp(
    r'^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$',
  );

  final String value;

  DottedQuad(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw DottedQuadFormatError('Invalid dotted-quad: "$value"');
    }
  }

  /// Creates a copy with an optionally modified value.
  DottedQuad copyWith({String? value}) {
    return DottedQuad(value ?? this.value);
  }
}

/// Represents a BCP 47 language tag (RFC 5646).
@immutable
@realizes(r'UML::LanguageTag.value')
class LanguageTag {
  static final _pattern = RegExp(
    r'^[a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*$',
  );

  final String value;

  LanguageTag(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw LanguageTagFormatError('Invalid language-tag: "$value"');
    }
  }

  /// Creates a copy with an optionally modified value.
  LanguageTag copyWith({String? value}) {
    return LanguageTag(value ?? this.value);
  }
}

/// Represents a YANG identifier string as defined by the 'identifier' rule
/// in RFC 7950 Section 14.
@immutable
@realizes(r'UML::YangIdentifier.value')
class YangIdentifier {
  static final _pattern = RegExp(r'^[a-zA-Z_][a-zA-Z0-9\-_.]*$');

  final String value;

  YangIdentifier(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw LanguageTagFormatError('Invalid yang-identifier: "$value"');
    }
  }

  /// Creates a copy with an optionally modified value.
  YangIdentifier copyWith({String? value}) {
    return YangIdentifier(value ?? this.value);
  }
}
