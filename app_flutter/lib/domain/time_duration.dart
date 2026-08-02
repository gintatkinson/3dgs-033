import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Error thrown when a duration value is outside its valid range.
///
/// [type] identifies the duration type (e.g. "Hours32").
/// [value] is the offending value.
/// [max] is the maximum allowed value for this type.
@immutable
class DurationRangeError implements Exception {
  final String type;
  final Object value;
  final Object max;

  const DurationRangeError({
    required this.type,
    required this.value,
    required this.max,
  });

  @override
  String toString() =>
      'DurationRangeError: $type value $value exceeds maximum $max';
}

/// Error thrown when converting between duration units would overflow.
///
/// [from] is the source unit (e.g. "milliseconds").
/// [to] is the target unit.
/// [value] is the value being converted.
@immutable
class DurationConversionError implements Exception {
  final String from;
  final String to;
  final Object value;

  const DurationConversionError({
    required this.from,
    required this.to,
    required this.value,
  });

  @override
  String toString() =>
      'DurationConversionError: cannot convert $value from $from to $to';
}

/// A period of time measured in units of hours (int32 range).
@immutable
@realizes(r'UML::Hours32.value')
class Hours32 {
  static const int maxValue = 2147483647;
  static const int _minutesPerHour = 60;
  static const int _secondsPerHour = 3600;

  final int value;

  const Hours32._({required this.value});

  Hours32(int value) : value = _validate(value);

  /// Creates [Hours32] from an integer number of hours.
  factory Hours32.fromHours(int n) => Hours32(n);

  static int _validate(int v) {
    if (v < 0 || v > maxValue) {
      throw DurationRangeError(type: 'Hours32', value: v, max: maxValue);
    }
    return v;
  }

  /// Converts to the equivalent number of minutes.
  int toMinutes() => value * _minutesPerHour;

  /// Converts to the equivalent number of seconds.
  int toSeconds() => value * _secondsPerHour;

  /// Creates a copy with an optionally modified value.
  Hours32 copyWith({int? value}) {
    return Hours32._(value: value ?? this.value);
  }
}

/// A period of time measured in units of minutes (int32 range).
@immutable
@realizes(r'UML::Minutes32.value')
class Minutes32 {
  static const int maxValue = 2147483647;
  static const int _secondsPerMinute = 60;

  final int value;

  const Minutes32._({required this.value});

  Minutes32(int value) : value = _validate(value);

  /// Creates [Minutes32] from an integer number of minutes.
  factory Minutes32.fromMinutes(int n) => Minutes32(n);

  static int _validate(int v) {
    if (v < 0 || v > maxValue) {
      throw DurationRangeError(type: 'Minutes32', value: v, max: maxValue);
    }
    return v;
  }

  /// Converts to the equivalent number of seconds.
  int toSeconds() => value * _secondsPerMinute;

  /// Converts to the equivalent number of hours.
  int toHours() => value ~/ _secondsPerMinute;

  /// Creates a copy with an optionally modified value.
  Minutes32 copyWith({int? value}) {
    return Minutes32._(value: value ?? this.value);
  }
}

/// A period of time measured in units of seconds (int32 range).
@immutable
@realizes(r'UML::Seconds32.value')
class Seconds32 {
  static const int maxValue = 2147483647;
  static const int _millisecondsPerSecond = 1000;

  final int value;

  const Seconds32._({required this.value});

  Seconds32(int value) : value = _validate(value);

  /// Creates [Seconds32] from an integer number of seconds.
  factory Seconds32.fromSeconds(int n) => Seconds32(n);

  static int _validate(int v) {
    if (v < 0 || v > maxValue) {
      throw DurationRangeError(type: 'Seconds32', value: v, max: maxValue);
    }
    return v;
  }

  /// Converts to the equivalent number of milliseconds.
  int toMilliseconds() => value * _millisecondsPerSecond;

  /// Converts to the equivalent number of minutes.
  int toMinutes() => value ~/ Minutes32._secondsPerMinute;

