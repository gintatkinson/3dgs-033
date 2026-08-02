import 'package:app_flutter/domain/date_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeValidationException', () {
    test('has message property', () {
      const ex = DateTimeValidationException('test error');
      expect(ex.message, equals('test error'));
      expect(ex.toString(), contains('DateTimeValidationException'));
    });
  });

  group('YangDateTime', () {
    group('parse valid', () {
      test('parse date-and-time with Z timezone', () {
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

      test('parse date-and-time with positive offset', () {
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

      test('parse date-and-time without timezone', () {
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

      test('parse year far future', () {
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

      test('accept leap second 60', () {
        final dt = YangDateTime.parse('2016-12-31T23:59:60Z');
        expect(dt.year, equals(2016));
        expect(dt.month, equals(12));
        expect(dt.day, equals(31));
        expect(dt.hour, equals(23));
        expect(dt.minute, equals(59));
        expect(dt.second, equals(60));
        expect(dt.hasLeapSecond, isTrue);
      });

      test('accept timezone +05:30', () {
        final dt = YangDateTime.parse('2025-12-22T14:30:00+05:30');
        expect(dt.timezone, equals('+05:30'));
        expect(dt.hasLeapSecond, isFalse);
      });

      test('parsed provides Dart DateTime for timezoned values', () {
        final dt = YangDateTime.parse('2025-12-22T14:30:00Z');
        expect(dt.parsed, isNotNull);
        expect(dt.parsed!.year, equals(2025));
        expect(dt.parsed!.month, equals(12));
        expect(dt.parsed!.day, equals(22));
      });

      test('parsed is null for values without timezone', () {
        final dt = YangDateTime.parse('2025-12-22T14:30:00');
        expect(dt.parsed, isNull);
      });

      test('parsed is null for leap second values', () {
        final dt = YangDateTime.parse('2016-12-31T23:59:60Z');
        expect(dt.parsed, isNull);
      });
    });

    group('parse rejects', () {
      test('reject invalid month 13', () {
        expect(
          () => YangDateTime.parse('2025-13-01T00:00:00Z'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject invalid day 32', () {
        expect(
          () => YangDateTime.parse('2025-01-32T00:00:00Z'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject invalid hour 24', () {
        expect(
          () => YangDateTime.parse('2025-01-01T24:00:00Z'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject invalid minute 60', () {
        expect(
          () => YangDateTime.parse('2025-01-01T00:60:00Z'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject second 61', () {
        expect(
          () => YangDateTime.parse('2025-01-01T00:00:61Z'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject negative year', () {
        expect(
          () => YangDateTime.parse('-0001-01-01T00:00:00Z'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject malformed timezone', () {
        expect(
          () => YangDateTime.parse('2025-12-22T14:30:00+25:00'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject missing T separator', () {
        expect(
          () => YangDateTime.parse('2025-12-22 14:30:00Z'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject empty string', () {
        expect(
          () => YangDateTime.parse(''),
          throwsA(isA<DateTimeValidationException>()),
        );
      });
    });
  });

  group('YangDate', () {
    group('parse valid', () {
      test('parse date without timezone', () {
        final d = YangDate.parse('2025-12-22');
        expect(d.year, equals(2025));
        expect(d.month, equals(12));
        expect(d.day, equals(22));
        expect(d.timezone, isNull);
      });

      test('parse date with Z timezone', () {
        final d = YangDate.parse('2025-12-22Z');
        expect(d.year, equals(2025));
        expect(d.month, equals(12));
        expect(d.day, equals(22));
        expect(d.timezone, equals('Z'));
      });

      test('parse date with positive offset', () {
        final d = YangDate.parse('2025-12-22+05:30');
        expect(d.timezone, equals('+05:30'));
      });

      test('parse date with negative offset', () {
        final d = YangDate.parse('2025-12-22-08:00');
        expect(d.timezone, equals('-08:00'));
      });
    });

    group('parse rejects', () {
      test('reject invalid month 13', () {
        expect(
          () => YangDate.parse('2025-13-01'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject invalid day 32', () {
        expect(
          () => YangDate.parse('2025-01-32'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject negative year', () {
        expect(
          () => YangDate.parse('-0001-01-01'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });
    });
  });

  group('YangDateNoZone', () {
    group('parse valid', () {
      test('parse date without zone', () {
        final d = YangDateNoZone.parse('2025-12-22');
        expect(d.year, equals(2025));
        expect(d.month, equals(12));
        expect(d.day, equals(22));
      });
    });

    group('parse rejects', () {
      test('reject invalid month 13', () {
        expect(
          () => YangDateNoZone.parse('2025-13-01'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject invalid day 32', () {
        expect(
          () => YangDateNoZone.parse('2025-01-32'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject date with timezone', () {
        expect(
          () => YangDateNoZone.parse('2025-12-22Z'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject empty string', () {
        expect(
          () => YangDateNoZone.parse(''),
          throwsA(isA<DateTimeValidationException>()),
        );
      });
    });
  });

  group('YangTime', () {
    group('parse valid', () {
      test('parse time with positive offset', () {
        final t = YangTime.parse('14:30:00+01:00');
        expect(t.hour, equals(14));
        expect(t.minute, equals(30));
        expect(t.second, equals(0));
        expect(t.fractionalSeconds, isNull);
        expect(t.timezone, equals('+01:00'));
        expect(t.hasLeapSecond, isFalse);
      });

      test('parse time with Z timezone', () {
        final t = YangTime.parse('14:30:00Z');
        expect(t.hour, equals(14));
        expect(t.minute, equals(30));
        expect(t.second, equals(0));
        expect(t.timezone, equals('Z'));
      });

      test('parse time with +05:30 timezone', () {
        final t = YangTime.parse('14:30:00+05:30');
        expect(t.timezone, equals('+05:30'));
      });

      test('parse time with negative offset', () {
        final t = YangTime.parse('14:30:00-05:00');
        expect(t.timezone, equals('-05:00'));
      });

      test('accept fractional seconds', () {
        final t = YangTime.parse('14:30:00.123456');
        expect(t.hour, equals(14));
        expect(t.minute, equals(30));
        expect(t.second, equals(0));
        expect(t.fractionalSeconds, equals(0.123456));
        expect(t.timezone, isNull);
      });

      test('accept fractional seconds with timezone', () {
        final t = YangTime.parse('14:30:00.5+01:00');
        expect(t.fractionalSeconds, equals(0.5));
        expect(t.timezone, equals('+01:00'));
      });

      test('accept leap second 60', () {
        final t = YangTime.parse('23:59:60Z');
        expect(t.second, equals(60));
        expect(t.hasLeapSecond, isTrue);
      });

      test('parse time without timezone', () {
        final t = YangTime.parse('14:30:00');
        expect(t.timezone, isNull);
      });
    });

    group('parse rejects', () {
      test('reject invalid hour 24', () {
        expect(
          () => YangTime.parse('24:00:00'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject invalid minute 60', () {
        expect(
          () => YangTime.parse('00:60:00'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject second 61', () {
        expect(
          () => YangTime.parse('00:00:61'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject malformed timezone', () {
        expect(
          () => YangTime.parse('14:30:00+25:00'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });
    });
  });

  group('YangTimeNoZone', () {
    group('parse valid', () {
      test('parse time without zone', () {
        final t = YangTimeNoZone.parse('14:30:00');
        expect(t.hour, equals(14));
        expect(t.minute, equals(30));
        expect(t.second, equals(0));
        expect(t.fractionalSeconds, isNull);
        expect(t.hasLeapSecond, isFalse);
      });

      test('accept fractional seconds', () {
        final t = YangTimeNoZone.parse('14:30:00.999999');
        expect(t.fractionalSeconds, equals(0.999999));
        expect(t.hasLeapSecond, isFalse);
      });

      test('accept leap second 60', () {
        final t = YangTimeNoZone.parse('23:59:60');
        expect(t.second, equals(60));
        expect(t.hasLeapSecond, isTrue);
      });
    });

    group('parse rejects', () {
      test('reject invalid hour 24', () {
        expect(
          () => YangTimeNoZone.parse('24:00:00'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject second 61', () {
        expect(
          () => YangTimeNoZone.parse('00:00:61'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject time with timezone', () {
        expect(
          () => YangTimeNoZone.parse('14:30:00Z'),
          throwsA(isA<DateTimeValidationException>()),
        );
      });

      test('reject empty string', () {
        expect(
          () => YangTimeNoZone.parse(''),
          throwsA(isA<DateTimeValidationException>()),
        );
      });
    });
  });
}
