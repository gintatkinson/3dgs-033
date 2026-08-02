import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Error thrown when a date component fails validation.
///
/// [field] identifies the invalid component (e.g. "month", "day", "year", "timezone").
/// [value] is the offending value as a string representation.
@immutable
class DateFormatError implements Exception {
  final String field;
  final String value;

  const DateFormatError({required this.field, required this.value});

  @override
  String toString() => 'DateFormatError: $field is invalid ($value)';
}

/// Error thrown when a time component fails validation.
///
/// [field] identifies the invalid component (e.g. "hour", "minute", "second").
/// [value] is the offending value as a string representation.
@immutable
class TimeFormatError implements Exception {
  final String field;
  final String value;

  const TimeFormatError({required this.field, required this.value});

  @override
  String toString() => 'TimeFormatError: $field is invalid ($value)';
}

/// Error thrown when a leap second (value 60) is specified in a context
/// where a leap second is not applicable.
@immutable
class LeapSecondError implements Exception {
  const LeapSecondError();

  @override
  String toString() => 'LeapSecondError: seconds value 60 outside leap second context';
}

/// A profile of ISO 8601 for representing dates and times with the Gregorian calendar.
///
/// Supports optional time zone offsets (Z, +/-HH:MM) and leap seconds (seconds=60).
@immutable
@realizes(r'UML::DateTime.value')
class YangDateTime {
  static final _pattern = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.(\d+))?(Z|[+-]\d{2}:\d{2})?$',
  );

  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int second;
  final double? fractionalSeconds;
  final String? timezone;
  final bool hasLeapSecond;
  final DateTime? parsed;

  const YangDateTime._({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
    this.fractionalSeconds,
    this.timezone,
    required this.hasLeapSecond,
    this.parsed,
  });

  /// Parses a date-and-time string in RFC 3339 / ISO 8601 profile format.
  ///
  /// Throws [DateFormatError] if the date components are invalid.
  /// Throws [TimeFormatError] if the time components are invalid.
  factory YangDateTime.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) {
      throw const DateFormatError(field: 'pattern', value: '');
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final hour = int.parse(match.group(4)!);
    final minute = int.parse(match.group(5)!);
    final second = int.parse(match.group(6)!);
    final fracStr = match.group(7);
    final timezone = match.group(8);

    _validateDateComponents(year, month, day);
    _validateTimeComponents(hour, minute, second);
    _validateTimezone(timezone);

    final double? fractionalSeconds =
        fracStr != null ? double.parse('0.$fracStr') : null;

    final hasLeapSecond = second == 60;

    DateTime? parsed;
    if (timezone != null && !hasLeapSecond) {
      try {
        parsed = DateTime.parse(value);
      } on FormatException {
        parsed = null;
      }
    }

    return YangDateTime._(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      fractionalSeconds: fractionalSeconds,
      timezone: timezone,
      hasLeapSecond: hasLeapSecond,
      parsed: parsed,
    );
  }

  /// Creates a copy of this [YangDateTime] with optionally modified fields.
  YangDateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    double? fractionalSeconds,
    String? timezone,
  }) {
    return YangDateTime._(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      fractionalSeconds: fractionalSeconds ?? this.fractionalSeconds,
      timezone: timezone ?? this.timezone,
      hasLeapSecond: (second ?? this.second) == 60,
      parsed: null,
    );
  }
}

/// A 24-hour day interval representation with optional time zone.
@immutable
@realizes(r'UML::Date.value')
class YangDate {
  static final _pattern = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})(Z|[+-]\d{2}:\d{2})?$',
  );

  final int year;
  final int month;
  final int day;
  final String? timezone;

  const YangDate._({
    required this.year,
    required this.month,
    required this.day,
    this.timezone,
  });

  /// Parses a date string in YYYY-MM-DD format with optional time zone.
  ///
  /// Throws [DateFormatError] if the date components are invalid.
  factory YangDate.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) {
      throw const DateFormatError(field: 'pattern', value: '');
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final timezone = match.group(4);

    _validateDateComponents(year, month, day);
    _validateTimezone(timezone);

    return YangDate._(
      year: year,
      month: month,
      day: day,
      timezone: timezone,
    );
  }

  /// Creates a copy of this [YangDate] with optionally modified fields.
  YangDate copyWith({
    int? year,
    int? month,
    int? day,
    String? timezone,
  }) {
    return YangDate._(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      timezone: timezone ?? this.timezone,
    );
  }
}

/// A date without time zone information, derived from [YangDate].
@immutable
@realizes(r'UML::DateNoZone.value')
class YangDateNoZone {
  static final _pattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  const YangDateNoZone._({
    required this.year,
    required this.month,
    required this.day,
  });

  /// Parses a date string in YYYY-MM-DD format without time zone.
  ///
  /// Throws [DateFormatError] if the date components are invalid or a time zone is present.
  factory YangDateNoZone.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) {
      throw const DateFormatError(field: 'pattern', value: '');
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);

    _validateDateComponents(year, month, day);

    return YangDateNoZone._(year: year, month: month, day: day);
  }

  /// Creates a copy of this [YangDateNoZone] with optionally modified fields.
  YangDateNoZone copyWith({
    int? year,
    int? month,
    int? day,
  }) {
    return YangDateNoZone._(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
    );
  }
}

