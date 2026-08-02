import 'package:app_flutter/domain/telemetry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TelemetrySample', () {
    test('should create sample with timestamp, metric name, value, and tags', () {
      final sample = TelemetrySample(
        timestampMicros: 1234567890,
        metricName: 'frame.total_time_ms',
        value: 14.5,
        tags: {'view': 'home'},
      );

      expect(sample.timestampMicros, 1234567890);
      expect(sample.metricName, 'frame.total_time_ms');
      expect(sample.value, 14.5);
      expect(sample.tags, {'view': 'home'});
    });

    test('should create copy with modified fields', () {
      final original = TelemetrySample(
        timestampMicros: 100,
        metricName: 'cpu.usage',
        value: 42.0,
        tags: {'host': 'A'},
      );

      final modified = original.copyWith(value: 55.0, tags: {'host': 'B'});

      expect(modified.timestampMicros, 100);
      expect(modified.metricName, 'cpu.usage');
      expect(modified.value, 55.0);
      expect(modified.tags, {'host': 'B'});
    });

    test('should be equal when all fields are identical', () {
      final a = TelemetrySample(
        timestampMicros: 1,
        metricName: 'm',
        value: 1.0,
        tags: {'k': 'v'},
      );
      final b = TelemetrySample(
        timestampMicros: 1,
        metricName: 'm',
        value: 1.0,
        tags: {'k': 'v'},
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('TelemetryAccumulator', () {
    test('should add samples and track count', () {
      var acc = const TelemetryAccumulator();
      expect(acc.count, 0);
      expect(acc.isEmpty, isTrue);

      acc = acc.add(TelemetrySample(
        timestampMicros: 1,
        metricName: 'm',
        value: 10.0,
      ));
      acc = acc.add(TelemetrySample(
        timestampMicros: 2,
        metricName: 'm',
        value: 20.0,
      ));

      expect(acc.count, 2);
      expect(acc.isEmpty, isFalse);
      expect(acc.samples.length, 2);
    });

    test('should compute min, max, avg from accumulated samples', () {
      final acc = TelemetryAccumulator()
          .add(TelemetrySample(timestampMicros: 1, metricName: 'm', value: 10.0))
          .add(TelemetrySample(timestampMicros: 2, metricName: 'm', value: 20.0))
          .add(TelemetrySample(timestampMicros: 3, metricName: 'm', value: 30.0));

      final stats = acc.computeStatistics();

      expect(stats.min, 10.0);
      expect(stats.max, 30.0);
      expect(stats.avg, 20.0);
      expect(stats.sampleCount, 3);
    });

    test('should compute p50, p90, p99 percentiles', () {
      final acc = const TelemetryAccumulator();
      var a = acc;
      for (final v in [5.0, 1.0, 9.0, 2.0, 8.0, 3.0, 7.0, 4.0, 6.0, 10.0]) {
        a = a.add(TelemetrySample(
          timestampMicros: 1,
          metricName: 'm',
          value: v,
        ));
      }

      // 10 values sorted: 1,2,3,4,5,6,7,8,9,10
      // p50: index 4.5 => (5 + 6) / 2 => 5.5
      // p90: index 8.1 => 9*0.9 + 10*0.1 => 9.1
      // p99: index 8.91 => 9*0.09 + 10*0.91 => 9.91
      final stats = a.computeStatistics();
      expect(stats.p50, closeTo(5.5, 1e-12));
      expect(stats.p90, closeTo(9.1, 1e-12));
      expect(stats.p99, closeTo(9.91, 1e-12));
    });

    test('should throw EmptySampleSetError when computing statistics with no samples', () {
      const acc = TelemetryAccumulator();
      expect(
        () => acc.computeStatistics(),
        throwsA(isA<EmptySampleSetError>()),
      );
    });

    test('should clear accumulated samples and return empty accumulator', () {
      final acc = TelemetryAccumulator()
          .add(TelemetrySample(timestampMicros: 1, metricName: 'm', value: 10.0))
          .clear();

      expect(acc.count, 0);
      expect(acc.isEmpty, isTrue);
    });
  });

  group('FrameMetrics', () {
    test('should create frame metrics from component times', () {
      final metrics = FrameMetrics.fromComponents(
        buildTimeMs: 5.0,
        rasterTimeMs: 10.0,
      );

      expect(metrics.buildTimeMs, 5.0);
      expect(metrics.rasterTimeMs, 10.0);
      expect(metrics.totalTimeMs, 15.0);
    });

    test('should calculate effective frame rate from total time', () {
      final metrics = FrameMetrics(
        buildTimeMs: 5.0,
        rasterTimeMs: 11.0,
        totalTimeMs: 16.67,
      );

      expect(metrics.frameRateHz, closeTo(60.0, 0.1));
    });
  });

  group('FrameDropHistogram', () {
    test('should bucket frame times into correct ranges', () {
      final histogram = FrameDropHistogram()
          .record(10.0) // bucket 0 (< 16ms)
          .record(20.0) // bucket 1 (16-32ms)
          .record(40.0) // bucket 2 (32-64ms)
          .record(80.0); // bucket 3 (>= 64ms)

      expect(histogram.totalFrames, 4);
      expect(histogram.buckets, [1, 1, 1, 1]);
    });

    test('should count dropped frames exceeding threshold', () {
      final histogram = FrameDropHistogram(dropThresholdMs: 32.0)
          .record(10.0)
          .record(20.0)
          .record(40.0)
          .record(80.0);

      expect(histogram.droppedFrames, 2);
      expect(histogram.dropRate, 0.5);
      expect(histogram.dropPercentage, 50.0);
    });

    test('should compute frame drop percentage correctly', () {
      final histogram = FrameDropHistogram()
          .recordAll([10.0, 15.0, 20.0, 50.0, 70.0]);

      expect(histogram.totalFrames, 5);
      expect(histogram.droppedFrames, 2);
      expect(histogram.dropPercentage, 40.0);
    });
  });
}
