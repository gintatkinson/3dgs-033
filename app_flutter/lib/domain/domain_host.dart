import 'package:app_flutter/domain/annotations.dart';
import 'package:app_flutter/domain/ip_address.dart';
import 'package:meta/meta.dart';

/// Thrown when a domain name or host name fails format validation.
@immutable
class DomainFormatError implements Exception {
  final String message;
  const DomainFormatError(this.message);

  @override
  String toString() => 'DomainFormatError: $message';
}

/// Thrown when a URI fails format validation.
@immutable
class UriFormatError implements Exception {
  final String message;
  const UriFormatError(this.message);

  @override
  String toString() => 'UriFormatError: $message';
}

/// Thrown when an email address fails format validation.
@immutable
class EmailFormatError implements Exception {
  final String message;
  const EmailFormatError(this.message);

  @override
  String toString() => 'EmailFormatError: $message';
}

/// Thrown when a [Host] input cannot be parsed as either an IP address or a host name.
@immutable
class HostParseError implements Exception {
  final String value;
  const HostParseError(this.value);

  @override
  String toString() => 'HostParseError: invalid host: "$value"';
}

/// Represents a fully-qualified domain name as defined in UML::DomainName.value.
@immutable
@realizes(r'UML::DomainName.value')
class DomainName {
  static const int _totalLengthMax = 253;
  static const int _labelLengthMax = 63;

  static final _labelHead = r'[a-zA-Z0-9_]';
  static final _labelMiddle = r'[a-zA-Z0-9\-_]*';
  static final _labelTail = r'[a-zA-Z0-9_]';
  static final _singleCharLabel = RegExp('^$_labelHead\$');
  static final _multiCharLabel =
      RegExp('^$_labelHead$_labelMiddle$_labelTail\$');

  final String value;

  DomainName(this.value) {
    _validate(value);
  }

  static void _validate(String v) {
    if (v.isEmpty) {
      throw const DomainFormatError('Domain name must not be empty');
    }
    if (v.length > _totalLengthMax) {
      throw DomainFormatError(
          'Domain name exceeds 253 characters, got ${v.length}');
    }
    if (v.endsWith('.')) {
      throw DomainFormatError(
          'Domain name must not include trailing dot: "$v"');
    }
    final labels = v.split('.');
    for (final label in labels) {
      if (label.isEmpty) {
        throw DomainFormatError('Empty label in domain name: "$v"');
      }
      if (label.length > _labelLengthMax) {
        throw DomainFormatError(
            'Label exceeds 63 characters: "$label" in "$v"');
      }
      if (label.length > 1) {
        if (!_multiCharLabel.hasMatch(label)) {
          throw DomainFormatError('Invalid label: "$label" in "$v"');
        }
      } else {
        if (!_singleCharLabel.hasMatch(label)) {
          throw DomainFormatError(
              'Invalid single-character label: "$label" in "$v"');
        }
      }
    }
  }

  String toCanonical() => value.toLowerCase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DomainName && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Represents a host name (without trailing dot) as defined in UML::HostName.value.
@immutable
@realizes(r'UML::HostName.value')
class HostName {
  static const int _totalLengthMin = 2;

  static final _labelHead = r'[a-zA-Z0-9]';
  static final _labelMiddle = r'[a-zA-Z0-9\-]*';
  static final _labelTail = r'[a-zA-Z0-9]';
  static final _singleCharLabel = RegExp('^$_labelHead\$');
  static final _multiCharLabel =
      RegExp('^$_labelHead$_labelMiddle$_labelTail\$');

  final String value;

  HostName(this.value) {
    _validate(value);
  }

