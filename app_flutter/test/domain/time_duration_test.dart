import 'package:app_flutter/domain/time_duration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DurationRangeError', () {
    test('should include type, value and max when created', () {
      const ex = DurationRangeError(type: 'Hours32', value: -1, max: 2147483647);
      expect(ex.type, equals('Hours32'));
      expect(ex.value, equals(-1));
      expect(ex.max, equals(2147483647));
    });
  });

  group('DurationConversionError', () {
    test('should include from, to and value when created', () {
      const ex = DurationConversionError(from: 'seconds', to: 'hours', value: 1000000000);
      expect(ex.from, equals('seconds'));
      expect(ex.to, equals('hours'));
      expect(ex.value, equals(1000000000));
    });
  });

  group('Hours32', () {
    test('should accept valid value when hours is 24', () {
      final h = Hours32(24);
      expect(h.value, equals(24));
    });

    test('should throw DurationRangeError when value is negative', () {
      expect(
        () => Hours32(-1),
        throwsA(isA<DurationRangeError>()),
      );
    });

    test('should throw DurationRangeError when value exceeds max', () {
      const overflow = 2147483648;
      expect(
        () => Hours32(overflow),
        throwsA(isA<DurationRangeError>()),
      );
    });

    test('should convert to 60 minutes when hours is 1', () {
      final h = Hours32(1);
      expect(h.toMinutes(), equals(60));
    });

    test('should convert to 3600 seconds when hours is 1', () {
      final h = Hours32(1);
      expect(h.toSeconds(), equals(3600));
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = Hours32(24);
        final copied = original.copyWith(value: 48);
        expect(copied.value, 48);
      });
    });
  });

  group('Minutes32', () {
    test('should accept valid value when minutes is 30', () {
      final m = Minutes32(30);
      expect(m.value, equals(30));
    });

    test('should throw DurationRangeError when value is negative', () {
      expect(
        () => Minutes32(-1),
        throwsA(isA<DurationRangeError>()),
      );
    });

    test('should throw DurationRangeError when value exceeds max', () {
      const overflow = 2147483648;
      expect(
        () => Minutes32(overflow),
        throwsA(isA<DurationRangeError>()),
      );
    });

    test('should convert to 3600 seconds when minutes is 60', () {
      final m = Minutes32(60);
      expect(m.toSeconds(), equals(3600));
    });

    test('should convert to 2 hours when minutes is 120', () {
      final m = Minutes32(120);
      expect(m.toHours(), equals(2));
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = Minutes32(30);
        final copied = original.copyWith(value: 60);
        expect(copied.value, 60);
      });
    });
  });

  group('Seconds32', () {
    test('should accept valid value when seconds is 45', () {
      final s = Seconds32(45);
      expect(s.value, equals(45));
    });

    test('should convert to 1000 milliseconds when seconds is 1', () {
      final s = Seconds32(1);
      expect(s.toMilliseconds(), equals(1000));
    });

    test('should throw DurationRangeError when value exceeds max', () {
      const overflow = 2147483648;
      expect(
        () => Seconds32(overflow),
        throwsA(isA<DurationRangeError>()),
      );
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = Seconds32(45);
        final copied = original.copyWith(value: 90);
        expect(copied.value, 90);
      });
    });
  });

  group('Centiseconds32', () {
    test('should accept valid value when centiseconds is 50', () {
      final cs = Centiseconds32(50);
      expect(cs.value, equals(50));
    });

    test('should convert to 1000 milliseconds when centiseconds is 100', () {
      final cs = Centiseconds32(100);
      expect(cs.toMilliseconds(), equals(1000));
    });

    test('should convert to 1 second when centiseconds is 100', () {
      final cs = Centiseconds32(100);
      expect(cs.toSeconds(), equals(1));
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = Centiseconds32(50);
        final copied = original.copyWith(value: 200);
        expect(copied.value, 200);
      });
    });
  });

  group('Milliseconds32', () {
    test('should accept valid value when milliseconds is 500', () {
      final ms = Milliseconds32(500);
      expect(ms.value, equals(500));
    });

    test('should convert to 1 second when milliseconds is 1500', () {
      final ms = Milliseconds32(1500);
      expect(ms.toSeconds(), equals(1));
    });

    test('should convert to 1000 microseconds when milliseconds is 1', () {
      final ms = Milliseconds32(1);
      expect(ms.toMicroseconds(), equals(1000));
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = Milliseconds32(500);
        final copied = original.copyWith(value: 1500);
        expect(copied.value, 1500);
      });
    });
  });

  group('Microseconds32', () {
    test('should accept valid value when microseconds is 1000', () {
      final us = Microseconds32(1000);
      expect(us.value, equals(1000));
    });

    test('should convert to 1000 nanoseconds when microseconds is 1', () {
      final us = Microseconds32(1);
      expect(us.toNanoseconds(), equals(1000));
    });

    test('should convert to 1 millisecond when microseconds is 1000', () {
      final us = Microseconds32(1000);
      expect(us.toMilliseconds(), equals(1));
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = Microseconds32(1000);
        final copied = original.copyWith(value: 2000);
        expect(copied.value, 2000);
      });
    });
  });

  group('Nanoseconds32', () {
    test('should accept valid value when nanoseconds is 1000000', () {
      final ns = Nanoseconds32(1000000);
      expect(ns.value, equals(1000000));
    });

    test('should convert to 1 microsecond when nanoseconds is 1000', () {
      final ns = Nanoseconds32(1000);
      expect(ns.toMicroseconds(), equals(1));
    });

    test('should convert to 1 millisecond when nanoseconds is 1000000', () {
      final ns = Nanoseconds32(1000000);
      expect(ns.toMilliseconds(), equals(1));
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = Nanoseconds32(1000000);
        final copied = original.copyWith(value: 2000000);
        expect(copied.value, 2000000);
      });
    });
  });

  group('Microseconds64', () {
    test('should accept large BigInt value when microseconds is int64 max', () {
      final us = Microseconds64(BigInt.parse('9223372036854775807'));
      expect(us.value, equals(BigInt.parse('9223372036854775807')));
    });

    test('should throw DurationRangeError when value is negative', () {
      expect(
        () => Microseconds64(BigInt.from(-1)),
        throwsA(isA<DurationRangeError>()),
      );
    });

    test('should throw DurationRangeError when value exceeds int64 max', () {
      final overflow = BigInt.parse('9223372036854775808');
      expect(
        () => Microseconds64(overflow),
        throwsA(isA<DurationRangeError>()),
      );
    });

    test('should convert to 1000 nanoseconds when microseconds is 1', () {
      final us = Microseconds64(BigInt.from(1));
      expect(us.toNanoseconds(), equals(BigInt.from(1000)));
    });

    test('should convert to 1 millisecond when microseconds is 1000', () {
      final us = Microseconds64(BigInt.from(1000));
      expect(us.toMilliseconds(), equals(BigInt.one));
    });

    group('copyWith', () {
      test('should create copy with modified BigInt value', () {
        final original = Microseconds64(BigInt.from(1));
        final copied = original.copyWith(value: BigInt.from(5000));
        expect(copied.value, BigInt.from(5000));
      });
    });
  });

  group('Nanoseconds64', () {
    test('should accept max int64 value when nanoseconds equals int64 max', () {
      final ns = Nanoseconds64(BigInt.parse('9223372036854775807'));
      expect(ns.value, equals(BigInt.parse('9223372036854775807')));
    });

    test('should throw DurationRangeError when value is negative', () {
      expect(
        () => Nanoseconds64(BigInt.from(-1)),
        throwsA(isA<DurationRangeError>()),
      );
    });

    test('should throw DurationRangeError when value exceeds int64 max', () {
      final overflow = BigInt.parse('9223372036854775808');
      expect(
        () => Nanoseconds64(overflow),
        throwsA(isA<DurationRangeError>()),
      );
    });

    test('should convert to 1 microsecond when nanoseconds is 1000', () {
      final ns = Nanoseconds64(BigInt.from(1000));
      expect(ns.toMicroseconds(), equals(BigInt.one));
    });

    test('should convert to 1 millisecond when nanoseconds is 1000000', () {
      final ns = Nanoseconds64(BigInt.from(1000000));
      expect(ns.toMilliseconds(), equals(BigInt.one));
    });

    group('copyWith', () {
      test('should create copy with modified BigInt value', () {
        final original = Nanoseconds64(BigInt.from(1000));
        final copied = original.copyWith(value: BigInt.from(2000));
        expect(copied.value, BigInt.from(2000));
      });
    });
  });

  group('zero value acceptance', () {
    test('should accept zero for Hours32', () {
      expect(Hours32(0).value, equals(0));
    });
    test('should accept zero for Minutes32', () {
      expect(Minutes32(0).value, equals(0));
    });
    test('should accept zero for Seconds32', () {
      expect(Seconds32(0).value, equals(0));
    });
    test('should accept zero for Centiseconds32', () {
      expect(Centiseconds32(0).value, equals(0));
    });
    test('should accept zero for Milliseconds32', () {
      expect(Milliseconds32(0).value, equals(0));
    });
    test('should accept zero for Microseconds32', () {
      expect(Microseconds32(0).value, equals(0));
    });
    test('should accept zero for Nanoseconds32', () {
      expect(Nanoseconds32(0).value, equals(0));
    });
    test('should accept BigInt zero for Microseconds64', () {
      expect(Microseconds64(BigInt.zero).value, equals(BigInt.zero));
    });
    test('should accept BigInt zero for Nanoseconds64', () {
      expect(Nanoseconds64(BigInt.zero).value, equals(BigInt.zero));
    });
  });

  group('chain conversion', () {
    test('should chain hours to minutes to seconds correctly', () {
      final hours = Hours32(1);
      final minutes = hours.toMinutes();
      expect(minutes, equals(60));
      final seconds = hours.toSeconds();
      expect(seconds, equals(3600));
      final minutesObj = Minutes32.fromMinutes(minutes);
      expect(minutesObj.toSeconds(), equals(3600));
    });
  });
}
