import 'package:app_flutter/domain/date_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateFormatError', () {
    test('should include field and value when created', () {
      const ex = DateFormatError(field: 'month', value: '13');
      expect(ex.field, equals('month'));
      expect(ex.value, equals('13'));
      expect(ex.toString(), contains('DateFormatError'));
    });
  });

  group('YangDateTime', () {
    group('parse valid', () {
      test('should parse date and time when value has Z timezone', () {
        final dt = YangDateTime.parse('2025-12-22T14:30:00Z');
        expect(dt.year, equals(2025));
        expect(dt.month, equals(12));
        expect(dt.day, equals(22));
        expect(dt.hour, equals(14));
        expect(dt.minute, equals(30));
        expect(dt.second, equals(0));
        expect(dt.timezone, equals('Z'));
        expect(dt.hasLeapSecond, isFalse);
      });

      test('should parse date and time when value has positive offset', () {
        final dt = YangDateTime.parse('2025-12-22T14:30:00+01:00');
        expect(dt.year, equals(2025));
        expect(dt.month, equals(12));
        expect(dt.day, equals(22));
        expect(dt.hour, equals(14));
        expect(dt.minute, equals(30));
        expect(dt.second, equals(0));
        expect(dt.timezone, equals('+01:00'));
        expect(dt.hasLeapSecond, isFalse);
      });

      test('should parse date and time when value has no timezone', () {
        final dt = YangDateTime.parse('2025-12-22T14:30:00');
        expect(dt.year, equals(2025));
        expect(dt.month, equals(12));
        expect(dt.day, equals(22));
        expect(dt.hour, equals(14));
        expect(dt.minute, equals(30));
        expect(dt.second, equals(0));
        expect(dt.timezone, isNull);
        expect(dt.hasLeapSecond, isFalse);
      });

      test('should parse far future date when value is 9999-12-31', () {
        final dt = YangDateTime.parse('9999-12-31T23:59:59Z');
        expect(dt.year, equals(9999));
        expect(dt.month, equals(12));
        expect(dt.day, equals(31));
        expect(dt.hour, equals(23));
        expect(dt.minute, equals(59));
        expect(dt.second, equals(59));
        expect(dt.timezone, equals('Z'));
        expect(dt.hasLeapSecond, isFalse);
      });

      test('should accept leap second when seconds value is 60', () {
        final dt = YangDateTime.parse('2016-12-31T23:59:60Z');
        expect(dt.year, equals(2016));
        expect(dt.month, equals(12));
        expect(dt.day, equals(31));
        expect(dt.hour, equals(23));
        expect(dt.minute, equals(59));
        expect(dt.second, equals(60));
        expect(dt.hasLeapSecond, isTrue);
      });

      test('should accept timezone offset +05:30', () {
        final dt = YangDateTime.parse('2025-12-22T14:30:00+05:30');
        expect(dt.timezone, equals('+05:30'));
        expect(dt.hasLeapSecond, isFalse);
      });

      test('should provide parsed Dart DateTime when timezoned and not leap second', () {
        final dt = YangDateTime.parse('2025-12-22T14:30:00Z');
        expect(dt.parsed, isNotNull);
        expect(dt.parsed!.year, equals(2025));
        expect(dt.parsed!.month, equals(12));
        expect(dt.parsed!.day, equals(22));
      });

      test('should provide null parsed when value has no timezone', () {
        final dt = YangDateTime.parse('2025-12-22T14:30:00');
        expect(dt.parsed, isNull);
      });

      test('should provide null parsed for leap second values', () {
        final dt = YangDateTime.parse('2016-12-31T23:59:60Z');
        expect(dt.parsed, isNull);
      });
    });

    group('parse rejects', () {
      test('should throw DateFormatError when month is 13', () {
        expect(
          () => YangDateTime.parse('2025-13-01T00:00:00Z'),
          throwsA(isA<DateFormatError>()),
        );
      });

      test('should throw DateFormatError when day is 32', () {
        expect(
          () => YangDateTime.parse('2025-01-32T00:00:00Z'),
          throwsA(isA<DateFormatError>()),
        );
      });

      test('should throw TimeFormatError when hour is 24', () {
        expect(
          () => YangDateTime.parse('2025-01-01T24:00:00Z'),
          throwsA(isA<TimeFormatError>()),
        );
      });

      test('should throw TimeFormatError when minute is 60', () {
        expect(
          () => YangDateTime.parse('2025-01-01T00:60:00Z'),
          throwsA(isA<TimeFormatError>()),
        );
      });

      test('should throw TimeFormatError when second is 61', () {
        expect(
          () => YangDateTime.parse('2025-01-01T00:00:61Z'),
          throwsA(isA<TimeFormatError>()),
        );
      });

      test('should throw DateFormatError when year is negative', () {
        expect(
          () => YangDateTime.parse('-0001-01-01T00:00:00Z'),
          throwsA(isA<DateFormatError>()),
        );
      });

      test('should throw DateFormatError when timezone offset hour is invalid', () {
        expect(
          () => YangDateTime.parse('2025-12-22T14:30:00+25:00'),
          throwsA(isA<DateFormatError>()),
        );
      });

      test('should throw DateFormatError when T separator is missing', () {
        expect(
          () => YangDateTime.parse('2025-12-22 14:30:00Z'),
          throwsA(isA<DateFormatError>()),
        );
      });

      test('should throw DateFormatError when string is empty', () {
        expect(
          () => YangDateTime.parse(''),
          throwsA(isA<DateFormatError>()),
        );
      });
    });

    group('copyWith', () {
      test('should create copy with modified year', () {
        final dt = YangDateTime.parse('2025-12-22T14:30:00Z');
        final copied = dt.copyWith(year: 2026);
        expect(copied.year, 2026);
        expect(copied.month, 12);
        expect(copied.day, 22);
      });

      test('should create copy with modified timezone', () {
        final dt = YangDateTime.parse('2025-12-22T14:30:00Z');
        final copied = dt.copyWith(timezone: '+05:00');
        expect(copied.timezone, '+05:00');
      });

      test('should preserve fields when copyWith has no arguments', () {
        final dt = YangDateTime.parse('2025-12-22T14:30:00Z');
        final copied = dt.copyWith();
        expect(copied.year, dt.year);
        expect(identical(copied, dt), isFalse);
      });
    });
  });

  group('YangDate', () {
    group('parse valid', () {
      test('should parse date when value has no timezone', () {
        final d = YangDate.parse('2025-12-22');
        expect(d.year, equals(2025));
        expect(d.month, equals(12));
        expect(d.day, equals(22));
        expect(d.timezone, isNull);
      });

      test('should parse date when value has Z timezone', () {
        final d = YangDate.parse('2025-12-22Z');
        expect(d.year, equals(2025));
        expect(d.month, equals(12));
        expect(d.day, equals(22));
        expect(d.timezone, equals('Z'));
      });

      test('should parse date with positive offset +05:30', () {
        final d = YangDate.parse('2025-12-22+05:30');
        expect(d.timezone, equals('+05:30'));
      });

      test('should parse date with negative offset -08:00', () {
        final d = YangDate.parse('2025-12-22-08:00');
        expect(d.timezone, equals('-08:00'));
      });
    });

    group('parse rejects', () {
      test('should throw DateFormatError when month is 13', () {
        expect(
          () => YangDate.parse('2025-13-01'),
          throwsA(isA<DateFormatError>()),
        );
      });

      test('should throw DateFormatError when day is 32', () {
        expect(
          () => YangDate.parse('2025-01-32'),
          throwsA(isA<DateFormatError>()),
        );
      });

      test('should throw DateFormatError when year is negative', () {
        expect(
          () => YangDate.parse('-0001-01-01'),
          throwsA(isA<DateFormatError>()),
        );
      });
    });

    group('copyWith', () {
      test('should create copy with modified year', () {
        final d = YangDate.parse('2025-12-22');
        final copied = d.copyWith(year: 2026);
        expect(copied.year, 2026);
      });
    });
  });

  group('YangDateNoZone', () {
    group('parse valid', () {
      test('should parse date when value has no zone', () {
        final d = YangDateNoZone.parse('2025-12-22');
        expect(d.year, equals(2025));
        expect(d.month, equals(12));
        expect(d.day, equals(22));
      });
    });

    group('parse rejects', () {
      test('should throw DateFormatError when month is 13', () {
        expect(
          () => YangDateNoZone.parse('2025-13-01'),
          throwsA(isA<DateFormatError>()),
        );
      });

      test('should throw DateFormatError when day is 32', () {
        expect(
          () => YangDateNoZone.parse('2025-01-32'),
          throwsA(isA<DateFormatError>()),
        );
      });

      test('should throw DateFormatError when value contains timezone', () {
        expect(
          () => YangDateNoZone.parse('2025-12-22Z'),
          throwsA(isA<DateFormatError>()),
        );
      });

      test('should throw DateFormatError when string is empty', () {
        expect(
          () => YangDateNoZone.parse(''),
          throwsA(isA<DateFormatError>()),
        );
      });
    });

    group('copyWith', () {
      test('should create copy with modified day', () {
        final d = YangDateNoZone.parse('2025-12-22');
        final copied = d.copyWith(day: 25);
        expect(copied.day, 25);
      });
    });
  });

  group('YangTime', () {
    group('parse valid', () {
      test('should parse time when value has positive offset', () {
        final t = YangTime.parse('14:30:00+01:00');
        expect(t.hour, equals(14));
        expect(t.minute, equals(30));
        expect(t.second, equals(0));
        expect(t.fractionalSeconds, isNull);
        expect(t.timezone, equals('+01:00'));
        expect(t.hasLeapSecond, isFalse);
      });

      test('should parse time when value has Z timezone', () {
        final t = YangTime.parse('14:30:00Z');
        expect(t.hour, equals(14));
        expect(t.minute, equals(30));
        expect(t.second, equals(0));
        expect(t.timezone, equals('Z'));
      });

      test('should parse time with +05:30 offset', () {
        final t = YangTime.parse('14:30:00+05:30');
        expect(t.timezone, equals('+05:30'));
      });

      test('should parse time with negative offset', () {
        final t = YangTime.parse('14:30:00-05:00');
        expect(t.timezone, equals('-05:00'));
      });

      test('should accept fractional seconds', () {
        final t = YangTime.parse('14:30:00.123456');
        expect(t.hour, equals(14));
        expect(t.minute, equals(30));
        expect(t.second, equals(0));
        expect(t.fractionalSeconds, equals(0.123456));
        expect(t.timezone, isNull);
      });

      test('should accept fractional seconds with timezone', () {
        final t = YangTime.parse('14:30:00.5+01:00');
        expect(t.fractionalSeconds, equals(0.5));
        expect(t.timezone, equals('+01:00'));
      });

      test('should accept leap second when value is 60', () {
        final t = YangTime.parse('23:59:60Z');
        expect(t.second, equals(60));
        expect(t.hasLeapSecond, isTrue);
      });

      test('should parse time without timezone', () {
        final t = YangTime.parse('14:30:00');
        expect(t.timezone, isNull);
      });
    });

    group('parse rejects', () {
      test('should throw TimeFormatError when hour is 24', () {
        expect(
          () => YangTime.parse('24:00:00'),
          throwsA(isA<TimeFormatError>()),
        );
      });

      test('should throw TimeFormatError when minute is 60', () {
        expect(
          () => YangTime.parse('00:60:00'),
          throwsA(isA<TimeFormatError>()),
        );
      });

      test('should throw TimeFormatError when second is 61', () {
        expect(
          () => YangTime.parse('00:00:61'),
          throwsA(isA<TimeFormatError>()),
        );
      });

      test('should throw DateFormatError when timezone offset hour is invalid', () {
        expect(
          () => YangTime.parse('14:30:00+25:00'),
          throwsA(isA<DateFormatError>()),
        );
      });
    });

    group('copyWith', () {
      test('should create copy with modified hour', () {
        final t = YangTime.parse('14:30:00Z');
        final copied = t.copyWith(hour: 10);
        expect(copied.hour, 10);
        expect(copied.minute, 30);
      });
    });
  });

  group('YangTimeNoZone', () {
    group('parse valid', () {
      test('should parse time when value has no zone', () {
        final t = YangTimeNoZone.parse('14:30:00');
        expect(t.hour, equals(14));
        expect(t.minute, equals(30));
        expect(t.second, equals(0));
        expect(t.fractionalSeconds, isNull);
        expect(t.hasLeapSecond, isFalse);
      });

      test('should accept fractional seconds', () {
        final t = YangTimeNoZone.parse('14:30:00.999999');
        expect(t.fractionalSeconds, equals(0.999999));
        expect(t.hasLeapSecond, isFalse);
      });

      test('should accept leap second when value is 60', () {
        final t = YangTimeNoZone.parse('23:59:60');
        expect(t.second, equals(60));
        expect(t.hasLeapSecond, isTrue);
      });
    });

    group('parse rejects', () {
      test('should throw TimeFormatError when hour is 24', () {
        expect(
          () => YangTimeNoZone.parse('24:00:00'),
          throwsA(isA<TimeFormatError>()),
        );
      });

      test('should throw TimeFormatError when second is 61', () {
        expect(
          () => YangTimeNoZone.parse('00:00:61'),
          throwsA(isA<TimeFormatError>()),
        );
      });

      test('should throw DateFormatError when value contains timezone', () {
        expect(
          () => YangTimeNoZone.parse('14:30:00Z'),
          throwsA(isA<DateFormatError>()),
        );
      });

      test('should throw DateFormatError when string is empty', () {
        expect(
          () => YangTimeNoZone.parse(''),
          throwsA(isA<DateFormatError>()),
        );
      });
    });

    group('copyWith', () {
      test('should create copy with modified minute', () {
        final t = YangTimeNoZone.parse('14:30:00');
        final copied = t.copyWith(minute: 45);
        expect(copied.minute, 45);
      });
    });
  });
}