  /// Converts to the equivalent number of hours.
  int toHours() => value ~/ Hours32._secondsPerHour;

  /// Creates a copy with an optionally modified value.
  Seconds32 copyWith({int? value}) {
    return Seconds32._(value: value ?? this.value);
  }
}

/// A period of time measured in units of 10^-2 seconds (int32 range).
@immutable
@realizes(r'UML::Centiseconds32.value')
class Centiseconds32 {
  static const int maxValue = 2147483647;
  static const int _millisecondsPerCentisecond = 10;
  static const int _centisecondsPerSecond = 100;

  final int value;

  const Centiseconds32._({required this.value});

  Centiseconds32(int value) : value = _validate(value);

  /// Creates [Centiseconds32] from an integer number of centiseconds.
  factory Centiseconds32.fromCentiseconds(int n) => Centiseconds32(n);

  static int _validate(int v) {
    if (v < 0 || v > maxValue) {
      throw DurationRangeError(
          type: 'Centiseconds32', value: v, max: maxValue);
    }
    return v;
  }

  /// Converts to the equivalent number of milliseconds.
  int toMilliseconds() => value * _millisecondsPerCentisecond;

  /// Converts to the equivalent number of seconds.
  int toSeconds() => value ~/ _centisecondsPerSecond;

  /// Creates a copy with an optionally modified value.
  Centiseconds32 copyWith({int? value}) {
    return Centiseconds32._(value: value ?? this.value);
  }
}

/// A period of time measured in units of 10^-3 seconds (int32 range).
@immutable
@realizes(r'UML::Milliseconds32.value')
class Milliseconds32 {
  static const int maxValue = 2147483647;
  static const int _microsecondsPerMillisecond = 1000;
  static const int _millisecondsPerSecond = 1000;

  final int value;

  const Milliseconds32._({required this.value});

  Milliseconds32(int value) : value = _validate(value);

  /// Creates [Milliseconds32] from an integer number of milliseconds.
  factory Milliseconds32.fromMilliseconds(int n) => Milliseconds32(n);

  static int _validate(int v) {
    if (v < 0 || v > maxValue) {
      throw DurationRangeError(
          type: 'Milliseconds32', value: v, max: maxValue);
    }
    return v;
  }

  /// Converts to the equivalent number of seconds.
  int toSeconds() => value ~/ _millisecondsPerSecond;

  /// Converts to the equivalent number of microseconds.
  int toMicroseconds() => value * _microsecondsPerMillisecond;

  /// Creates a copy with an optionally modified value.
  Milliseconds32 copyWith({int? value}) {
    return Milliseconds32._(value: value ?? this.value);
  }
}

/// A period of time measured in units of 10^-6 seconds (int32 range).
@immutable
@realizes(r'UML::Microseconds32.value')
class Microseconds32 {
  static const int maxValue = 2147483647;
  static const int _nanosecondsPerMicrosecond = 1000;
  static const int _microsecondsPerMillisecond = 1000;

  final int value;

  const Microseconds32._({required this.value});

  Microseconds32(int value) : value = _validate(value);

  /// Creates [Microseconds32] from an integer number of microseconds.
  factory Microseconds32.fromMicroseconds(int n) => Microseconds32(n);

  static int _validate(int v) {
    if (v < 0 || v > maxValue) {
      throw DurationRangeError(
          type: 'Microseconds32', value: v, max: maxValue);
    }
    return v;
  }

  /// Converts to the equivalent number of nanoseconds.
  int toNanoseconds() => value * _nanosecondsPerMicrosecond;

  /// Converts to the equivalent number of milliseconds.
  int toMilliseconds() => value ~/ _microsecondsPerMillisecond;

  /// Creates a copy with an optionally modified value.
  Microseconds32 copyWith({int? value}) {
    return Microseconds32._(value: value ?? this.value);
  }
}

