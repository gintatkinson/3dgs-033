class DurationValidationException implements Exception {
  final String message;

  const DurationValidationException(this.message);

  @override
  String toString() => 'DurationValidationException: $message';
}

class Hours32 {
  static const int maxValue = 2147483647;
  static const int _minutesPerHour = 60;
  static const int _secondsPerHour = 3600;

  final int value;

  const Hours32._(this.value);

  Hours32(int value) : value = _validate(value);

  factory Hours32.fromHours(int n) => Hours32(n);

  static int _validate(int v) {
    if (v < 0) {
      throw DurationValidationException(
        'Hours32 value must be non-negative, got $v',
      );
    }
    if (v > maxValue) {
      throw DurationValidationException(
        'Hours32 value exceeds maximum $maxValue, got $v',
      );
    }
    return v;
  }

  int toMinutes() => value * _minutesPerHour;
  int toSeconds() => value * _secondsPerHour;
}

class Minutes32 {
  static const int maxValue = 2147483647;
  static const int _secondsPerMinute = 60;

  final int value;

  const Minutes32._(this.value);

  Minutes32(int value) : value = _validate(value);

  factory Minutes32.fromMinutes(int n) => Minutes32(n);

  static int _validate(int v) {
    if (v < 0) {
      throw DurationValidationException(
        'Minutes32 value must be non-negative, got $v',
      );
    }
    if (v > maxValue) {
      throw DurationValidationException(
        'Minutes32 value exceeds maximum $maxValue, got $v',
      );
    }
    return v;
  }

  int toSeconds() => value * _secondsPerMinute;
  int toHours() => value ~/ _secondsPerMinute;
}

class Seconds32 {
  static const int maxValue = 2147483647;
  static const int _millisecondsPerSecond = 1000;

  final int value;

  const Seconds32._(this.value);

  Seconds32(int value) : value = _validate(value);

  factory Seconds32.fromSeconds(int n) => Seconds32(n);

  static int _validate(int v) {
    if (v < 0) {
      throw DurationValidationException(
        'Seconds32 value must be non-negative, got $v',
      );
    }
    if (v > maxValue) {
      throw DurationValidationException(
        'Seconds32 value exceeds maximum $maxValue, got $v',
      );
    }
    return v;
  }

  int toMilliseconds() => value * _millisecondsPerSecond;
  int toMinutes() => value ~/ Minutes32._secondsPerMinute;
  int toHours() => value ~/ Hours32._secondsPerHour;
}

class Centiseconds32 {
  static const int maxValue = 2147483647;
  static const int _millisecondsPerCentisecond = 10;
  static const int _centisecondsPerSecond = 100;

  final int value;

  const Centiseconds32._(this.value);

  Centiseconds32(int value) : value = _validate(value);

  factory Centiseconds32.fromCentiseconds(int n) => Centiseconds32(n);

  static int _validate(int v) {
    if (v < 0) {
      throw DurationValidationException(
        'Centiseconds32 value must be non-negative, got $v',
      );
    }
    if (v > maxValue) {
      throw DurationValidationException(
        'Centiseconds32 value exceeds maximum $maxValue, got $v',
      );
    }
    return v;
  }

  int toMilliseconds() => value * _millisecondsPerCentisecond;
  int toSeconds() => value ~/ _centisecondsPerSecond;
}

class Milliseconds32 {
  static const int maxValue = 2147483647;
  static const int _microsecondsPerMillisecond = 1000;
  static const int _millisecondsPerSecond = 1000;

  final int value;

  const Milliseconds32._(this.value);

  Milliseconds32(int value) : value = _validate(value);

  factory Milliseconds32.fromMilliseconds(int n) => Milliseconds32(n);

  static int _validate(int v) {
    if (v < 0) {
      throw DurationValidationException(
        'Milliseconds32 value must be non-negative, got $v',
      );
    }
    if (v > maxValue) {
      throw DurationValidationException(
        'Milliseconds32 value exceeds maximum $maxValue, got $v',
      );
    }
    return v;
  }