  static void _validate(String v) {
    if (v.length < _totalLengthMin) {
      throw DomainFormatError(
          'Host name must be at least $_totalLengthMin characters, got "${v.length}": "$v"');
    }
    final labels = v.split('.');
    for (final label in labels) {
      if (label.isEmpty) {
        throw DomainFormatError('Empty label in host name: "$v"');
      }
      if (label.length > DomainName._labelLengthMax) {
        throw DomainFormatError(
            'Label exceeds 63 characters: "$label" in "$v"');
      }
      if (label.length > 1) {
        if (!_multiCharLabel.hasMatch(label)) {
          throw DomainFormatError('Invalid label: "$label" in "$v"');
        }
      } else {
        if (!_singleCharLabel.hasMatch(label)) {
          throw DomainFormatError(
              'Invalid single-character label: "$label" in "$v"');
        }
      }
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is HostName && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Represents a host that is either an IP address or a host name as defined in UML::Host.value.
@immutable
@realizes(r'UML::Host.value')
class Host {
  final String value;
  final bool _isIp;
  final bool _isHostName;

  Host._(this.value, this._isIp, this._isHostName);

  /// Parses a host string, detecting whether it is an IP address or host name.
  ///
  /// Throws [HostParseError] if the value is neither a valid IP address nor a valid host name.
  factory Host.parse(String value) {
    if (value.isEmpty) {
      throw const HostParseError('');
    }

    bool isIp = false;
    try {
      IpAddress.parse(value);
      isIp = true;
    } on Ipv4FormatError {
      isIp = false;
    } on Ipv6FormatError {
      isIp = false;
    }

    if (isIp) {
      return Host._(value, true, false);
    }

    try {
      HostName(value);
      return Host._(value, false, true);
    } on DomainFormatError {
      throw HostParseError(value);
    }
  }

  bool get isIp => _isIp;
  bool get isHostName => _isHostName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Host && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Represents a URI as defined in UML::Uri.value.
@immutable
@realizes(r'UML::Uri.value')
class Uri {
  static final _schemePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*$');

  final String value;

  Uri(String raw) : value = _init(raw);

  static String _init(String raw) {
    _validate(raw);
    return _normalize(raw);
  }

  static void _validate(String v) {
    if (v.isEmpty) {
      throw const UriFormatError('URI must not be empty');
    }

    final colonIdx = v.indexOf(':');
    if (colonIdx == -1) {
      throw UriFormatError('URI must contain a scheme (e.g. "https:"): "$v"');
    }

    final scheme = v.substring(0, colonIdx);
    if (scheme.isEmpty) {
      throw UriFormatError('URI scheme must not be empty: "$v"');
    }
    if (!_schemePattern.hasMatch(scheme)) {
      throw UriFormatError(
          'URI scheme must start with a letter and contain only [a-zA-Z0-9+.-]: "$scheme" in "$v"');
    }
  }

  static String _normalizePercentEncoding(String v) {
    return v.replaceAllMapped(
      RegExp(r'%[0-9a-fA-F]{2}'),
      (m) => m.group(0)!.toUpperCase(),
    );
  }

  static int _minPositive(int a, int b, int fallback) {
    if (a != -1 && b != -1) return a < b ? a : b;
    if (a != -1) return a;
    if (b != -1) return b;
    return fallback;
  }

  static String _normalize(String v) {
    final schemeEnd = v.indexOf(':');
    if (schemeEnd == -1) return v;

    final scheme = v.substring(0, schemeEnd).toLowerCase();
    final rest = v.substring(schemeEnd + 1);

    final sb = StringBuffer();
    sb.write(scheme);
    sb.write(':');

    if (rest.startsWith('//')) {
      final authStart = 2;
      final pathStart = rest.indexOf('/', authStart);
      final queryStart = rest.indexOf('?', authStart);
      final fragmentStart = rest.indexOf('#', authStart);

      int authEnd = rest.length;
      for (final pos in [pathStart, queryStart, fragmentStart]) {
        if (pos != -1 && pos < authEnd) authEnd = pos;
      }

      final authority = rest.substring(authStart, authEnd);
      final hostPortSep = authority.lastIndexOf(':');
      String hostPart;
      String portPart;
      if (hostPortSep != -1) {
        final afterColon = authority.substring(hostPortSep + 1);
        if (int.tryParse(afterColon) != null) {
          hostPart = authority.substring(0, hostPortSep).toLowerCase();
          portPart = afterColon;
        } else {
          hostPart = authority.toLowerCase();
          portPart = '';
        }
      } else {
        hostPart = authority.toLowerCase();
        portPart = '';
      }

      sb.write('//');
      sb.write(hostPart);
      if (portPart.isNotEmpty) {
        sb.write(':');
        sb.write(portPart);
      }

      if (pathStart != -1) {
        final pathEnd = _minPositive(queryStart, fragmentStart, rest.length);
        sb.write(rest.substring(pathStart, pathEnd));
      }
      if (queryStart != -1) {
        final queryEnd = fragmentStart != -1 ? fragmentStart : rest.length;
        sb.write(rest.substring(queryStart, queryEnd));
      }
      if (fragmentStart != -1) {
        sb.write(rest.substring(fragmentStart));
      }
    } else {
      sb.write(rest);
    }

    return _normalizePercentEncoding(sb.toString());
  }

  String toNormalized() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Uri && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Represents an email address as defined in UML::EmailAddress.value.
@immutable
@realizes(r'UML::EmailAddress.value')
class EmailAddress {
  final String value;

  EmailAddress(this.value) {
    _validate(value);
  }

  static void _validate(String v) {
    final atIndex = v.lastIndexOf('@');
    if (atIndex == -1) {
      throw EmailFormatError('Email address must contain @ separator: "$v"');
    }

    final localPart = v.substring(0, atIndex);
    final domainPart = v.substring(atIndex + 1);

    if (localPart.isEmpty) {
      throw EmailFormatError('Email local part must not be empty: "$v"');
    }
    if (domainPart.isEmpty) {
      throw EmailFormatError('Email domain part must not be empty: "$v"');
    }

    if (domainPart.startsWith('[') && domainPart.endsWith(']')) {
      final ipLit = domainPart.substring(1, domainPart.length - 1);
      if (ipLit.isEmpty) {
        throw EmailFormatError('Empty IP literal in email: "$v"');
      }
      try {
        IpAddress.parse(ipLit);
      } on Ipv4FormatError {
        throw EmailFormatError('Invalid IP literal in email: "$ipLit"');
      } on Ipv6FormatError {
        throw EmailFormatError('Invalid IP literal in email: "$ipLit"');
      }
    } else {
      try {
        DomainName(domainPart);
      } on DomainFormatError {
        throw EmailFormatError('Invalid domain in email: "$domainPart"');
      }
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailAddress && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
