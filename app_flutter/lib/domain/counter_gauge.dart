import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Error thrown when a counter value exceeds its maximum allowed value.
///
/// [maxValue] is the maximum value for this counter type.
@immutable
class CounterOverflowError implements Exception {
  final Object maxValue;

  const CounterOverflowError({required this.maxValue});

  @override
  String toString() => 'CounterOverflowError: value exceeds maximum $maxValue';
}

/// Error thrown when a gauge value is clamped due to saturation.
///
/// [current] is the current gauge value before the attempted change.
/// [attempted] is the value that was attempted to be set.
@immutable
class GaugeSaturationError implements Exception {
  final Object current;
  final Object attempted;

  const GaugeSaturationError({required this.current, required this.attempted});

  @override
  String toString() =>
      'GaugeSaturationError: attempted $attempted saturated from $current';
}

/// Error thrown when a counter is configured incorrectly.
@immutable
class CounterConfigError implements Exception {
  final String message;

  const CounterConfigError(this.message);

  @override
  String toString() => 'CounterConfigError: $message';
}

/// A non-negative 32-bit monotonic counter that wraps at 2^32-1.
@immutable
@realizes(r'UML::Counter32.value')
class Counter32 {
  static const int maxValue = 4294967295;

  final int value;
  final bool hasWrapped;

  Counter32(int initialValue)
      : value = _validate(initialValue),
        hasWrapped = false;

  const Counter32._({required this.value, required this.hasWrapped});

  static int _validate(int v) {
    if (v < 0) {
      throw const CounterConfigError('Counter32 value must not be negative');
    }
    if (v > maxValue) {
      throw CounterOverflowError(maxValue: maxValue);
    }
    return v;
  }

  /// Increments the counter by one, wrapping to 0 at [maxValue].
  Counter32 increment() {
    if (value == maxValue) {
      return const Counter32._(value: 0, hasWrapped: true);
    }
    return Counter32._(value: value + 1, hasWrapped: false);
  }

  /// Resets the discontinuity flag.
  Counter32 reset() {
    return Counter32._(value: value, hasWrapped: false);
  }

  /// Creates a copy of this [Counter32] with optionally modified fields.
  Counter32 copyWith({int? value, bool? hasWrapped}) {
    return Counter32._(
      value: value ?? this.value,
      hasWrapped: hasWrapped ?? this.hasWrapped,
    );
  }
}

/// A zero-based 32-bit counter that starts at 0 and monotonically increases.
@immutable
@realizes(r'UML::ZeroBasedCounter32.value')
class ZeroBasedCounter32 extends Counter32 {
  ZeroBasedCounter32() : super(0);

  const ZeroBasedCounter32._({required int value, required bool hasWrapped})
      : super._(value: value, hasWrapped: hasWrapped);

  @override
  ZeroBasedCounter32 increment() {
    if (value == Counter32.maxValue) {
      return const ZeroBasedCounter32._(value: 0, hasWrapped: true);
    }
    return ZeroBasedCounter32._(value: value + 1, hasWrapped: false);
  }

  @override
  ZeroBasedCounter32 reset() {
    return const ZeroBasedCounter32._(value: 0, hasWrapped: false);
  }

  @override
  ZeroBasedCounter32 copyWith({int? value, bool? hasWrapped}) {
    return ZeroBasedCounter32._(
      value: value ?? this.value,
      hasWrapped: hasWrapped ?? this.hasWrapped,
    );
  }
}

/// A non-negative 64-bit monotonic counter that wraps at 2^64-1.
@immutable
@realizes(r'UML::Counter64.value')
class Counter64 {
  static final BigInt maxValue = BigInt.parse('18446744073709551615');

  final BigInt value;
  final bool hasWrapped;

  Counter64(BigInt initialValue)
      : value = _validate(initialValue),
        hasWrapped = false;

  const Counter64._({required this.value, required this.hasWrapped});

