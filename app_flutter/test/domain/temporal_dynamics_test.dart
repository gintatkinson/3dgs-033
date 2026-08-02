import 'package:app_flutter/domain/temporal_dynamics.dart';
import 'package:app_flutter/domain/velocity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseTime = DateTime.utc(2024, 1, 1, 12, 0, 0);

  TemporalState makeState(int minuteOffset, {double lat = 0.0, double lon = 0.0, double alt = 0.0, Velocity? velocity, String entityId = 'e1'}) {
    return TemporalState(
      entityId: entityId,
      timestamp: baseTime.add(Duration(minutes: minuteOffset)),
      lat: lat,
      lon: lon,
      alt: alt,
      velocity: velocity ?? const Velocity(),
    );
  }

  group('TemporalState', () {
    test('should construct with all required fields set', () {
      final ts = makeState(0, lat: 15.0, lon: 30.0, alt: 100.0);
      expect(ts.entityId, equals('e1'));
      expect(ts.lat, equals(15.0));
      expect(ts.lon, equals(30.0));
      expect(ts.alt, equals(100.0));
      expect(ts.status, equals('unknown'));
    });

    test('should be equal when all fields match', () {
      final a = makeState(0);
      final b = makeState(0);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should be unequal when timestamp differs', () {
      final a = makeState(0);
      final b = makeState(1);
      expect(a, isNot(equals(b)));
    });

    test('should create copy with modified fields using copyWith', () {
      final original = makeState(0, lat: 1.0, lon: 2.0);
      final copied = original.copyWith(lat: 10.0, status: 'active');
      expect(copied.lat, equals(10.0));
      expect(copied.lon, equals(2.0));
      expect(copied.status, equals('active'));
    });
  });

  group('MotionTrajectory', () {
    test('should construct trajectory sorted by timestamp', () {
      final s3 = makeState(3);
      final s1 = makeState(1);
      final s2 = makeState(2);
      final t = MotionTrajectory.fromStates([s3, s1, s2]);
      expect(t.states.map((s) => s.timestamp).toList(),
          equals([s1.timestamp, s2.timestamp, s3.timestamp]));
    });

    test('should add state and maintain sorted order', () {
      final t = MotionTrajectory.fromStates([makeState(10), makeState(20)]);
      final updated = t.addState(makeState(15));
      expect(updated.length, equals(3));
      expect(
          updated.states[1].timestamp, equals(baseTime.add(Duration(minutes: 15))));
    });

    test('should extrapolate forward using nearest velocity', () {
      final t = MotionTrajectory.fromStates([
        makeState(0, lat: 0.0, lon: 0.0,
            velocity: Velocity(vNorth: 1.0, vEast: 0.0)),
      ]);
      final target = baseTime.add(const Duration(minutes: 1));
      final result = t.extrapolate(target);
      expect(result.status, equals('extrapolated'));
      expect(result.timestamp, equals(target));
      expect(result.lat, greaterThan(0.0));
    });

    test('should extrapolate backward using nearest velocity', () {
      final t = MotionTrajectory.fromStates([
        makeState(10, lat: 0.0, lon: 0.0,
            velocity: Velocity(vNorth: 1.0, vEast: 0.0)),
      ]);
      final target = baseTime.add(const Duration(minutes: 5));
      final result = t.extrapolate(target);
      expect(result.status, equals('extrapolated'));
      expect(result.lat, lessThan(0.0));
    });

    test('should interpolate between two bracketing states', () {
      final t = MotionTrajectory.fromStates([
        makeState(0, lat: 0.0, lon: 0.0, alt: 0.0, velocity: Velocity(vUp: 0.0)),
        makeState(10, lat: 10.0, lon: 10.0, alt: 10.0, velocity: Velocity(vUp: 10.0)),
      ]);
      final target = baseTime.add(const Duration(minutes: 5));
      final result = t.interpolate(target);
      expect(result.status, equals('interpolated'));
      expect(result.lat, closeTo(5.0, 1e-6));
      expect(result.lon, closeTo(5.0, 1e-6));
      expect(result.alt, closeTo(5.0, 1e-6));
      expect(result.velocity.vUp, closeTo(5.0, 1e-6));
    });

    test('should return exact state when interpolating at timestamp of a state', () {
      final t = MotionTrajectory.fromStates([
        makeState(0, lat: 5.0, lon: 10.0, alt: 100.0),
        makeState(10, lat: 15.0, lon: 20.0, alt: 200.0),
      ]);
      final result = t.interpolate(baseTime);
      expect(result.lat, equals(5.0));
      expect(result.lon, equals(10.0));
      expect(result.alt, equals(100.0));
    });

    test('should retrieve velocity at given time', () {
      final t = MotionTrajectory.fromStates([
        makeState(0, velocity: Velocity(vNorth: 1.0, vEast: 0.0)),
        makeState(10, velocity: Velocity(vNorth: 5.0, vEast: 3.0)),
      ]);
      final v = t.velocityAt(baseTime.add(const Duration(minutes: 5)));
      expect(v.vNorth, closeTo(3.0, 1e-6));
      expect(v.vEast, closeTo(1.5, 1e-6));
    });

    test('should throw EmptyTrajectoryError when interpolating on empty trajectory', () {
      final t = const MotionTrajectory.empty();
      expect(
        () => t.interpolate(baseTime),
        throwsA(isA<EmptyTrajectoryError>()),
      );
    });
  });

  group('PlaybackController', () {
    MotionTrajectory makeTraj() {
      return MotionTrajectory.fromStates([
        makeState(0, lat: 0.0, lon: 0.0,
            velocity: Velocity(vNorth: 1.0)),
        makeState(10, lat: 5.0, lon: 5.0,
            velocity: Velocity(vNorth: 1.0)),
      ]);
    }

    test('should start in stopped state when trajectory is assigned', () {
      final ctrl = PlaybackController().withTrajectory(makeTraj());
      expect(ctrl.state, equals(PlaybackState.stopped));
      expect(ctrl.scrubPosition, equals(baseTime));
    });

    test('should transition through stopped → playing → paused → stopped', () {
      final ctrl = PlaybackController()
          .withTrajectory(makeTraj())
          .play();
      expect(ctrl.state, equals(PlaybackState.playing));

      final paused = ctrl.pause();
      expect(paused.state, equals(PlaybackState.paused));

      final resumed = paused.play();
      expect(resumed.state, equals(PlaybackState.playing));

      final stopped = resumed.stop();
      expect(stopped.state, equals(PlaybackState.stopped));
      expect(stopped.scrubPosition, equals(baseTime));
    });

    test('should advance scrubber position with rate multiplier applied', () {
      final ctrl = PlaybackController()
          .withTrajectory(makeTraj())
          .play()
          .setRate(2.0);
      final advanced = ctrl.advance(const Duration(minutes: 1));
      expect(
        advanced.scrubPosition
            .difference(baseTime)
            .inMinutes,
        equals(2),
      );
    });

    test('should advance at 1x rate by default', () {
      final ctrl = PlaybackController()
          .withTrajectory(makeTraj())
          .play();
      final advanced = ctrl.advance(const Duration(minutes: 3));
      expect(
        advanced.scrubPosition
            .difference(baseTime)
            .inMinutes,
        equals(3),
      );
    });

    test('should clamp scrubber position to trajectory bounds', () {
      final ctrl = PlaybackController()
          .withTrajectory(makeTraj())
          .play();
      final advanced = ctrl.advance(const Duration(minutes: 60));
      final lastTs = baseTime.add(const Duration(minutes: 10));
      expect(advanced.scrubPosition, equals(lastTs));
      expect(advanced.state, equals(PlaybackState.paused));
    });

    test('should return interpolated state at current scrubber position', () {
      final ctrl = PlaybackController()
          .withTrajectory(makeTraj())
          .play()
          .advance(const Duration(minutes: 5));
      final state = ctrl.currentState();
      expect(state.status, equals('interpolated'));
      expect(state.lat, closeTo(2.5, 1e-6));
      expect(state.lon, closeTo(2.5, 1e-6));
    });

    test('should seek to specific timestamp', () {
      final ctrl = PlaybackController()
          .withTrajectory(makeTraj());
      final seeked = ctrl.seekTo(baseTime.add(const Duration(minutes: 7)));
      expect(
        seeked.scrubPosition
            .difference(baseTime)
            .inMinutes,
        equals(7),
      );
    });

    test('should reject invalid rate multiplier', () {
      final ctrl = PlaybackController()
          .withTrajectory(makeTraj());
      expect(
        () => ctrl.setRate(3.0),
        throwsA(isA<InvalidPlaybackStateError>()),
      );
    });

    test('should throw TrajectoryNotSetError when playing without trajectory', () {
      final ctrl = PlaybackController();
      expect(
        () => ctrl.play(),
        throwsA(isA<TrajectoryNotSetError>()),
      );
    });
  });

  group('Error types', () {
    test('EmptyTrajectoryError toString should contain descriptive text', () {
      final e = const EmptyTrajectoryError();
      expect(e.toString(), contains('EmptyTrajectoryError'));
    });

    test('TrajectoryNotSetError toString should contain descriptive text', () {
      final e = const TrajectoryNotSetError();
      expect(e.toString(), contains('TrajectoryNotSetError'));
    });

    test('InvalidPlaybackStateError toString should contain message', () {
      final e = InvalidPlaybackStateError('bad state');
      expect(e.toString(), contains('bad state'));
    });
  });
}
