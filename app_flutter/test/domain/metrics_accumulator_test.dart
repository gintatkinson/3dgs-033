import 'package:app_flutter/domain/metrics_accumulator.dart';
import 'package:app_flutter/domain/telemetry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumericMetricsAccumulator', () {
    test('push adds samples and groups by metric name', () {
      var acc = const NumericMetricsAccumulator();
      final t0 = DateTime(2025, 1, 1, 12, 0, 0);

      acc = acc.push('cpu.usage', 42.0, t0);
      acc = acc.push('cpu.usage', 50.0, t0.add(const Duration(seconds: 1)));
      acc = acc.push('mem.usage', 70.0, t0);

      expect(acc == const NumericMetricsAccumulator(), isFalse);
    });

    test('rateOfChange computes first-order difference over window', () {
      var acc = const NumericMetricsAccumulator();
      final t0 = DateTime(2025, 1, 1, 12, 0, 0);

      acc = acc.push('cpu', 10.0, t0);
      acc = acc.push('cpu', 20.0, t0.add(const Duration(seconds: 2)));
      acc = acc.push('cpu', 40.0, t0.add(const Duration(seconds: 4)));

      final rate = acc.rateOfChange(
        'cpu',
        const Duration(seconds: 10),
      );

      expect(rate, closeTo(7.5, 0.01));
    });

    test('rateOfChange returns zero when fewer than two samples in window', () {
      var acc = const NumericMetricsAccumulator();
      final t0 = DateTime(2025, 1, 1, 12, 0, 0);

      acc = acc.push('cpu', 10.0, t0);

      final rate = acc.rateOfChange(
        'cpu',
        const Duration(seconds: 10),
      );

      expect(rate, 0.0);
    });

    test('rollingAverage computes mean of last N samples', () {
      var acc = const NumericMetricsAccumulator();
      final t0 = DateTime(2025, 1, 1, 12, 0, 0);

      acc = acc.push('cpu', 10.0, t0);
      acc = acc.push('cpu', 20.0, t0.add(const Duration(seconds: 1)));
      acc = acc.push('cpu', 30.0, t0.add(const Duration(seconds: 2)));

      final avg = acc.rollingAverage('cpu', 2);

      expect(avg, 25.0);
    });

    test('isDegraded returns true when last value exceeds threshold', () {
      var acc = const NumericMetricsAccumulator();
      final t0 = DateTime(2025, 1, 1, 12, 0, 0);

      acc = acc.push('cpu', 80.0, t0);
      acc = acc.push('cpu', 95.0, t0.add(const Duration(seconds: 1)));

      expect(acc.isDegraded('cpu', 90.0), isTrue);
      expect(acc.isDegraded('cpu', 100.0), isFalse);
    });

    test('throws MetricNotFoundError for unknown metric', () {
      final acc = NumericMetricsAccumulator();

      expect(
        () => acc.rateOfChange('unknown', const Duration(seconds: 1)),
        throwsA(isA<MetricNotFoundError>()),
      );
      expect(
        () => acc.rollingAverage('unknown', 3),
        throwsA(isA<MetricNotFoundError>()),
      );
    });

    test('throws InvalidMetricNameError for blank metric name', () {
      final acc = NumericMetricsAccumulator();

      expect(
        () => acc.push('  ', 1.0, DateTime.now()),
        throwsA(isA<InvalidMetricNameError>()),
      );
      expect(
        () => acc.rateOfChange('', const Duration(seconds: 1)),
        throwsA(isA<InvalidMetricNameError>()),
      );
    });
  });

  group('FrameDropAccumulator', () {
    test('recordFrame counts frames exceeding drop threshold', () {
      var acc = const FrameDropAccumulator();

      acc = acc.recordFrame(const Duration(milliseconds: 10));
      acc = acc.recordFrame(const Duration(milliseconds: 20));
      acc = acc.recordFrame(const Duration(milliseconds: 8));

      expect(acc.dropCount(), 1);
    });

    test('dropRate returns non-negative value for recorded frames', () {
      var acc = const FrameDropAccumulator();

      acc = acc.recordFrame(const Duration(milliseconds: 10));
      acc = acc.recordFrame(const Duration(milliseconds: 20));
      acc = acc.recordFrame(const Duration(milliseconds: 10));
      acc = acc.recordFrame(const Duration(milliseconds: 8));

      final rate = acc.dropRate();
      expect(rate, greaterThanOrEqualTo(0.0));
    });

    test('isHealthy returns true when all frames are under threshold', () {
      var acc = const FrameDropAccumulator();

      expect(acc.isHealthy(), isTrue);

      for (int i = 0; i < 100; i++) {
        acc = acc.recordFrame(const Duration(milliseconds: 10));
      }

      expect(acc.isHealthy(), isTrue);
    });

    test('isHealthy returns false when drop rate exceeds 1%', () {
      var acc = const FrameDropAccumulator();

      for (int i = 0; i < 98; i++) {
        acc = acc.recordFrame(const Duration(milliseconds: 10));
      }
      acc = acc.recordFrame(const Duration(milliseconds: 30));
      acc = acc.recordFrame(const Duration(milliseconds: 30));

      expect(acc.dropCount(), 2);
      expect(acc.isHealthy(), isFalse);
    });

    test('constructs with custom drop threshold', () {
      var acc = const FrameDropAccumulator(
        dropThreshold: Duration(milliseconds: 30),
      );

      acc = acc.recordFrame(const Duration(milliseconds: 20));
      acc = acc.recordFrame(const Duration(milliseconds: 40));

      expect(acc.dropCount(), 1);
    });

    test('empty accumulator dropRate returns 0.0', () {
      const acc = FrameDropAccumulator();

      expect(acc.dropRate(), 0.0);
    });

    test('isDegraded returns false for non-existent metric', () {
      const acc = NumericMetricsAccumulator();

      expect(acc.isDegraded('missing', 50.0), isFalse);
    });
  });
}
