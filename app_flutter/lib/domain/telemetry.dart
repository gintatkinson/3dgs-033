import 'dart:math' as math;

import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Error thrown when statistics are requested on an empty sample set.
@immutable
class EmptySampleSetError implements Exception {
  const EmptySampleSetError();

  @override
  String toString() => 'EmptySampleSetError: no samples available to compute statistics';
}

/// Error thrown when a metric name is invalid (empty or whitespace-only).
@immutable
class InvalidMetricNameError implements Exception {
  final String metricName;

  const InvalidMetricNameError({required this.metricName});

  @override
  String toString() => 'InvalidMetricNameError: metric name is empty or invalid';
}

/// A single telemetry data point captured at a point in time.
///
/// Each [TelemetrySample] records a [metricName], a numeric [value],
/// a [timestamp] (in microseconds since epoch), and optional string [tags]
/// for dimensional slicing.
@immutable
@realizes(r'UML::TelemetrySample.metricName')
@realizes(r'UML::TelemetrySample.value')
@realizes(r'UML::TelemetrySample.timestamp')
class TelemetrySample {
  final int timestampMicros;
  final String metricName;
  final double value;
  final Map<String, String> tags;

  const TelemetrySample({
    required this.timestampMicros,
    required this.metricName,
    required this.value,
    this.tags = const {},
  });

  TelemetrySample copyWith({
    int? timestampMicros,
    String? metricName,
    double? value,
    Map<String, String>? tags,
  }) {
    return TelemetrySample(
      timestampMicros: timestampMicros ?? this.timestampMicros,
      metricName: metricName ?? this.metricName,
      value: value ?? this.value,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TelemetrySample &&
        other.timestampMicros == timestampMicros &&
        other.metricName == metricName &&
        other.value == value &&
        _mapsEqual(other.tags, tags);
  }

  @override
  int get hashCode => Object.hash(timestampMicros, metricName, value, Object.hashAll(tags.entries.map((e) => Object.hash(e.key, e.value))));

  @override
  String toString() =>
      'TelemetrySample(timestampMicros: $timestampMicros, metricName: $metricName, value: $value, tags: $tags)';
}

/// Immutable result of computing statistics over a collection of samples.
@immutable
@realizes(r'UML::TelemetryStatistics.min')
@realizes(r'UML::TelemetryStatistics.max')
@realizes(r'UML::TelemetryStatistics.avg')
class TelemetryStatistics {
  final double min;
  final double max;
  final double avg;
  final double p50;
  final double p90;
  final double p99;
  final int sampleCount;

  const TelemetryStatistics({
    required this.min,
    required this.max,
    required this.avg,
    required this.p50,
    required this.p90,
    required this.p99,
    required this.sampleCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TelemetryStatistics &&
        other.min == min &&
        other.max == max &&
        other.avg == avg &&
        other.p50 == p50 &&
        other.p90 == p90 &&
        other.p99 == p99 &&
        other.sampleCount == sampleCount;
  }

  @override
  int get hashCode => Object.hash(min, max, avg, p50, p90, p99, sampleCount);

  @override
  String toString() =>
      'TelemetryStatistics(min: $min, max: $max, avg: $avg, p50: $p50, p90: $p90, p99: $p99, n: $sampleCount)';
}

/// Collects [TelemetrySample] instances and computes aggregate statistics.
///
/// This class is pure Dart and has no dependency on Flutter, making it suitable
/// for execution in a background [Isolate]. Every mutating operation returns a
/// new immutable instance.
@immutable
@realizes(r'UML::TelemetryAccumulator.samples')
class TelemetryAccumulator {
  final List<TelemetrySample> _samples;

  const TelemetryAccumulator._({required List<TelemetrySample> samples})
      : _samples = samples;

  /// Creates an empty accumulator.
  const TelemetryAccumulator() : _samples = const [];

  List<TelemetrySample> get samples => List.unmodifiable(_samples);

  int get count => _samples.length;