  static BigInt _validate(BigInt v) {
    if (v.isNegative) {
      throw const CounterConfigError('Counter64 value must not be negative');
    }
    if (v > maxValue) {
      throw CounterOverflowError(maxValue: maxValue);
    }
    return v;
  }

  /// Increments the counter by one, wrapping to 0 at [maxValue].
  Counter64 increment() {
    if (value == maxValue) {
      return Counter64._(value: BigInt.zero, hasWrapped: true);
    }
    return Counter64._(value: value + BigInt.one, hasWrapped: false);
  }

  /// Resets the discontinuity flag.
  Counter64 reset() {
    return Counter64._(value: value, hasWrapped: false);
  }

  /// Creates a copy of this [Counter64] with optionally modified fields.
  Counter64 copyWith({BigInt? value, bool? hasWrapped}) {
    return Counter64._(
      value: value ?? this.value,
      hasWrapped: hasWrapped ?? this.hasWrapped,
    );
  }
}

/// A zero-based 64-bit counter that starts at 0 and monotonically increases.
@immutable
@realizes(r'UML::ZeroBasedCounter64.value')
class ZeroBasedCounter64 extends Counter64 {
  ZeroBasedCounter64() : super(BigInt.zero);

  const ZeroBasedCounter64._({required BigInt value, required bool hasWrapped})
      : super._(value: value, hasWrapped: hasWrapped);

  @override
  ZeroBasedCounter64 increment() {
    if (value == Counter64.maxValue) {
      return ZeroBasedCounter64._(value: BigInt.zero, hasWrapped: true);
    }
    return ZeroBasedCounter64._(value: value + BigInt.one, hasWrapped: false);
  }

  @override
  ZeroBasedCounter64 reset() {
    return ZeroBasedCounter64._(value: BigInt.zero, hasWrapped: false);
  }

  @override
  ZeroBasedCounter64 copyWith({BigInt? value, bool? hasWrapped}) {
    return ZeroBasedCounter64._(
      value: value ?? this.value,
      hasWrapped: hasWrapped ?? this.hasWrapped,
    );
  }
}

/// A non-negative 32-bit gauge that clamps at min (0) and max (2^32-1).
@immutable
@realizes(r'UML::Gauge32.value')
class Gauge32 {
  static const int maxValue = 4294967295;

  final int value;

  const Gauge32._({required this.value});

  Gauge32(int initialValue) : value = _clamp(initialValue);

  static int _clamp(int v) {
    if (v < 0) return 0;
    if (v > maxValue) return maxValue;
    return v;
  }

  /// Returns `true` when the gauge is at either min (0) or max.
  bool get isSaturated => value == 0 || value == maxValue;

  /// Sets the gauge to [newValue], clamping at boundaries.
  Gauge32 set(int newValue) {
    return Gauge32._(value: _clamp(newValue));
  }

  /// Creates a copy of this [Gauge32] with an optionally modified value.
  Gauge32 copyWith({int? value}) {
    return Gauge32._(value: value ?? this.value);
  }
}

/// A non-negative 64-bit gauge that clamps at min (0) and max (2^64-1).
@immutable
@realizes(r'UML::Gauge64.value')
class Gauge64 {
  static final BigInt maxValue = BigInt.parse('18446744073709551615');
  static final BigInt _zero = BigInt.zero;

  final BigInt value;

  const Gauge64._({required this.value});

  Gauge64(BigInt initialValue) : value = _clamp(initialValue);

  static BigInt _clamp(BigInt v) {
    if (v.isNegative) return _zero;
    if (v > maxValue) return maxValue;
    return v;
  }

  /// Returns `true` when the gauge is at either min (0) or max.
  bool get isSaturated => value == _zero || value == maxValue;

  /// Sets the gauge to [newValue], clamping at boundaries.
  Gauge64 set(BigInt newValue) {
    return Gauge64._(value: _clamp(newValue));
  }

  /// Creates a copy of this [Gauge64] with an optionally modified value.
  Gauge64 copyWith({BigInt? value}) {
    return Gauge64._(value: value ?? this.value);
  }
}
