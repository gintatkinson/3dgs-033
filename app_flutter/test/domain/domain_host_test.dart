import 'package:app_flutter/domain/domain_host.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DomainName', () {
    test('accepts valid fully qualified domain name', () {
      final dn = DomainName('example.com');
      expect(dn.value, 'example.com');
    });

    test('canonical format is lowercase ASCII', () {
      final dn = DomainName('Example.COM');
      expect(dn.toCanonical(), 'example.com');
    });

    test('rejects domain name exceeding 253 characters', () {
      final longName = '${'a' * 63}.${'b' * 63}.${'c' * 63}.${'d' * 63}';
      expect(
        () => DomainName(longName),
        throwsA(isA<DomainHostValidationException>()),
      );
    });

    test('rejects label exceeding 63 characters', () {
      expect(
        () => DomainName('${'a' * 64}.com'),
        throwsA(isA<DomainHostValidationException>()),
      );
    });

    test('rejects label with leading hyphen', () {
      expect(
        () => DomainName('-example.com'),
        throwsA(isA<DomainHostValidationException>()),
      );
    });

    test('rejects label with trailing hyphen', () {
      expect(
        () => DomainName('example-.com'),
        throwsA(isA<DomainHostValidationException>()),
      );
    });

    test('rejects domain name with trailing dot', () {
      expect(
        () => DomainName('example.com.'),
        throwsA(isA<DomainHostValidationException>()),
      );
    });

    test('accepts IDN A-label (xn-- prefix)', () {
      final dn = DomainName('xn--fsq.com');
      expect(dn.value, 'xn--fsq.com');
    });

    test('accepts domain name with underscore in label', () {
      final dn = DomainName('_example.example.com');
      expect(dn.value, '_example.example.com');
    });
  });

  group('HostName', () {
    test('accepts valid host name', () {
      final hn = HostName('host.example.com');
      expect(hn.value, 'host.example.com');
    });

    test('rejects host name shorter than 2 characters', () {
      expect(
        () => HostName('a'),
        throwsA(isA<DomainHostValidationException>()),
      );
    });

    test('rejects host name with underscore', () {
      expect(
        () => HostName('host_name.example.com'),
        throwsA(isA<DomainHostValidationException>()),
      );
    });
  });

  group('Host', () {
    test('Host.parse detects IPv4 address', () {
      final h = Host.parse('192.0.2.1');
      expect(h.isIp, isTrue);
      expect(h.isHostName, isFalse);
      expect(h.value, '192.0.2.1');
    });

    test('Host.parse detects host name', () {
      final h = Host.parse('example.com');
      expect(h.isHostName, isTrue);
      expect(h.isIp, isFalse);
      expect(h.value, 'example.com');
    });

    test('Host.parse rejects invalid input', () {
      expect(
        () => Host.parse(''),
        throwsA(isA<DomainHostValidationException>()),
      );
    });
  });

  group('Uri', () {
    test('accepts valid URI with scheme and authority', () {
      final u = Uri('https://example.com/path?query=value');
      expect(u.value, 'https://example.com/path?query=value');
    });

    test('normalizes scheme and host to lowercase', () {
      final u = Uri('HTTPS://Example.COM/Path');
      expect(u.value, 'https://example.com/Path');
    });

    test('rejects URI without scheme', () {
      expect(
        () => Uri('example.com/path'),
        throwsA(isA<DomainHostValidationException>()),
      );
    });

    test('rejects URI with invalid scheme characters', () {
      expect(
        () => Uri('3invalid://example.com'),
        throwsA(isA<DomainHostValidationException>()),
      );
    });
  });

  group('EmailAddress', () {
    test('accepts valid email address', () {
      final e = EmailAddress('user@example.com');
      expect(e.value, 'user@example.com');
    });

    test('rejects email without @ separator', () {
      expect(
        () => EmailAddress('userexample.com'),
        throwsA(isA<DomainHostValidationException>()),
      );
    });

    test('rejects email with empty local part', () {
      expect(
        () => EmailAddress('@example.com'),
        throwsA(isA<DomainHostValidationException>()),
      );
    });

    test('rejects email with invalid domain', () {
      expect(
        () => EmailAddress('user@invaliddomain!.com'),
        throwsA(isA<DomainHostValidationException>()),
      );
    });
  });
}
