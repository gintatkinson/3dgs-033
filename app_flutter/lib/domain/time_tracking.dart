import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Error thrown when a TimeTicks value overflows or is out of range.
///
/// [maxValue] is the maximum allowed value (2^32-1).
@immutable
class TimeTicksOverflowError implements Exception {
  final int maxValue;

  const TimeTicksOverflowError({required this.maxValue});

  @override
  String toString() =>
      'TimeTicksOverflowError: value exceeds maximum $maxValue';
}

/// Error thrown when a TimeStamp value is invalid or a reset occurs.
@immutable
class TimestampResetError implements Exception {
  final String message;

  const TimestampResetError(this.message);

  @override
  String toString() => 'TimestampResetError: $message';
}

/// Represents non-negative time in hundredths of a second modulo 2^32.
///
/// Timeticks monotonically increase and wrap after ~497 days.
@immutable
@realizes(r'UML::TimeTicks.value')
class TimeTicks {
  static const int maxValue = 4294967295;
  static const int _modulus = 4294967296;
  static const int _millisecondsPerCentisecond = 10;

  final int value;
  final bool hasWrapped;

  const TimeTicks._({required this.value, required this.hasWrapped});

  TimeTicks(int value)
      : value = _validate(value),
        hasWrapped = false;

  static int _validate(int v) {
    if (v < 0 || v > maxValue) {
      throw TimeTicksOverflowError(maxValue: maxValue);
    }
    return v;
  }

  /// Converts the timeticks value to a [Duration].
  Duration toDuration() =>
      Duration(milliseconds: value * _millisecondsPerCentisecond);

  /// Advances the timeticks by [ticks] hundredths of a second, wrapping at 2^32.
  TimeTicks advance(int ticks) {
    final int newRaw = value + ticks;
    if (newRaw > maxValue) {
      return TimeTicks._(value: newRaw % _modulus, hasWrapped: true);
    }
    return TimeTicks._(value: newRaw, hasWrapped: false);
  }

  /// Calculates the positive delta from [previous] to this value,
  /// accounting for wrap-around.
  int deltaTo(TimeTicks previous) {
    if (value >= previous.value) {
      return value - previous.value;
    }
    return _modulus - previous.value + value;
  }

  /// Creates a copy with optionally modified fields.
  TimeTicks copyWith({int? value, bool? hasWrapped}) {
    return TimeTicks._(
      value: value ?? this.value,
      hasWrapped: hasWrapped ?? this.hasWrapped,
    );
  }
}

/// Captures the value of an associated timeticks node when a specific occurrence happened.
///
/// All timestamp values reset to zero when the associated timeticks wraps.
@immutable
@realizes(r'UML::TimeStamp.value')
class TimeStamp {
  static const int maxValue = 4294967295;

  final int value;

  const TimeStamp._({required this.value});

  TimeStamp(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < 0 || v > maxValue) {
      throw const TimestampResetError('TimeStamp value is out of range');
    }
    return v;
  }

  /// Returns `true` when the value is zero, indicating the occurrence happened
  /// before the last timeticks zero point.
  bool get isBeforeLastZero => value == 0;

  /// Resets the timestamp to zero.
  TimeStamp reset() => const TimeStamp._(value: 0);

  /// Creates a copy with an optionally modified value.
  TimeStamp copyWith({int? value}) {
    return TimeStamp._(value: value ?? this.value);
  }
}
