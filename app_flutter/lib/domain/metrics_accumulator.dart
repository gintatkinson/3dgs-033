import 'dart:math' as math;

import 'package:app_flutter/domain/annotations.dart';
import 'package:app_flutter/domain/telemetry.dart';
import 'package:meta/meta.dart';

@immutable
class _MetricSample {
  final double value;
  final DateTime timestamp;

  const _MetricSample(this.value, this.timestamp);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _MetricSample &&
        other.value == value &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(value, timestamp);
}

@immutable
class _FrameRecord {
  final Duration frameTime;
  final DateTime timestamp;

  const _FrameRecord(this.frameTime, this.timestamp);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _FrameRecord &&
        other.frameTime == frameTime &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(frameTime, timestamp);
}

/// Error thrown when a metric name has no accumulated samples.
@immutable
class MetricNotFoundError implements Exception {
  final String metricName;

  const MetricNotFoundError({required this.metricName});

  @override
  String toString() => 'MetricNotFoundError: no samples for metric "$metricName"';
}

/// Collects numeric metric samples over a sliding window and computes
/// derived indicators such as rate of change, rolling average, and
/// degradation status.
///
/// Every mutating operation returns a new immutable instance, making
/// this class suitable for use in reactive pipelines and isolates.
@immutable
@realizes(r'UML::NumericMetricsAccumulator.samples')
class NumericMetricsAccumulator {
  final Map<String, List<_MetricSample>> _samples;

  const NumericMetricsAccumulator._({
    required Map<String, List<_MetricSample>> samples,
  }) : _samples = samples;

  /// Creates an empty accumulator with no samples.
  const NumericMetricsAccumulator() : _samples = const {};

  int get _metricCount => _samples.length;

  List<_MetricSample> _samplesFor(String metricName) =>
      _samples[metricName] ?? const [];

  /// Adds a [value] for [metricName] recorded at [timestamp].
  ///
  /// Returns a new [NumericMetricsAccumulator] with the sample appended.
  /// Throws [InvalidMetricNameError] if [metricName] is empty or blank.
  NumericMetricsAccumulator push(
    String metricName,
    double value,
    DateTime timestamp,
  ) {
    if (metricName.trim().isEmpty) {
      throw InvalidMetricNameError(metricName: metricName);
    }
    final existing = List<_MetricSample>.from(_samplesFor(metricName));
    existing.add(_MetricSample(value, timestamp));
    final newMap = Map<String, List<_MetricSample>>.from(_samples);
    newMap[metricName] = existing;
    return NumericMetricsAccumulator._(samples: newMap);
  }

  /// Computes the rate of change for [metricName] over the duration
  /// of the most recent [window] of samples.
  ///
  /// The rate is `(last - first) / timeDelta` expressed in units per
  /// second. Returns `0.0` when fewer than two samples fall within the
  /// window.
  ///
  /// Throws [MetricNotFoundError] if no samples exist for [metricName].
  /// Throws [InvalidMetricNameError] if [metricName] is empty.
  double rateOfChange(String metricName, Duration window) {
    if (metricName.trim().isEmpty) {
      throw InvalidMetricNameError(metricName: metricName);
    }
    final all = _samplesFor(metricName);
    if (all.isEmpty) {
      throw MetricNotFoundError(metricName: metricName);
    }
    final cutoff = all.last.timestamp.subtract(window);
    final windowed = all.where((s) => !s.timestamp.isBefore(cutoff)).toList();
    if (windowed.length < 2) return 0.0;

    final first = windowed.first;
    final last = windowed.last;
    final deltaSeconds =
        last.timestamp.difference(first.timestamp).inMicroseconds / 1000000.0;
    if (deltaSeconds <= 0.0) return 0.0;
    return (last.value - first.value) / deltaSeconds;
  }

  /// Computes the moving average of the last [windowSize] samples
  /// for [metricName].
  ///
  /// If fewer samples exist than [windowSize], returns the average
  /// of all available samples.
  ///
  /// Throws [MetricNotFoundError] if no samples exist for [metricName].
  /// Throws [InvalidMetricNameError] if [metricName] is empty.
  double rollingAverage(String metricName, int windowSize) {
    if (metricName.trim().isEmpty) {
      throw InvalidMetricNameError(metricName: metricName);
    }
    final all = _samplesFor(metricName);
    if (all.isEmpty) {
      throw MetricNotFoundError(metricName: metricName);
    }
    final effective = math.min(windowSize, all.length);
    final windowed = all.sublist(all.length - effective);
    final sum = windowed.fold<double>(0.0, (a, s) => a + s.value);
    return sum / effective;
  }

