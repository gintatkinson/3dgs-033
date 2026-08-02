import 'package:app_flutter/domain/counter_gauge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Counter32', () {
    test('should increment to 101 when counter value is 100', () {
      final counter = Counter32(100);
      final next = counter.increment();
      expect(next.value, 101);
      expect(next.hasWrapped, isFalse);
    });

    test('should wrap to zero when counter value is 4294967295', () {
      final counter = Counter32(4294967295);
      final next = counter.increment();
      expect(next.value, 0);
      expect(next.hasWrapped, isTrue);
    });

    test('should throw CounterConfigError when initial value is negative', () {
      expect(
        () => Counter32(-1),
        throwsA(isA<CounterConfigError>()),
      );
    });

    test('should throw CounterOverflowError when initial value exceeds maximum', () {
      expect(
        () => Counter32(4294967296),
        throwsA(isA<CounterOverflowError>()),
      );
    });

    test('should set discontinuity flag on wrap', () {
      final counter = Counter32(4294967295);
      final wrapped = counter.increment();
      expect(wrapped.hasWrapped, isTrue);
      expect(wrapped.value, 0);

      final next = wrapped.increment();
      expect(next.hasWrapped, isFalse);
      expect(next.value, 1);
    });

    test('should return same value when reset is called', () {
      final counter = Counter32(42);
      final result = counter.reset();
      expect(result.value, 42);
      expect(result.hasWrapped, isFalse);
    });

    test('should be read only with no set method unlike Gauge', () {
      final counter = Counter32(10);
      expect(counter.value, 10);
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = Counter32(100);
        final copied = original.copyWith(value: 200);
        expect(copied.value, 200);
        expect(copied.hasWrapped, isFalse);
      });

      test('should create copy with modified hasWrapped flag', () {
        final original = Counter32(100);
        final copied = original.copyWith(hasWrapped: true);
        expect(copied.value, 100);
        expect(copied.hasWrapped, isTrue);
      });

      test('should preserve fields when copyWith has no arguments', () {
        final original = Counter32(100);
        final copied = original.copyWith();
        expect(copied.value, 100);
        expect(identical(copied, original), isFalse);
      });
    });
  });

  group('ZeroBasedCounter32', () {
    test('should start at zero when created', () {
      final counter = ZeroBasedCounter32();
      expect(counter.value, 0);
      expect(counter.hasWrapped, isFalse);
    });

    test('should reset to zero when reset is called after increments', () {
      final counter = ZeroBasedCounter32();
      final inc = counter.increment().increment();
      expect(inc.value, 2);
      final result = inc.reset();
      expect(result.value, 0);
      expect(result.hasWrapped, isFalse);
    });

    group('copyWith', () {
      test('should return ZeroBasedCounter32 when copyWith is called', () {
        final original = ZeroBasedCounter32();
        final copied = original.copyWith(value: 5);
        expect(copied, isA<ZeroBasedCounter32>());
        expect(copied.value, 5);
      });
    });
  });

  group('Counter64', () {
    test('should wrap to zero when counter value is 18446744073709551615', () {
      final counter = Counter64(BigInt.parse('18446744073709551615'));
      final next = counter.increment();
      expect(next.value, BigInt.zero);
      expect(next.hasWrapped, isTrue);
    });

    test('should throw CounterOverflowError when initial value exceeds maximum', () {
      expect(
        () => Counter64(BigInt.parse('18446744073709551616')),
        throwsA(isA<CounterOverflowError>()),
      );
    });

    group('copyWith', () {
      test('should create copy with modified BigInt value', () {
        final original = Counter64(BigInt.from(100));
        final copied = original.copyWith(value: BigInt.from(200));
        expect(copied.value, BigInt.from(200));
      });
    });
  });

  group('ZeroBasedCounter64', () {
    test('should start at zero when created', () {
      final counter = ZeroBasedCounter64();
      expect(counter.value, BigInt.zero);
      expect(counter.hasWrapped, isFalse);
    });

    group('copyWith', () {
      test('should return ZeroBasedCounter64 when copyWith is called', () {
        final original = ZeroBasedCounter64();
        final copied = original.copyWith(value: BigInt.from(10));
        expect(copied, isA<ZeroBasedCounter64>());
        expect(copied.value, BigInt.from(10));
      });
    });
  });

  group('Gauge32', () {
    test('should set value to 75 when current value is 50', () {
      final gauge = Gauge32(50);
      final updated = gauge.set(75);
      expect(updated.value, 75);
      expect(updated.isSaturated, isFalse);
    });

    test('should clamp at maximum when value exceeds 4294967295', () {
      final gauge = Gauge32(4294967294);
      final updated = gauge.set(4294967296);
      expect(updated.value, 4294967295);
      expect(updated.isSaturated, isTrue);
    });

    test('should clamp at minimum when value drops below zero', () {
      final gauge = Gauge32(1);
      final updated = gauge.set(-1);
      expect(updated.value, 0);
      expect(updated.isSaturated, isTrue);
    });

    test('should clamp on construction when initial value exceeds maximum', () {
      final gauge = Gauge32(5000000000);
      expect(gauge.value, 4294967295);
    });

    test('should clamp on construction when initial value is below minimum', () {
      final gauge = Gauge32(-5);
      expect(gauge.value, 0);
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = Gauge32(50);
        final copied = original.copyWith(value: 100);
        expect(copied.value, 100);
      });

      test('should preserve value when copyWith has no arguments', () {
        final original = Gauge32(50);
        final copied = original.copyWith();
        expect(copied.value, 50);
        expect(identical(copied, original), isFalse);
      });
    });
  });

  group('Gauge64', () {
    test('should set value to 75 when current value is 50', () {
      final gauge = Gauge64(BigInt.from(50));
      final updated = gauge.set(BigInt.from(75));
      expect(updated.value, BigInt.from(75));
      expect(updated.isSaturated, isFalse);
    });

    test('should clamp at maximum when value exceeds 18446744073709551615', () {
      final gauge = Gauge64(BigInt.parse('18446744073709551614'));
      final updated = gauge.set(BigInt.parse('18446744073709551616'));
      expect(updated.value, BigInt.parse('18446744073709551615'));
      expect(updated.isSaturated, isTrue);
    });

    test('should clamp at minimum when value drops below zero', () {
      final gauge = Gauge64(BigInt.one);
      final updated = gauge.set(BigInt.from(-1));
      expect(updated.value, BigInt.zero);
      expect(updated.isSaturated, isTrue);
    });

    group('copyWith', () {
      test('should create copy with modified BigInt value', () {
        final original = Gauge64(BigInt.from(50));
        final copied = original.copyWith(value: BigInt.from(100));
        expect(copied.value, BigInt.from(100));
      });
    });
  });

  group('CounterOverflowError', () {
    test('should include maxValue in message when Counter32 overflows', () {
      try {
        Counter32(4294967296);
        fail('Expected CounterOverflowError');
      } on CounterOverflowError catch (e) {
        expect(e.maxValue, equals(4294967295));
      }
    });
  });
}
