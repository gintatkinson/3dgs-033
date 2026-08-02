import 'package:app_flutter/domain/counter_gauge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Counter32', () {
    test('increment within bounds: 100 → 101', () {
      final counter = Counter32(100);
      final next = counter.increment();
      expect(next.value, 101);
      expect(next.hasWrapped, isFalse);
    });

    test('wrap at maximum: 4294967295 → 0', () {
      final counter = Counter32(4294967295);
      final next = counter.increment();
      expect(next.value, 0);
      expect(next.hasWrapped, isTrue);
    });

    test('rejects negative initial value', () {
      expect(
        () => Counter32(-1),
        throwsA(isA<CounterGaugeValidationException>()),
      );
    });

    test('rejects value above maximum', () {
      expect(
        () => Counter32(4294967296),
        throwsA(isA<CounterGaugeValidationException>()),
      );
    });

    test('discontinuity flag set on wrap', () {
      final counter = Counter32(4294967295);
      final wrapped = counter.increment();
      expect(wrapped.hasWrapped, isTrue);
      expect(wrapped.value, 0);

      final next = wrapped.increment();
      expect(next.hasWrapped, isFalse);
      expect(next.value, 1);
    });

    test('reset returns same value', () {
      final counter = Counter32(42);
      final result = counter.reset();
      expect(result.value, 42);
      expect(result.hasWrapped, isFalse);
    });

    test('read-only: has no set method unlike Gauge', () {
      final counter = Counter32(10);
      expect(counter.value, 10);
    });
  });

  group('ZeroBasedCounter32', () {
    test('starts at 0', () {
      final counter = ZeroBasedCounter32();
      expect(counter.value, 0);
      expect(counter.hasWrapped, isFalse);
    });

    test('reset returns to 0', () {
      final counter = ZeroBasedCounter32();
      final inc = counter.increment().increment();
      expect(inc.value, 2);
      final result = inc.reset();
      expect(result.value, 0);
      expect(result.hasWrapped, isFalse);
    });
  });

  group('Counter64', () {
    test('wrap at maximum: 18446744073709551615 → 0', () {
      final counter = Counter64(BigInt.parse('18446744073709551615'));
      final next = counter.increment();
      expect(next.value, BigInt.zero);
      expect(next.hasWrapped, isTrue);
    });
  });

  group('ZeroBasedCounter64', () {
    test('starts at 0', () {
      final counter = ZeroBasedCounter64();
      expect(counter.value, BigInt.zero);
      expect(counter.hasWrapped, isFalse);
    });
  });

  group('Gauge32', () {
    test('within bounds: 50 → 75', () {
      final gauge = Gauge32(50);
      final updated = gauge.set(75);
      expect(updated.value, 75);
      expect(updated.isSaturated, isFalse);
    });

    test('clamp at maximum', () {
      final gauge = Gauge32(4294967294);
      final updated = gauge.set(4294967296);
      expect(updated.value, 4294967295);
      expect(updated.isSaturated, isTrue);
    });

    test('clamp at minimum: 1 → 0', () {
      final gauge = Gauge32(1);
      final updated = gauge.set(-1);
      expect(updated.value, 0);
      expect(updated.isSaturated, isTrue);
    });

    test('clamp on construction above max', () {
      final gauge = Gauge32(5000000000);
      expect(gauge.value, 4294967295);
    });

    test('clamp on construction below min', () {
      final gauge = Gauge32(-5);
      expect(gauge.value, 0);
    });
  });

  group('Gauge64', () {
    test('within bounds: 50 → 75', () {
      final gauge = Gauge64(BigInt.from(50));
      final updated = gauge.set(BigInt.from(75));
      expect(updated.value, BigInt.from(75));
      expect(updated.isSaturated, isFalse);
    });

    test('clamp at maximum', () {
      final gauge = Gauge64(BigInt.parse('18446744073709551614'));
      final updated = gauge.set(BigInt.parse('18446744073709551616'));
      expect(updated.value, BigInt.parse('18446744073709551615'));
      expect(updated.isSaturated, isTrue);
    });

    test('clamp at minimum', () {
      final gauge = Gauge64(BigInt.one);
      final updated = gauge.set(BigInt.from(-1));
      expect(updated.value, BigInt.zero);
      expect(updated.isSaturated, isTrue);
    });
  });

  group('CounterGaugeValidationException', () {
    test('has descriptive message for negative value', () {
      try {
        Counter32(-1);
        fail('Expected exception');
      } on CounterGaugeValidationException catch (e) {
        expect(e.message, contains('negative'));
      }
    });

    test('has descriptive message for overflow', () {
      try {
        Counter32(4294967296);
        fail('Expected exception');
      } on CounterGaugeValidationException catch (e) {
        expect(e.message, contains('exceeds'));
      }
    });
  });
}
