import 'package:app_flutter/domain/time_duration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DurationValidationException', () {
    test('has message property', () {
      const ex = DurationValidationException('test error');
      expect(ex.message, equals('test error'));
      expect(ex.toString(), contains('DurationValidationException'));
    });
  });

  group('Hours32', () {
    test('accepts valid value (24)', () {
      final h = Hours32(24);
      expect(h.value, equals(24));
    });

    test('rejects negative (-1)', () {
      expect(
        () => Hours32(-1),
        throwsA(isA<DurationValidationException>()),
      );
    });

    test('rejects out-of-range value exceeding max', () {
      const overflow = 2147483648; // 2^31
      expect(
        () => Hours32(overflow),
        throwsA(isA<DurationValidationException>()),
      );
    });

    test('converts to minutes', () {
      final h = Hours32(1);
      expect(h.toMinutes(), equals(60));
    });

    test('converts to seconds', () {
      final h = Hours32(1);
      expect(h.toSeconds(), equals(3600));
    });
  });

  group('Minutes32', () {
    test('accepts valid value (30)', () {
      final m = Minutes32(30);
      expect(m.value, equals(30));
    });

    test('rejects negative', () {
      expect(
        () => Minutes32(-1),
        throwsA(isA<DurationValidationException>()),
      );
    });

    test('rejects out-of-range', () {
      const overflow = 2147483648;
      expect(
        () => Minutes32(overflow),
        throwsA(isA<DurationValidationException>()),
      );
    });

    test('converts to seconds', () {
      final m = Minutes32(60);
      expect(m.toSeconds(), equals(3600));
    });

    test('converts to hours', () {
      final m = Minutes32(120);
      expect(m.toHours(), equals(2));
    });
  });

  group('Seconds32', () {
    test('accepts valid value', () {
      final s = Seconds32(45);
      expect(s.value, equals(45));
    });

    test('converts to milliseconds', () {
      final s = Seconds32(1);
      expect(s.toMilliseconds(), equals(1000));
    });

    test('rejects out-of-range', () {
      const overflow = 2147483648;
      expect(
        () => Seconds32(overflow),
        throwsA(isA<DurationValidationException>()),
      );
    });
  });

  group('Centiseconds32', () {
    test('accepts valid value', () {
      final cs = Centiseconds32(50);
      expect(cs.value, equals(50));
    });

    test('converts to milliseconds', () {
      final cs = Centiseconds32(100);
      expect(cs.toMilliseconds(), equals(1000));
    });

    test('converts to seconds', () {
      final cs = Centiseconds32(100);
      expect(cs.toSeconds(), equals(1));
    });
  });

  group('Milliseconds32', () {
    test('accepts valid value', () {
      final ms = Milliseconds32(500);
      expect(ms.value, equals(500));
    });

    test('converts to seconds', () {
      final ms = Milliseconds32(1500);
      expect(ms.toSeconds(), equals(1));
    });

    test('converts to microseconds', () {
      final ms = Milliseconds32(1);
      expect(ms.toMicroseconds(), equals(1000));
    });
  });

  group('Microseconds32', () {
    test('accepts valid value', () {
      final us = Microseconds32(1000);
      expect(us.value, equals(1000));
    });

    test('converts to nanoseconds', () {
      final us = Microseconds32(1);
      expect(us.toNanoseconds(), equals(1000));
    });

    test('converts to milliseconds', () {
      final us = Microseconds32(1000);
      expect(us.toMilliseconds(), equals(1));
    });
  });

  group('Nanoseconds32', () {
    test('accepts valid value', () {
      final ns = Nanoseconds32(1000000);
      expect(ns.value, equals(1000000));
    });

    test('converts to microseconds', () {
      final ns = Nanoseconds32(1000);
      expect(ns.toMicroseconds(), equals(1));
    });

    test('converts to milliseconds', () {
      final ns = Nanoseconds32(1000000);
      expect(ns.toMilliseconds(), equals(1));
    });
  });

  group('Microseconds64', () {
    test('accepts large value using BigInt', () {
      final us = Microseconds64(BigInt.parse('9223372036854775807'));
      expect(us.value, equals(BigInt.parse('9223372036854775807')));
    });

    test('rejects negative value', () {
      expect(
        () => Microseconds64(BigInt.from(-1)),
        throwsA(isA<DurationValidationException>()),
      );
    });

    test('rejects value exceeding 2^63-1', () {
      final overflow = BigInt.parse('9223372036854775808');
      expect(
        () => Microseconds64(overflow),
        throwsA(isA<DurationValidationException>()),
      );
    });

    test('converts to nanoseconds', () {
      final us = Microseconds64(BigInt.from(1));
      expect(us.toNanoseconds(), equals(BigInt.from(1000)));
    });

    test('converts to milliseconds', () {
      final us = Microseconds64(BigInt.from(1000));
      expect(us.toMilliseconds(), equals(BigInt.one));
    });
  });

  group('Nanoseconds64', () {
    test('accepts max range value', () {
      final ns = Nanoseconds64(BigInt.parse('9223372036854775807'));
      expect(ns.value, equals(BigInt.parse('9223372036854775807')));
    });

    test('rejects negative value', () {
      expect(
        () => Nanoseconds64(BigInt.from(-1)),
        throwsA(isA<DurationValidationException>()),
      );
    });

    test('rejects value exceeding 2^63-1', () {
      final overflow = BigInt.parse('9223372036854775808');
      expect(
        () => Nanoseconds64(overflow),
        throwsA(isA<DurationValidationException>()),
      );
    });

    test('converts to microseconds', () {
      final ns = Nanoseconds64(BigInt.from(1000));
      expect(ns.toMicroseconds(), equals(BigInt.one));
    });

    test('converts to milliseconds', () {
      final ns = Nanoseconds64(BigInt.from(1000000));
      expect(ns.toMilliseconds(), equals(BigInt.one));
    });
  });

  group('hours to minutes to seconds chain conversion', () {
    test('Hours32 chain: 1 hour = 60 minutes = 3600 seconds', () {
      final hours = Hours32(1);
      final minutes = hours.toMinutes();
      expect(minutes, equals(60));
      final seconds = hours.toSeconds();
      expect(seconds, equals(3600));
      final minutesObj = Minutes32.fromMinutes(minutes);
      expect(minutesObj.toSeconds(), equals(3600));
    });

    test('chain through different types', () {
      final h = Hours32(1);
      expect(h.toMinutes(), equals(60));
      expect(h.toSeconds(), equals(3600));
    });
  });

  group('zero value accepted for all types', () {
    test('Hours32 accepts zero', () {
      final h = Hours32(0);
      expect(h.value, equals(0));
    });

    test('Minutes32 accepts zero', () {
      final m = Minutes32(0);
      expect(m.value, equals(0));
    });

    test('Seconds32 accepts zero', () {
      final s = Seconds32(0);
      expect(s.value, equals(0));
    });

    test('Centiseconds32 accepts zero', () {
      final cs = Centiseconds32(0);
      expect(cs.value, equals(0));
    });

    test('Milliseconds32 accepts zero', () {
      final ms = Milliseconds32(0);
      expect(ms.value, equals(0));
    });

    test('Microseconds32 accepts zero', () {
      final us = Microseconds32(0);
      expect(us.value, equals(0));
    });

    test('Nanoseconds32 accepts zero', () {
      final ns = Nanoseconds32(0);
      expect(ns.value, equals(0));
    });

    test('Microseconds64 accepts zero', () {
      final us = Microseconds64(BigInt.zero);
      expect(us.value, equals(BigInt.zero));
    });

    test('Nanoseconds64 accepts zero', () {
      final ns = Nanoseconds64(BigInt.zero);
      expect(ns.value, equals(BigInt.zero));
    });
  });

  group('named constructors', () {
    test('Hours32.fromHours creates valid instance', () {
      final h = Hours32.fromHours(24);
      expect(h.value, equals(24));
    });

    test('Minutes32.fromMinutes creates valid instance', () {
      final m = Minutes32.fromMinutes(30);
      expect(m.value, equals(30));
    });

    test('Seconds32.fromSeconds creates valid instance', () {
      final s = Seconds32.fromSeconds(45);
      expect(s.value, equals(45));
    });

    test('Centiseconds32.fromCentiseconds creates valid instance', () {
      final cs = Centiseconds32.fromCentiseconds(50);
      expect(cs.value, equals(50));
    });

    test('Milliseconds32.fromMilliseconds creates valid instance', () {
      final ms = Milliseconds32.fromMilliseconds(500);
      expect(ms.value, equals(500));
    });

    test('Microseconds32.fromMicroseconds creates valid instance', () {
      final us = Microseconds32.fromMicroseconds(1000);
      expect(us.value, equals(1000));
    });

    test('Nanoseconds32.fromNanoseconds creates valid instance', () {
      final ns = Nanoseconds32.fromNanoseconds(1000000);
      expect(ns.value, equals(1000000));
    });

    test('Microseconds64.fromMicroseconds creates valid instance', () {
      final us = Microseconds64.fromMicroseconds(BigInt.from(1000000));
      expect(us.value, equals(BigInt.from(1000000)));
    });

    test('Nanoseconds64.fromNanoseconds creates valid instance', () {
      final ns = Nanoseconds64.fromNanoseconds(BigInt.from(1000000000));
      expect(ns.value, equals(BigInt.from(1000000000)));
    });
  });
}
