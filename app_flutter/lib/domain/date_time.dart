class DateTimeValidationException implements Exception {
  final String message;

  const DateTimeValidationException(this.message);

  @override
  String toString() => 'DateTimeValidationException: $message';
}

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

  factory YangDateTime.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) {
      throw const DateTimeValidationException(
        'date-and-time must match pattern YYYY-MM-DDTHH:MM:SS[.f+][Z|(+|-)HH:MM]',
      );
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final hour = int.parse(match.group(4)!);
    final minute = int.parse(match.group(5)!);
    final second = int.parse(match.group(6)!);
    final fracStr = match.group(7);
    final timezone = match.group(8);

    _validateDateComponents(year, month, day, 'date-and-time');
    _validateTimeComponents(hour, minute, second, 'date-and-time');
    _validateTimezone(timezone, 'date-and-time');

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
}

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

  factory YangDate.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) {
      throw const DateTimeValidationException(
        'date must match pattern YYYY-MM-DD[Z|(+|-)HH:MM]',
      );
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final timezone = match.group(4);

    _validateDateComponents(year, month, day, 'date');
    _validateTimezone(timezone, 'date');

    return YangDate._(
      year: year,
      month: month,
      day: day,
      timezone: timezone,
    );
  }
}

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

  factory YangDateNoZone.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) {
      throw const DateTimeValidationException(
        'date-no-zone must match pattern YYYY-MM-DD',
      );
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);

    _validateDateComponents(year, month, day, 'date-no-zone');

    return YangDateNoZone._(year: year, month: month, day: day);
  }
}

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

  factory YangTime.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) {
      throw const DateTimeValidationException(
        'time must match pattern HH:MM:SS[.f+][Z|(+|-)HH:MM]',
      );
    }

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final second = int.parse(match.group(3)!);
    final fracStr = match.group(4);
    final timezone = match.group(5);

    _validateTimeComponents(hour, minute, second, 'time');
    _validateTimezone(timezone, 'time');

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
}

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

  factory YangTimeNoZone.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) {
      throw const DateTimeValidationException(
        'time-no-zone must match pattern HH:MM:SS[.f+]',
      );
    }

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final second = int.parse(match.group(3)!);
    final fracStr = match.group(4);

    _validateTimeComponents(hour, minute, second, 'time-no-zone');

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
}

void _validateDateComponents(
  int year,
  int month,
  int day,
  String typeName,
) {
  if (year < 0) {
    throw DateTimeValidationException(
      '$typeName year must be non-negative, got $year',
    );
  }
  if (month < 1 || month > 12) {
    throw DateTimeValidationException(
      '$typeName month must be 01-12, got $month',
    );
  }
  if (day < 1 || day > 31) {
    throw DateTimeValidationException(
      '$typeName day must be 01-31, got $day',
    );
  }
}

void _validateTimeComponents(
  int hour,
  int minute,
  int second,
  String typeName,
) {
  if (hour < 0 || hour > 23) {
    throw DateTimeValidationException(
      '$typeName hour must be 00-23, got $hour',
    );
  }
  if (minute < 0 || minute > 59) {
    throw DateTimeValidationException(
      '$typeName minute must be 00-59, got $minute',
    );
  }
  if (second < 0 || second > 60) {
    throw DateTimeValidationException(
      '$typeName second must be 00-60, got $second',
    );
  }
}

void _validateTimezone(String? timezone, String typeName) {
  if (timezone == null || timezone == 'Z') return;

  final match = RegExp(r'^([+-])(\d{2}):(\d{2})$').firstMatch(timezone);
  if (match == null) {
    throw DateTimeValidationException(
      '$typeName timezone must be Z or (+|-)HH:MM, got $timezone',
    );
  }

  final tzHour = int.parse(match.group(2)!);
  final tzMinute = int.parse(match.group(3)!);

  if (tzHour > 23) {
    throw DateTimeValidationException(
      '$typeName timezone offset hour must be 00-23, got $tzHour',
    );
  }
  if (tzMinute > 59) {
    throw DateTimeValidationException(
      '$typeName timezone offset minute must be 00-59, got $tzMinute',
    );
  }
}
