class CounterGaugeValidationException implements Exception {
  final String message;

  const CounterGaugeValidationException(this.message);

  @override
  String toString() => 'CounterGaugeValidationException: $message';
}

class Counter32 {
  static const int maxValue = 4294967295;

  final int value;
  final bool hasWrapped;

  Counter32(int initialValue)
      : value = _validate(initialValue),
        hasWrapped = false;

  const Counter32._(this.value, this.hasWrapped);

  static int _validate(int v) {
    if (v < 0) {
      throw CounterGaugeValidationException(
        'Counter32 value must not be negative, got $v',
      );
    }
    if (v > maxValue) {
      throw CounterGaugeValidationException(
        'Counter32 value exceeds maximum $maxValue, got $v',
      );
    }
    return v;
  }

  Counter32 increment() {
    if (value == maxValue) {
      return const Counter32._(0, true);
    }
    return Counter32._(value + 1, false);
  }

  Counter32 reset() {
    return Counter32._(value, false);
  }
}

class ZeroBasedCounter32 extends Counter32 {
  ZeroBasedCounter32() : super(0);

  const ZeroBasedCounter32._(int value, bool hasWrapped)
      : super._(value, hasWrapped);

  @override
  ZeroBasedCounter32 increment() {
    if (value == Counter32.maxValue) {
      return const ZeroBasedCounter32._(0, true);
    }
    return ZeroBasedCounter32._(value + 1, false);
  }

  @override
  ZeroBasedCounter32 reset() {
    return const ZeroBasedCounter32._(0, false);
  }
}

class Counter64 {
  static final BigInt maxValue = BigInt.parse('18446744073709551615');

  final BigInt value;
  final bool hasWrapped;

  Counter64(BigInt initialValue)
      : value = _validate(initialValue),
        hasWrapped = false;

  const Counter64._(this.value, this.hasWrapped);

  static BigInt _validate(BigInt v) {
    if (v.isNegative) {
      throw const CounterGaugeValidationException(
        'Counter64 value must not be negative',
      );
    }
    if (v > maxValue) {
      throw CounterGaugeValidationException(
        'Counter64 value exceeds maximum $maxValue',
      );
    }
    return v;
  }

  Counter64 increment() {
    if (value == maxValue) {
      return Counter64._(BigInt.zero, true);
    }
    return Counter64._(value + BigInt.one, false);
  }

  Counter64 reset() {
    return Counter64._(value, false);
  }
}

class ZeroBasedCounter64 extends Counter64 {
  ZeroBasedCounter64() : super(BigInt.zero);

  const ZeroBasedCounter64._(BigInt value, bool hasWrapped)
      : super._(value, hasWrapped);

  @override
  ZeroBasedCounter64 increment() {
    if (value == Counter64.maxValue) {
      return ZeroBasedCounter64._(BigInt.zero, true);
    }
    return ZeroBasedCounter64._(value + BigInt.one, false);
  }

  @override
  ZeroBasedCounter64 reset() {
    return ZeroBasedCounter64._(BigInt.zero, false);
  }
}

class Gauge32 {
  static const int maxValue = 4294967295;

  final int value;

  const Gauge32._(this.value);

  Gauge32(int initialValue) : value = _clamp(initialValue);

  static int _clamp(int v) {
    if (v < 0) return 0;
    if (v > maxValue) return maxValue;
    return v;
  }

  bool get isSaturated => value == 0 || value == maxValue;

  Gauge32 set(int newValue) {
    return Gauge32._(_clamp(newValue));
  }
}

class Gauge64 {
  static final BigInt maxValue = BigInt.parse('18446744073709551615');
  static final BigInt _zero = BigInt.zero;

  final BigInt value;

  const Gauge64._(this.value);

  Gauge64(BigInt initialValue) : value = _clamp(initialValue);

  static BigInt _clamp(BigInt v) {
    if (v.isNegative) return _zero;
    if (v > maxValue) return maxValue;
    return v;
  }

  bool get isSaturated => value == _zero || value == maxValue;

  Gauge64 set(BigInt newValue) {
    return Gauge64._(_clamp(newValue));
  }
}