  bool get isEmpty => _samples.isEmpty;

  /// Returns a new [TelemetryAccumulator] with [sample] appended.
  TelemetryAccumulator add(TelemetrySample sample) {
    return TelemetryAccumulator._(samples: [..._samples, sample]);
  }

  /// Returns a new [TelemetryAccumulator] with all given [newSamples] appended.
  TelemetryAccumulator addAll(Iterable<TelemetrySample> newSamples) {
    return TelemetryAccumulator._(samples: [..._samples, ...newSamples]);
  }

  /// Clears all accumulated samples.
  TelemetryAccumulator clear() {
    if (_samples.isEmpty) return this;
    return const TelemetryAccumulator._(samples: []);
  }

  /// Computes [TelemetryStatistics] over all currently held samples.
  ///
  /// Throws [EmptySampleSetError] if no samples have been collected.
  TelemetryStatistics computeStatistics() {
    if (_samples.isEmpty) {
      throw const EmptySampleSetError();
    }

    final values = List<double>.from(_samples.map((s) => s.value));
    values.sort();

    final n = values.length;
    final min = values.first;
    final max = values.last;
    final sum = values.fold<double>(0.0, (a, b) => a + b);
    final avg = sum / n;

    double percentile(List<double> sorted, double p) {
      if (sorted.isEmpty) return 0.0;
      final index = p / 100.0 * (sorted.length - 1);
      final lower = index.floor();
      final upper = index.ceil();
      if (lower == upper) return sorted[lower];
      final fraction = index - lower;
      return sorted[lower] * (1.0 - fraction) + sorted[upper] * fraction;
    }

    return TelemetryStatistics(
      min: min,
      max: max,
      avg: avg,
      p50: percentile(values, 50),
      p90: percentile(values, 90),
      p99: percentile(values, 99),
      sampleCount: n,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TelemetryAccumulator &&
        other.count == count &&
        _listsEqual(other._samples, _samples);
  }

  @override
  int get hashCode => Object.hashAll(_samples);

  @override
  String toString() => 'TelemetryAccumulator(samples: $count)';
}

/// Timing breakdown for a single rendered frame.
///
/// All times are in milliseconds. [buildTimeMs] is the widget/layout phase,
/// [rasterTimeMs] is the GPU rasterization phase, and [totalTimeMs] is the
/// end-to-end wall-clock duration.
@immutable
@realizes(r'UML::FrameMetrics.buildTime')
@realizes(r'UML::FrameMetrics.rasterTime')
@realizes(r'UML::FrameMetrics.totalTime')
class FrameMetrics {
  final double buildTimeMs;
  final double rasterTimeMs;
  final double totalTimeMs;

  const FrameMetrics({
    required this.buildTimeMs,
    required this.rasterTimeMs,
    required this.totalTimeMs,
  });

  /// Creates [FrameMetrics] where [totalTimeMs] is derived from build + raster.
  FrameMetrics.fromComponents({
    required double buildTimeMs,
    required double rasterTimeMs,
  })  : buildTimeMs = buildTimeMs,
        rasterTimeMs = rasterTimeMs,
        totalTimeMs = buildTimeMs + rasterTimeMs;

  /// Returns the effective frame rate in Hz (frames per second).
  double get frameRateHz {
    if (totalTimeMs <= 0.0) return double.infinity;
    return 1000.0 / totalTimeMs;
  }

