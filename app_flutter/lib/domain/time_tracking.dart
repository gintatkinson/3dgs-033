class TimeTrackingValidationException implements Exception {
  final String message;

  const TimeTrackingValidationException(this.message);

  @override
  String toString() => 'TimeTrackingValidationException: $message';
}

class TimeTicks {
  static const int maxValue = 4294967295;
  static const int _modulus = 4294967296;
  static const int _millisecondsPerCentisecond = 10;

  final int value;
  final bool hasWrapped;

  const TimeTicks._(this.value, this.hasWrapped);

  TimeTicks(int value)
      : value = _validate(value),
        hasWrapped = false;

  static int _validate(int v) {
    if (v < 0) {
      throw TimeTrackingValidationException(
        'TimeTicks value must be non-negative, got $v',
      );
    }
    if (v > maxValue) {
      throw TimeTrackingValidationException(
        'TimeTicks value exceeds maximum $maxValue, got $v',
      );
    }
    return v;
  }

  Duration toDuration() => Duration(milliseconds: value * _millisecondsPerCentisecond);

  TimeTicks advance(int ticks) {
    final int newRaw = value + ticks;
    if (newRaw > maxValue) {
      return TimeTicks._(newRaw % _modulus, true);
    }
    return TimeTicks._(newRaw, false);
  }

  int deltaTo(TimeTicks previous) {
    if (value >= previous.value) {
      return value - previous.value;
    }
    return _modulus - previous.value + value;
  }
}

class TimeStamp {
  static const int maxValue = 4294967295;

  final int value;

  const TimeStamp._(this.value);

  TimeStamp(int value) : value = _validate(value);

  static int _validate(int v) {
    if (v < 0) {
      throw TimeTrackingValidationException(
        'TimeStamp value must be non-negative, got $v',
      );
    }
    if (v > maxValue) {
      throw TimeTrackingValidationException(
        'TimeStamp value exceeds maximum $maxValue, got $v',
      );
    }
    return v;
  }

  bool get isBeforeLastZero => value == 0;

  TimeStamp reset() => const TimeStamp._(0);
}