  /// Returns `true` if the most recent value for [metricName] exceeds
  /// [threshold], indicating a degraded state.
  ///
  /// Returns `false` if no samples exist for [metricName].
  /// Throws [InvalidMetricNameError] if [metricName] is empty.
  bool isDegraded(String metricName, double threshold) {
    if (metricName.trim().isEmpty) {
      throw InvalidMetricNameError(metricName: metricName);
    }
    final all = _samplesFor(metricName);
    if (all.isEmpty) return false;
    return all.last.value > threshold;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NumericMetricsAccumulator) return false;
    if (other._metricCount != _metricCount) return false;
    for (final key in _samples.keys) {
      final a = _samples[key]!;
      final b = other._samples[key];
      if (b == null) return false;
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(
        _samples.entries.expand(
          (e) => e.value.map((s) => Object.hash(e.key, s.value, s.timestamp)),
        ),
      );

  @override
  String toString() =>
      'NumericMetricsAccumulator(metrics: $_metricCount)';
}

/// Tracks frame timings over time and computes drop-related metrics.
///
/// A frame is considered "dropped" when its duration exceeds the
/// configured [dropThreshold], which defaults to ~16.6 ms (60 FPS).
/// Every mutating operation returns a new immutable instance.
@immutable
@realizes(r'UML::FrameDropAccumulator.records')
class FrameDropAccumulator {
  /// The default drop threshold of ~16.6 ms, corresponding to 60 FPS.
  static const Duration defaultDropThreshold =
      Duration(microseconds: 16600);

  /// The default sliding window used by [dropRate] and [isHealthy].
  static const Duration defaultWindow = Duration(seconds: 5);

  final List<_FrameRecord> _records;
  final Duration dropThreshold;

  const FrameDropAccumulator._({
    required List<_FrameRecord> records,
    this.dropThreshold = defaultDropThreshold,
  }) : _records = records;

  /// Creates an empty accumulator with no recorded frames.
  const FrameDropAccumulator({
    this.dropThreshold = defaultDropThreshold,
  }) : _records = const [];

  int get _frameCount => _records.length;

  /// Records [frameTime] and returns a new [FrameDropAccumulator].
  ///
  /// The current wall-clock time is stored alongside the frame duration.
  FrameDropAccumulator recordFrame(Duration frameTime) {
    final newRecords = List<_FrameRecord>.from(_records)
      ..add(_FrameRecord(frameTime, DateTime.now()));
    return FrameDropAccumulator._(
      records: newRecords,
      dropThreshold: dropThreshold,
    );
  }

  /// Returns the total number of frames whose duration exceeds
  /// [dropThreshold].
  int dropCount() {
    return _records.where((r) => r.frameTime > dropThreshold).length;
  }

  /// Returns the number of drops per second within the sliding
  /// [defaultWindow].
  ///
  /// Uses the most recent frame timestamp as the reference point.
  /// Returns `0.0` when fewer than two frames are available in the
  /// window.
  double dropRate() {
    if (_records.isEmpty) return 0.0;
    final latest = _records.last.timestamp;
    final cutoff = latest.subtract(defaultWindow);
    final recent = _records.where((r) => !r.timestamp.isBefore(cutoff)).toList();
    if (recent.length < 2) return 0.0;
    final drops = recent.where((r) => r.frameTime > dropThreshold).length;
    final span =
        recent.last.timestamp.difference(recent.first.timestamp).inMicroseconds /
            1000000.0;
    if (span <= 0.0) return 0.0;
    return drops / span;
  }

  /// Returns the percentage of dropped frames within the sliding
  /// [defaultWindow] of the most recent frame.
  ///
  /// Returns `0.0` when the accumulator is empty or the window
  /// contains no frames.
  double dropPercentage() {
    if (_records.isEmpty) return 0.0;
    final latest = _records.last.timestamp;
    final cutoff = latest.subtract(defaultWindow);
    final recent = _records.where((r) => !r.timestamp.isBefore(cutoff)).toList();
    if (recent.isEmpty) return 0.0;
    final drops = recent.where((r) => r.frameTime > dropThreshold).length;
    return 100.0 * drops / recent.length;
  }

  /// Returns `true` when fewer than 1% of recent frames are dropped.
  ///
  /// Frames are considered "recent" when they fall within
  /// [defaultWindow] of the most recent frame. Returns `true` for
  /// an empty accumulator.
  bool isHealthy() {
    return dropPercentage() < 1.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FrameDropAccumulator) return false;
    if (other.dropThreshold != dropThreshold) return false;
    if (other._frameCount != _frameCount) return false;
    for (int i = 0; i < _frameCount; i++) {
      if (_records[i] != other._records[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        dropThreshold,
        Object.hashAll(_records),
      );

  @override
  String toString() =>
      'FrameDropAccumulator(frames: $_frameCount, drops: ${dropCount()})';
}