  FrameMetrics copyWith({
    double? buildTimeMs,
    double? rasterTimeMs,
    double? totalTimeMs,
  }) {
    return FrameMetrics(
      buildTimeMs: buildTimeMs ?? this.buildTimeMs,
      rasterTimeMs: rasterTimeMs ?? this.rasterTimeMs,
      totalTimeMs: totalTimeMs ?? this.totalTimeMs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FrameMetrics &&
        other.buildTimeMs == buildTimeMs &&
        other.rasterTimeMs == rasterTimeMs &&
        other.totalTimeMs == totalTimeMs;
  }

  @override
  int get hashCode => Object.hash(buildTimeMs, rasterTimeMs, totalTimeMs);

  @override
  String toString() =>
      'FrameMetrics(build: ${buildTimeMs.toStringAsFixed(2)}ms, raster: ${rasterTimeMs.toStringAsFixed(2)}ms, total: ${totalTimeMs.toStringAsFixed(2)}ms)';
}

/// A histogram that buckets frame times into defined ranges and counts frames
/// that exceed a drop threshold.
///
/// Buckets are defined by sorted [thresholds]; the histogram has N+1 buckets
/// where N is the number of thresholds. A frame is considered "dropped" if its
/// total time exceeds [dropThresholdMs].
@immutable
@realizes(r'UML::FrameDropHistogram.buckets')
@realizes(r'UML::FrameDropHistogram.dropThreshold')
class FrameDropHistogram {
  final List<double> thresholds;
  final List<int> buckets;
  final int totalFrames;
  final int droppedFrames;
  final double dropThresholdMs;

  /// Creates an empty histogram with [thresholds] and [dropThresholdMs].
  const FrameDropHistogram({
    this.thresholds = const [16.0, 32.0, 64.0],
    this.dropThresholdMs = 32.0,
  })  : buckets = const [],
        totalFrames = 0,
        droppedFrames = 0;

  const FrameDropHistogram._({
    required this.thresholds,
    required this.buckets,
    required this.totalFrames,
    required this.droppedFrames,
    required this.dropThresholdMs,
  });

  int get bucketCount => thresholds.length + 1;

  /// Returns a new [FrameDropHistogram] with [frameTimeMs] recorded.
  FrameDropHistogram record(double frameTimeMs) {
    final newTotal = totalFrames + 1;
    final newDropped = frameTimeMs >= dropThresholdMs ? droppedFrames + 1 : droppedFrames;

    final newBuckets = List<int>.from(buckets);
    while (newBuckets.length < bucketCount) {
      newBuckets.add(0);
    }
    var bucketIndex = thresholds.length;
    for (int i = 0; i < thresholds.length; i++) {
      if (frameTimeMs < thresholds[i]) {
        bucketIndex = i;
        break;
      }
    }
    newBuckets[bucketIndex]++;

    return FrameDropHistogram._(
      thresholds: thresholds,
      buckets: newBuckets,
      totalFrames: newTotal,
      droppedFrames: newDropped,
      dropThresholdMs: dropThresholdMs,
    );
  }

  /// Returns a new [FrameDropHistogram] with all given [frameTimesMs] recorded.
  FrameDropHistogram recordAll(Iterable<double> frameTimesMs) {
    return frameTimesMs.fold(this, (h, t) => h.record(t));
  }

  /// The drop rate as a fraction of total frames (0.0 – 1.0).
  double get dropRate {
    if (totalFrames == 0) return 0.0;
    return droppedFrames / totalFrames;
  }

  /// The drop rate as a percentage (0.0 – 100.0).
  double get dropPercentage {
    if (totalFrames == 0) return 0.0;
    return 100.0 * droppedFrames / totalFrames;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FrameDropHistogram) return false;
    return other.dropThresholdMs == dropThresholdMs &&
        other.totalFrames == totalFrames &&
        other.droppedFrames == droppedFrames &&
        _listsEqual(other.thresholds, thresholds) &&
        _listsEqual(other.buckets, buckets);
  }

  @override
  int get hashCode => Object.hash(
        dropThresholdMs,
        totalFrames,
        droppedFrames,
        Object.hashAll(thresholds),
        Object.hashAll(buckets),
      );

  @override
  String toString() =>
      'FrameDropHistogram(frames: $totalFrames, dropped: $droppedFrames, dropRate: ${dropPercentage.toStringAsFixed(1)}%, thresholds: $thresholds, buckets: $buckets)';
}

bool _listsEqual<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _mapsEqual<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) return false;
  }
  return true;
}
