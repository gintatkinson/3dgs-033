import 'package:app_flutter/domain/domain_host.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DomainName', () {
    test('should accept "example.com" when domain is valid', () {
      final dn = DomainName('example.com');
      expect(dn.value, 'example.com');
    });

    test('should lowercase when converting to canonical format', () {
      final dn = DomainName('Example.COM');
      expect(dn.toCanonical(), 'example.com');
    });

    test('should throw DomainFormatError when name exceeds 253 characters', () {
      final longName = '${'a' * 63}.${'b' * 63}.${'c' * 63}.${'d' * 63}';
      expect(
        () => DomainName(longName),
        throwsA(isA<DomainFormatError>()),
      );
    });

    test('should throw DomainFormatError when label exceeds 63 characters', () {
      expect(
        () => DomainName('${'a' * 64}.com'),
        throwsA(isA<DomainFormatError>()),
      );
    });

    test('should throw DomainFormatError when label has leading hyphen', () {
      expect(
        () => DomainName('-example.com'),
        throwsA(isA<DomainFormatError>()),
      );
    });

    test('should throw DomainFormatError when label has trailing hyphen', () {
      expect(
        () => DomainName('example-.com'),
        throwsA(isA<DomainFormatError>()),
      );
    });

    test('should throw DomainFormatError when name has trailing dot', () {
      expect(
        () => DomainName('example.com.'),
        throwsA(isA<DomainFormatError>()),
      );
    });

    test('should accept IDN A-label when prefix is "xn--"', () {
      final dn = DomainName('xn--fsq.com');
      expect(dn.value, 'xn--fsq.com');
    });

    test('should accept domain name when label has underscore', () {
      final dn = DomainName('_example.example.com');
      expect(dn.value, '_example.example.com');
    });
  });

  group('HostName', () {
    test('should accept "host.example.com" when host name is valid', () {
      final hn = HostName('host.example.com');
      expect(hn.value, 'host.example.com');
    });

    test('should throw DomainFormatError when name is shorter than 2 characters', () {
      expect(
        () => HostName('a'),
        throwsA(isA<DomainFormatError>()),
      );
    });

    test('should throw DomainFormatError when name has underscore', () {
      expect(
        () => HostName('host_name.example.com'),
        throwsA(isA<DomainFormatError>()),
      );
    });
  });

  group('Host', () {
    test('should detect IPv4 when value is "192.0.2.1"', () {
      final h = Host.parse('192.0.2.1');
      expect(h.isIp, isTrue);
      expect(h.isHostName, isFalse);
      expect(h.value, '192.0.2.1');
    });

    test('should detect host name when value is "example.com"', () {
      final h = Host.parse('example.com');
      expect(h.isHostName, isTrue);
      expect(h.isIp, isFalse);
      expect(h.value, 'example.com');
    });

    test('should throw HostParseError when input is empty', () {
      expect(
        () => Host.parse(''),
        throwsA(isA<HostParseError>()),
      );
    });
  });

  group('Uri', () {
    test('should accept "https://example.com/path?query=value" when scheme is valid', () {
      final u = Uri('https://example.com/path?query=value');
      expect(u.value, 'https://example.com/path?query=value');
    });

    test('should lowercase scheme and host when normalizing', () {
      final u = Uri('HTTPS://Example.COM/Path');
      expect(u.value, 'https://example.com/Path');
    });

    test('should throw UriFormatError when scheme is missing', () {
      expect(
        () => Uri('example.com/path'),
        throwsA(isA<UriFormatError>()),
      );
    });

    test('should throw UriFormatError when scheme has invalid characters', () {
      expect(
        () => Uri('3invalid://example.com'),
        throwsA(isA<UriFormatError>()),
      );
    });
  });

  group('EmailAddress', () {
    test('should accept "user@example.com" when email is valid', () {
      final e = EmailAddress('user@example.com');
      expect(e.value, 'user@example.com');
    });

    test('should throw EmailFormatError when @ is missing', () {
      expect(
        () => EmailAddress('userexample.com'),
        throwsA(isA<EmailFormatError>()),
      );
    });

    test('should throw EmailFormatError when local part is empty', () {
      expect(
        () => EmailAddress('@example.com'),
        throwsA(isA<EmailFormatError>()),
      );
    });

    test('should throw EmailFormatError when domain is invalid', () {
      expect(
        () => EmailAddress('user@invaliddomain!.com'),
        throwsA(isA<EmailFormatError>()),
      );
    });
  });
}