  int toSeconds() => value ~/ _millisecondsPerSecond;
  int toMicroseconds() => value * _microsecondsPerMillisecond;
}

class Microseconds32 {
  static const int maxValue = 2147483647;
  static const int _nanosecondsPerMicrosecond = 1000;
  static const int _microsecondsPerMillisecond = 1000;

  final int value;

  const Microseconds32._(this.value);

  Microseconds32(int value) : value = _validate(value);

  factory Microseconds32.fromMicroseconds(int n) => Microseconds32(n);

  static int _validate(int v) {
    if (v < 0) {
      throw DurationValidationException(
        'Microseconds32 value must be non-negative, got $v',
      );
    }
    if (v > maxValue) {
      throw DurationValidationException(
        'Microseconds32 value exceeds maximum $maxValue, got $v',
      );
    }
    return v;
  }

  int toNanoseconds() => value * _nanosecondsPerMicrosecond;
  int toMilliseconds() => value ~/ _microsecondsPerMillisecond;
}

class Nanoseconds32 {
  static const int maxValue = 2147483647;
  static const int _nanosecondsPerMicrosecond = 1000;
  static const int _nanosecondsPerMillisecond = 1000000;

  final int value;

  const Nanoseconds32._(this.value);

  Nanoseconds32(int value) : value = _validate(value);

  factory Nanoseconds32.fromNanoseconds(int n) => Nanoseconds32(n);

  static int _validate(int v) {
    if (v < 0) {
      throw DurationValidationException(
        'Nanoseconds32 value must be non-negative, got $v',
      );
    }
    if (v > maxValue) {
      throw DurationValidationException(
        'Nanoseconds32 value exceeds maximum $maxValue, got $v',
      );
    }
    return v;
  }

  int toMicroseconds() => value ~/ _nanosecondsPerMicrosecond;
  int toMilliseconds() => value ~/ _nanosecondsPerMillisecond;
}

class Microseconds64 {
  static final BigInt maxValue = BigInt.parse('9223372036854775807');
  static final BigInt _nanosecondsPerMicrosecond = BigInt.from(1000);
  static final BigInt _microsecondsPerMillisecond = BigInt.from(1000);

  final BigInt value;

  const Microseconds64._(this.value);

  Microseconds64(BigInt value) : value = _validate(value);

  factory Microseconds64.fromMicroseconds(BigInt n) => Microseconds64(n);

  static BigInt _validate(BigInt v) {
    if (v.isNegative) {
      throw const DurationValidationException(
        'Microseconds64 value must be non-negative',
      );
    }
    if (v > maxValue) {
      throw DurationValidationException(
        'Microseconds64 value exceeds maximum $maxValue, got $v',
      );
    }
    return v;
  }

  BigInt toNanoseconds() => value * _nanosecondsPerMicrosecond;
  BigInt toMilliseconds() => value ~/ _microsecondsPerMillisecond;
}

class Nanoseconds64 {
  static final BigInt maxValue = BigInt.parse('9223372036854775807');
  static final BigInt _nanosecondsPerMicrosecond = BigInt.from(1000);
  static final BigInt _nanosecondsPerMillisecond = BigInt.from(1000000);

  final BigInt value;

  const Nanoseconds64._(this.value);

  Nanoseconds64(BigInt value) : value = _validate(value);

  factory Nanoseconds64.fromNanoseconds(BigInt n) => Nanoseconds64(n);

  static BigInt _validate(BigInt v) {
    if (v.isNegative) {
      throw const DurationValidationException(
        'Nanoseconds64 value must be non-negative',
      );
    }
    if (v > maxValue) {
      throw DurationValidationException(
        'Nanoseconds64 value exceeds maximum $maxValue, got $v',
      );
    }
    return v;
  }

  BigInt toMicroseconds() => value ~/ _nanosecondsPerMicrosecond;
  BigInt toMilliseconds() => value ~/ _nanosecondsPerMillisecond;
}
