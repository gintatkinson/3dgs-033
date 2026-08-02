import 'package:app_flutter/domain/time_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeTicks', () {
    test('valid value 8640000 converts to 86400 seconds', () {
      final tt = TimeTicks(8640000);
      expect(tt.value, equals(8640000));
      final d = tt.toDuration();
      expect(d.inSeconds, equals(86400));
    });

    test('rejects negative value', () {
      expect(
        () => TimeTicks(-1),
        throwsA(isA<TimeTrackingValidationException>()),
      );
    });

    test('wraps at 2^32-1 + 1 to 0', () {
      const maxVal = 4294967295;
      final tt = TimeTicks(maxVal);
      final wrapped = tt.advance(1);
      expect(wrapped.value, equals(0));
    });

    test('hasWrapped flag set on wrap', () {
      const maxVal = 4294967295;
      final tt = TimeTicks(maxVal);
      final wrapped = tt.advance(1);
      expect(wrapped.hasWrapped, isTrue);
    });

    test('deltaTo in normal range: 100 to 200, delta = 100', () {
      final previous = TimeTicks(100);
      final current = TimeTicks(200);
      expect(current.deltaTo(previous), equals(100));
    });

    test('deltaTo across wrap: 4294967290 to 5, delta = 11', () {
      final previous = TimeTicks(4294967290);
      final current = TimeTicks(5);
      expect(current.deltaTo(previous), equals(11));
    });
  });

  group('TimeStamp', () {
    test('accepts valid value', () {
      final ts = TimeStamp(4320000);
      expect(ts.value, equals(4320000));
    });

    test('isBeforeLastZero true when value is 0', () {
      final ts = TimeStamp(0);
      expect(ts.isBeforeLastZero, isTrue);
    });

    test('reset returns timestamp with value 0', () {
      final ts = TimeStamp(500);
      final reset = ts.reset();
      expect(reset.value, equals(0));
    });

    test('reset on timeticks wrap returns zero timestamp', () {
      const maxVal = 4294967295;
      final ticks = TimeTicks(maxVal);
      final timestamp = TimeStamp(500);
      final wrappedTicks = ticks.advance(1);
      final resetTs = timestamp.reset();
      expect(wrappedTicks.value, equals(0));
      expect(resetTs.value, equals(0));
    });
  });

  group('TimeTrackingValidationException', () {
    test('has message property', () {
      const ex = TimeTrackingValidationException('test error');
      expect(ex.message, equals('test error'));
      expect(ex.toString(), contains('TimeTrackingValidationException'));
    });
  });
}