/// A period of time measured in units of 10^-9 seconds (int32 range).
@immutable
@realizes(r'UML::Nanoseconds32.value')
class Nanoseconds32 {
  static const int maxValue = 2147483647;
  static const int _nanosecondsPerMicrosecond = 1000;
  static const int _nanosecondsPerMillisecond = 1000000;

  final int value;

  const Nanoseconds32._({required this.value});

  Nanoseconds32(int value) : value = _validate(value);

  /// Creates [Nanoseconds32] from an integer number of nanoseconds.
  factory Nanoseconds32.fromNanoseconds(int n) => Nanoseconds32(n);

  static int _validate(int v) {
    if (v < 0 || v > maxValue) {
      throw DurationRangeError(
          type: 'Nanoseconds32', value: v, max: maxValue);
    }
    return v;
  }

  /// Converts to the equivalent number of microseconds.
  int toMicroseconds() => value ~/ _nanosecondsPerMicrosecond;

  /// Converts to the equivalent number of milliseconds.
  int toMilliseconds() => value ~/ _nanosecondsPerMillisecond;

  /// Creates a copy with an optionally modified value.
  Nanoseconds32 copyWith({int? value}) {
    return Nanoseconds32._(value: value ?? this.value);
  }
}

/// A period of time measured in units of 10^-6 seconds (int64 range).
@immutable
@realizes(r'UML::Microseconds64.value')
class Microseconds64 {
  static final BigInt maxValue = BigInt.parse('9223372036854775807');
  static final BigInt _nanosecondsPerMicrosecond = BigInt.from(1000);
  static final BigInt _microsecondsPerMillisecond = BigInt.from(1000);

  final BigInt value;

  const Microseconds64._({required this.value});

  Microseconds64(BigInt value) : value = _validate(value);

  /// Creates [Microseconds64] from a BigInt number of microseconds.
  factory Microseconds64.fromMicroseconds(BigInt n) => Microseconds64(n);

  static BigInt _validate(BigInt v) {
    if (v.isNegative || v > maxValue) {
      throw DurationRangeError(
          type: 'Microseconds64', value: v, max: maxValue);
    }
    return v;
  }

  /// Converts to the equivalent number of nanoseconds.
  BigInt toNanoseconds() => value * _nanosecondsPerMicrosecond;

  /// Converts to the equivalent number of milliseconds.
  BigInt toMilliseconds() => value ~/ _microsecondsPerMillisecond;

  /// Creates a copy with an optionally modified value.
  Microseconds64 copyWith({BigInt? value}) {
    return Microseconds64._(value: value ?? this.value);
  }
}

/// A period of time measured in units of 10^-9 seconds (int64 range).
@immutable
@realizes(r'UML::Nanoseconds64.value')
class Nanoseconds64 {
  static final BigInt maxValue = BigInt.parse('9223372036854775807');
  static final BigInt _nanosecondsPerMicrosecond = BigInt.from(1000);
  static final BigInt _nanosecondsPerMillisecond = BigInt.from(1000000);

  final BigInt value;

  const Nanoseconds64._({required this.value});

  Nanoseconds64(BigInt value) : value = _validate(value);

  /// Creates [Nanoseconds64] from a BigInt number of nanoseconds.
  factory Nanoseconds64.fromNanoseconds(BigInt n) => Nanoseconds64(n);

  static BigInt _validate(BigInt v) {
    if (v.isNegative || v > maxValue) {
      throw DurationRangeError(
          type: 'Nanoseconds64', value: v, max: maxValue);
    }
    return v;
  }

  /// Converts to the equivalent number of microseconds.
  BigInt toMicroseconds() => value ~/ _nanosecondsPerMicrosecond;

  /// Converts to the equivalent number of milliseconds.
  BigInt toMilliseconds() => value ~/ _nanosecondsPerMillisecond;

  /// Creates a copy with an optionally modified value.
  Nanoseconds64 copyWith({BigInt? value}) {
    return Nanoseconds64._(value: value ?? this.value);
  }
}