/// A recurring instant of zero duration each day, with optional time zone.
@immutable
@realizes(r'UML::Time.value')
class YangTime {
  static final _pattern = RegExp(
    r'^(\d{2}):(\d{2}):(\d{2})(?:\.(\d+))?(Z|[+-]\d{2}:\d{2})?$',
  );

  final int hour;
  final int minute;
  final int second;
  final double? fractionalSeconds;
  final String? timezone;
  final bool hasLeapSecond;

  const YangTime._({
    required this.hour,
    required this.minute,
    required this.second,
    this.fractionalSeconds,
    this.timezone,
    required this.hasLeapSecond,
  });

  /// Parses a time string in HH:MM:SS format with optional time zone.
  ///
  /// Throws [TimeFormatError] if the time components are invalid.
  /// Throws [DateFormatError] if the timezone offset is invalid.
  factory YangTime.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) {
      throw const DateFormatError(field: 'pattern', value: '');
    }

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final second = int.parse(match.group(3)!);
    final fracStr = match.group(4);
    final timezone = match.group(5);

    _validateTimeComponents(hour, minute, second);
    _validateTimezone(timezone);

    final double? fractionalSeconds =
        fracStr != null ? double.parse('0.$fracStr') : null;

    return YangTime._(
      hour: hour,
      minute: minute,
      second: second,
      fractionalSeconds: fractionalSeconds,
      timezone: timezone,
      hasLeapSecond: second == 60,
    );
  }

  /// Creates a copy of this [YangTime] with optionally modified fields.
  YangTime copyWith({
    int? hour,
    int? minute,
    int? second,
    double? fractionalSeconds,
    String? timezone,
  }) {
    return YangTime._(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      fractionalSeconds: fractionalSeconds ?? this.fractionalSeconds,
      timezone: timezone ?? this.timezone,
      hasLeapSecond: (second ?? this.second) == 60,
    );
  }
}

/// A time without time zone information, derived from [YangTime].
@immutable
@realizes(r'UML::TimeNoZone.value')
class YangTimeNoZone {
  static final _pattern = RegExp(r'^(\d{2}):(\d{2}):(\d{2})(?:\.(\d+))?$');

  final int hour;
  final int minute;
  final int second;
  final double? fractionalSeconds;
  final bool hasLeapSecond;

  const YangTimeNoZone._({
    required this.hour,
    required this.minute,
    required this.second,
    this.fractionalSeconds,
    required this.hasLeapSecond,
  });

  /// Parses a time string in HH:MM:SS format without time zone.
  ///
  /// Throws [TimeFormatError] if the time components are invalid.
  /// Throws [DateFormatError] if a time zone is present.
  factory YangTimeNoZone.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) {
      throw const DateFormatError(field: 'pattern', value: '');
    }

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final second = int.parse(match.group(3)!);
    final fracStr = match.group(4);

    _validateTimeComponents(hour, minute, second);

    final double? fractionalSeconds =
        fracStr != null ? double.parse('0.$fracStr') : null;

    return YangTimeNoZone._(
      hour: hour,
      minute: minute,
      second: second,
      fractionalSeconds: fractionalSeconds,
      hasLeapSecond: second == 60,
    );
  }

  /// Creates a copy of this [YangTimeNoZone] with optionally modified fields.
  YangTimeNoZone copyWith({
    int? hour,
    int? minute,
    int? second,
    double? fractionalSeconds,
  }) {
    return YangTimeNoZone._(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      fractionalSeconds: fractionalSeconds ?? this.fractionalSeconds,
      hasLeapSecond: (second ?? this.second) == 60,
    );
  }
}

void _validateDateComponents(int year, int month, int day) {
  if (year < 0) {
    throw DateFormatError(field: 'year', value: year.toString());
  }
  if (month < 1 || month > 12) {
    throw DateFormatError(field: 'month', value: month.toString());
  }
  if (day < 1 || day > 31) {
    throw DateFormatError(field: 'day', value: day.toString());
  }
}

void _validateTimeComponents(int hour, int minute, int second) {
  if (hour < 0 || hour > 23) {
    throw TimeFormatError(field: 'hour', value: hour.toString());
  }
  if (minute < 0 || minute > 59) {
    throw TimeFormatError(field: 'minute', value: minute.toString());
  }
  if (second < 0 || second > 60) {
    throw TimeFormatError(field: 'second', value: second.toString());
  }
}

void _validateTimezone(String? timezone) {
  if (timezone == null || timezone == 'Z') return;

  final match = RegExp(r'^([+-])(\d{2}):(\d{2})$').firstMatch(timezone);
  if (match == null) {
    throw DateFormatError(field: 'timezone', value: timezone);
  }

  final tzHour = int.parse(match.group(2)!);
  final tzMinute = int.parse(match.group(3)!);

  if (tzHour > 23) {
    throw DateFormatError(field: 'timezone-hour', value: tzHour.toString());
  }
  if (tzMinute > 59) {
    throw DateFormatError(field: 'timezone-minute', value: tzMinute.toString());
  }
}
