class AddressStringValidationException implements Exception {
  final String message;

  const AddressStringValidationException(this.message);

  @override
  String toString() => 'AddressStringValidationException: $message';
}

class PhysAddress {
  static final _pattern = RegExp(r'^([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?$');

  final String value;

  PhysAddress(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw AddressStringValidationException(
        'Invalid phys-address: "$value"',
      );
    }
  }
}

class MacAddress {
  static final _pattern = RegExp(r'^[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}$');

  final String value;

  MacAddress(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw AddressStringValidationException(
        'Invalid mac-address: "$value"',
      );
    }
  }
}

class Xpath10 {
  final String value;

  const Xpath10(this.value);
}

class HexString {
  static final _pattern = RegExp(r'^([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?$');

  final String value;

  HexString(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw AddressStringValidationException(
        'Invalid hex-string: "$value"',
      );
    }
  }
}

class Uuid {
  static final _pattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  final String value;

  Uuid(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw AddressStringValidationException(
        'Invalid uuid: "$value"',
      );
    }
  }
}

class DottedQuad {
  static final _pattern = RegExp(
    r'^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$',
  );

  final String value;

  DottedQuad(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw AddressStringValidationException(
        'Invalid dotted-quad: "$value"',
      );
    }
  }
}

class LanguageTag {
  static final _pattern = RegExp(
    r'^[a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*$',
  );

  final String value;

  LanguageTag(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw AddressStringValidationException(
        'Invalid language-tag: "$value"',
      );
    }
  }
}

class YangIdentifier {
  static final _pattern = RegExp(r'^[a-zA-Z_][a-zA-Z0-9\-_.]*$');

  final String value;

  YangIdentifier(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw AddressStringValidationException(
        'Invalid yang-identifier: "$value"',
      );
    }
  }
}
