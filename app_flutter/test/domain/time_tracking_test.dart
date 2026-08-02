import 'package:app_flutter/domain/time_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeTicksOverflowError', () {
    test('should include maxValue when created', () {
      const ex = TimeTicksOverflowError(maxValue: 4294967295);
      expect(ex.maxValue, equals(4294967295));
    });
  });

  group('TimeTicks', () {
    test('should convert to 86400 seconds when value is 8640000', () {
      final tt = TimeTicks(8640000);
      expect(tt.value, equals(8640000));
      final d = tt.toDuration();
      expect(d.inSeconds, equals(86400));
    });

    test('should throw TimeTicksOverflowError when value is negative', () {
      expect(
        () => TimeTicks(-1),
        throwsA(isA<TimeTicksOverflowError>()),
      );
    });

    test('should throw TimeTicksOverflowError when value exceeds 4294967295', () {
      expect(
        () => TimeTicks(4294967296),
        throwsA(isA<TimeTicksOverflowError>()),
      );
    });

    test('should wrap to zero when value reaches 4294967295 and advances by 1', () {
      const maxVal = 4294967295;
      final tt = TimeTicks(maxVal);
      final wrapped = tt.advance(1);
      expect(wrapped.value, equals(0));
    });

    test('should set hasWrapped flag when wrapping at maximum', () {
      const maxVal = 4294967295;
      final tt = TimeTicks(maxVal);
      final wrapped = tt.advance(1);
      expect(wrapped.hasWrapped, isTrue);
    });

    test('should calculate delta of 100 when previous is 100 and current is 200', () {
      final previous = TimeTicks(100);
      final current = TimeTicks(200);
      expect(current.deltaTo(previous), equals(100));
    });

    test('should calculate delta of 11 when wrapping from 4294967290 to 5', () {
      final previous = TimeTicks(4294967290);
      final current = TimeTicks(5);
      expect(current.deltaTo(previous), equals(11));
    });

    /// @traces US-03
    test('should calculate elapsed ticks between timestamp and current timeticks', () {
      final eventTimestamp = TimeTicks(500000);
      final currentTimeticks = TimeTicks(800000);
      expect(currentTimeticks.deltaTo(eventTimestamp), equals(300000));
    });

    /// @traces US-03
    test('should report unreliable delta when multiple wraps may have occurred', () {
      final previous = TimeTicks(0);
      final current = TimeTicks(0);
      expect(current.deltaTo(previous), equals(0));
      final shortDelta = TimeTicks(1);
      expect(shortDelta.deltaTo(previous), equals(1));
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = TimeTicks(100);
        final copied = original.copyWith(value: 200);
        expect(copied.value, 200);
      });

      test('should create copy with modified hasWrapped flag', () {
        final original = TimeTicks(100);
        final copied = original.copyWith(hasWrapped: true);
        expect(copied.hasWrapped, isTrue);
      });

      test('should preserve fields when copyWith has no arguments', () {
        final original = TimeTicks(100);
        final copied = original.copyWith();
        expect(copied.value, 100);
        expect(identical(copied, original), isFalse);
      });
    });
  });

  group('TimeStamp', () {
    test('should accept valid value 4320000', () {
      final ts = TimeStamp(4320000);
      expect(ts.value, equals(4320000));
    });

    test('should return true for isBeforeLastZero when value is zero', () {
      final ts = TimeStamp(0);
      expect(ts.isBeforeLastZero, isTrue);
    });

    test('should reset to zero when reset is called on a non-zero timestamp', () {
      final ts = TimeStamp(500);
      final reset = ts.reset();
      expect(reset.value, equals(0));
    });

    test('should reset timestamp to zero when timeticks wraps', () {
      const maxVal = 4294967295;
      final ticks = TimeTicks(maxVal);
      final timestamp = TimeStamp(500);
      final wrappedTicks = ticks.advance(1);
      final resetTs = timestamp.reset();
      expect(wrappedTicks.value, equals(0));
      expect(resetTs.value, equals(0));
    });

    test('should throw TimestampResetError when value is negative', () {
      expect(
        () => TimeStamp(-1),
        throwsA(isA<TimestampResetError>()),
      );
    });

    group('copyWith', () {
      test('should create copy with modified value', () {
        final original = TimeStamp(500);
        final copied = original.copyWith(value: 1000);
        expect(copied.value, 1000);
      });

      test('should preserve value when copyWith has no arguments', () {
        final original = TimeStamp(500);
        final copied = original.copyWith();
        expect(copied.value, 500);
        expect(identical(copied, original), isFalse);
      });
    });
  });
}
