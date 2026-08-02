import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:app_flutter/domain/metrics_accumulator.dart';

enum FrameStatus { healthy, degraded, poor }

class FrameHealthNotifier extends ChangeNotifier {
  FrameDropAccumulator _accumulator = const FrameDropAccumulator();
  double _dropPercentage = 0.0;
  Timer? _timer;

  FrameDropAccumulator get accumulator => _accumulator;
  double get dropPercentage => _dropPercentage;

  FrameStatus get status {
    if (_dropPercentage < 1.0) return FrameStatus.healthy;
    if (_dropPercentage <= 5.0) return FrameStatus.degraded;
    return FrameStatus.poor;
  }

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _dropPercentage = _accumulator.dropPercentage();
      notifyListeners();
    });
  }

  void recordFrameTime(Duration frameTime) {
    _accumulator = _accumulator.recordFrame(frameTime);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
