import 'package:app_flutter/domain/annotations.dart';
import 'package:app_flutter/domain/velocity.dart';
import 'package:meta/meta.dart';

@immutable
class EmptyTrajectoryError implements Exception {
  const EmptyTrajectoryError();

  @override
  String toString() =>
      'EmptyTrajectoryError: trajectory contains no states to operate on';
}

@immutable
class TrajectoryNotSetError implements Exception {
  const TrajectoryNotSetError();

  @override
  String toString() =>
      'TrajectoryNotSetError: no trajectory has been assigned to the playback controller';
}

@immutable
class InvalidPlaybackStateError implements Exception {
  final String message;
  const InvalidPlaybackStateError(this.message);

  @override
  String toString() => 'InvalidPlaybackStateError: $message';
}

enum PlaybackState { stopped, playing, paused }

@immutable
@realizes(r'UML::TemporalState.entityId')
@realizes(r'UML::TemporalState.timestamp')
@realizes(r'UML::TemporalState.lat')
@realizes(r'UML::TemporalState.lon')
@realizes(r'UML::TemporalState.alt')
class TemporalState {
  final String entityId;
  final DateTime timestamp;
  final double lat;
  final double lon;
  final double alt;
  final Velocity velocity;
  final String status;

  const TemporalState({
    required this.entityId,
    required this.timestamp,
    required this.lat,
    required this.lon,
    required this.alt,
    this.velocity = const Velocity(),
    this.status = 'unknown',
  });

  TemporalState copyWith({
    String? entityId,
    DateTime? timestamp,
    double? lat,
    double? lon,
    double? alt,
    Velocity? velocity,
    String? status,
  }) {
    return TemporalState(
      entityId: entityId ?? this.entityId,
      timestamp: timestamp ?? this.timestamp,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      alt: alt ?? this.alt,
      velocity: velocity ?? this.velocity,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemporalState &&
        other.entityId == entityId &&
        other.timestamp == timestamp &&
        other.lat == lat &&
        other.lon == lon &&
        other.alt == alt &&
        other.velocity == velocity &&
        other.status == status;
  }

  @override
  int get hashCode =>
      Object.hash(entityId, timestamp, lat, lon, alt, velocity, status);

  @override
  String toString() =>
      'TemporalState(entityId: $entityId, timestamp: $timestamp, '
      'lat: $lat, lon: $lon, alt: $alt, velocity: $velocity, status: $status)';
}

@immutable
@realizes(r'UML::MotionTrajectory')
class MotionTrajectory {
  final List<TemporalState> _states;

  const MotionTrajectory._({required List<TemporalState> states})
      : _states = states;

  const MotionTrajectory.empty() : _states = const [];

  factory MotionTrajectory.fromStates(Iterable<TemporalState> states) {
    final sorted = List<TemporalState>.from(states)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return MotionTrajectory._(states: List.unmodifiable(sorted));
  }

  List<TemporalState> get states => List.unmodifiable(_states);

  int get length => _states.length;

  bool get isEmpty => _states.isEmpty;

  bool get isNotEmpty => _states.isNotEmpty;

  TemporalState get first {
    if (_states.isEmpty) throw const EmptyTrajectoryError();
    return _states.first;
  }

  TemporalState get last {
    if (_states.isEmpty) throw const EmptyTrajectoryError();
    return _states.last;
  }

  MotionTrajectory addState(TemporalState state) {
    final newStates = [..._states, state]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return MotionTrajectory._(states: List.unmodifiable(newStates));
  }

  TemporalState extrapolate(DateTime target) {
    if (_states.isEmpty) throw const EmptyTrajectoryError();
    if (_states.length == 1) {
      final s = _states.first;
      final dt = target
          .difference(s.timestamp)
          .inMilliseconds
          .toDouble() /
      1000.0;
      return TemporalState(
        entityId: s.entityId,
        timestamp: target,
        lat: s.lat + s.velocity.vNorth * dt / 111320.0,
        lon: s.lon +
            s.velocity.vEast *
                dt /
                (111320.0 * _cosLat(s.lat)),
        alt: s.alt + s.velocity.vUp * dt,
        velocity: s.velocity,
        status: 'extrapolated',
      );
    }

    final dtFirst =
        target.difference(_states.first.timestamp).abs();
    final dtLast =
        target.difference(_states.last.timestamp).abs();
    final nearest = dtFirst <= dtLast ? _states.first : _states.last;

    final dt = target
        .difference(nearest.timestamp)
        .inMilliseconds
        .toDouble() /
    1000.0;
    return TemporalState(
      entityId: nearest.entityId,
      timestamp: target,
      lat: nearest.lat + nearest.velocity.vNorth * dt / 111320.0,
      lon: nearest.lon +
          nearest.velocity.vEast *
              dt /
              (111320.0 * _cosLat(nearest.lat)),
      alt: nearest.alt + nearest.velocity.vUp * dt,
      velocity: nearest.velocity,
      status: 'extrapolated',
    );
  }

  TemporalState interpolate(DateTime target) {
    if (_states.isEmpty) throw const EmptyTrajectoryError();
    if (_states.length == 1) {
      final s = _states.first;
      return s.copyWith(timestamp: target, status: 'interpolated');
    }

    if (target.isBefore(_states.first.timestamp) ||
        target.isAfter(_states.last.timestamp)) {
      return extrapolate(target);
    }

    if (target == _states.first.timestamp) return _states.first;
    if (target == _states.last.timestamp) return _states.last;

    int beforeIndex = 0;
    for (int i = 0; i < _states.length - 1; i++) {
      if (target == _states[i].timestamp) return _states[i];
      if (target.isAfter(_states[i].timestamp) &&
          target.isBefore(_states[i + 1].timestamp)) {
        beforeIndex = i;
        break;
      }
    }

    final before = _states[beforeIndex];
    final after = _states[beforeIndex + 1];

    final totalMs = after.timestamp.difference(before.timestamp).inMilliseconds;
    final offsetMs = target.difference(before.timestamp).inMilliseconds;

    final ratio = totalMs > 0 ? offsetMs / totalMs : 0.0;

    return TemporalState(
      entityId: before.entityId,
      timestamp: target,
      lat: before.lat + (after.lat - before.lat) * ratio,
      lon: before.lon + (after.lon - before.lon) * ratio,
      alt: before.alt + (after.alt - before.alt) * ratio,
      velocity: Velocity(
        vNorth: before.velocity.vNorth +
            (after.velocity.vNorth - before.velocity.vNorth) * ratio,
        vEast: before.velocity.vEast +
            (after.velocity.vEast - before.velocity.vEast) * ratio,
        vUp: before.velocity.vUp +
            (after.velocity.vUp - before.velocity.vUp) * ratio,
      ),
      status: 'interpolated',
    );
  }

  Velocity velocityAt(DateTime time) {
    if (_states.isEmpty) throw const EmptyTrajectoryError();

    if (_states.length == 1) return _states.first.velocity;

    TemporalState? before;
    TemporalState? after;
    for (final s in _states) {
      if (!s.timestamp.isAfter(time)) {
        before = s;
      }
    }

    if (before == null) return _states.first.velocity;

    for (int i = _states.length - 1; i >= 0; i--) {
      if (!_states[i].timestamp.isBefore(time)) {
        after = _states[i];
      }
    }

    if (after == null) return _states.last.velocity;

    if (before == after) return before.velocity;

    final totalMs = after.timestamp.difference(before.timestamp).inMilliseconds;
    final offsetMs = time.difference(before.timestamp).inMilliseconds;
    final ratio = totalMs > 0 ? offsetMs / totalMs : 0.0;

    return Velocity(
      vNorth: before.velocity.vNorth +
          (after.velocity.vNorth - before.velocity.vNorth) * ratio,
      vEast: before.velocity.vEast +
          (after.velocity.vEast - before.velocity.vEast) * ratio,
      vUp: before.velocity.vUp +
          (after.velocity.vUp - before.velocity.vUp) * ratio,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MotionTrajectory && _listsEqual(other._states, _states);
  }

  @override
  int get hashCode => Object.hashAll(_states);

  @override
  String toString() => 'MotionTrajectory(states: ${_states.length})';
}

@immutable
@realizes(r'UML::PlaybackController')
class PlaybackController {
  final MotionTrajectory? _trajectory;
  final PlaybackState state;
  final DateTime _scrubPosition;
  final double rateMultiplier;

  static final Set<double> allowedRates = {0.5, 1.0, 2.0, 4.0};

  PlaybackController({
    MotionTrajectory? trajectory,
    this.state = PlaybackState.stopped,
    DateTime? scrubPosition,
    this.rateMultiplier = 1.0,
  })  : _trajectory = trajectory,
        _scrubPosition = scrubPosition ?? DateTime.fromMillisecondsSinceEpoch(0);

  const PlaybackController._({
    required MotionTrajectory? trajectory,
    required this.state,
    required DateTime scrubPosition,
    required this.rateMultiplier,
  })  : _trajectory = trajectory,
        _scrubPosition = scrubPosition;

  MotionTrajectory? get trajectory => _trajectory;

  DateTime get scrubPosition {
    if (_trajectory == null || _trajectory!.isEmpty) {
      return _scrubPosition;
    }
    return _scrubPosition;
  }

  PlaybackController withTrajectory(MotionTrajectory trajectory) {
    final start = trajectory.isEmpty
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : trajectory.first.timestamp;
    return PlaybackController._(
      trajectory: trajectory,
      state: PlaybackState.stopped,
      scrubPosition: start,
      rateMultiplier: rateMultiplier,
    );
  }

  PlaybackController play() {
    if (_trajectory == null) throw const TrajectoryNotSetError();
    if (_trajectory!.isEmpty) throw const EmptyTrajectoryError();
    return PlaybackController._(
      trajectory: _trajectory,
      state: PlaybackState.playing,
      scrubPosition: _scrubPosition,
      rateMultiplier: rateMultiplier,
    );
  }

  PlaybackController pause() {
    if (_trajectory == null) throw const TrajectoryNotSetError();
    return PlaybackController._(
      trajectory: _trajectory,
      state: PlaybackState.paused,
      scrubPosition: _scrubPosition,
      rateMultiplier: rateMultiplier,
    );
  }

  PlaybackController stop() {
    if (_trajectory == null) throw const TrajectoryNotSetError();
    final start = _trajectory!.isEmpty
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : _trajectory!.first.timestamp;
    return PlaybackController._(
      trajectory: _trajectory,
      state: PlaybackState.stopped,
      scrubPosition: start,
      rateMultiplier: rateMultiplier,
    );
  }

  PlaybackController advance(Duration delta) {
    if (_trajectory == null) throw const TrajectoryNotSetError();
    if (_trajectory!.isEmpty) throw const EmptyTrajectoryError();
    final scaledDelta =
        Duration(microseconds: (delta.inMicroseconds * rateMultiplier).round());
    final newPosition = _scrubPosition.add(scaledDelta);

    var clamped = newPosition;
    final firstTs = _trajectory!.first.timestamp;
    final lastTs = _trajectory!.last.timestamp;
    if (clamped.isBefore(firstTs)) clamped = firstTs;
    if (clamped.isAfter(lastTs)) clamped = lastTs;

    final newState = clamped == lastTs ? PlaybackState.paused : state;

    return PlaybackController._(
      trajectory: _trajectory,
      state: newState,
      scrubPosition: clamped,
      rateMultiplier: rateMultiplier,
    );
  }

  PlaybackController seekTo(DateTime target) {
    if (_trajectory == null) throw const TrajectoryNotSetError();
    if (_trajectory!.isEmpty) throw const EmptyTrajectoryError();
    final firstTs = _trajectory!.first.timestamp;
    final lastTs = _trajectory!.last.timestamp;
    var clamped = target;
    if (clamped.isBefore(firstTs)) clamped = firstTs;
    if (clamped.isAfter(lastTs)) clamped = lastTs;

    return PlaybackController._(
      trajectory: _trajectory,
      state: state,
      scrubPosition: clamped,
      rateMultiplier: rateMultiplier,
    );
  }

  PlaybackController setRate(double rate) {
    if (!allowedRates.contains(rate)) {
      throw InvalidPlaybackStateError(
          'Rate multiplier must be one of $allowedRates, got $rate');
    }
    return PlaybackController._(
      trajectory: _trajectory,
      state: state,
      scrubPosition: _scrubPosition,
      rateMultiplier: rate,
    );
  }

  TemporalState currentState() {
    if (_trajectory == null) throw const TrajectoryNotSetError();
    if (_trajectory!.isEmpty) throw const EmptyTrajectoryError();
    return _trajectory!.interpolate(_scrubPosition);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaybackController &&
        other._trajectory == _trajectory &&
        other.state == state &&
        other._scrubPosition == _scrubPosition &&
        other.rateMultiplier == rateMultiplier;
  }

  @override
  int get hashCode =>
      Object.hash(_trajectory, state, _scrubPosition, rateMultiplier);

  @override
  String toString() =>
      'PlaybackController(state: $state, scrubPosition: $_scrubPosition, '
      'rateMultiplier: ${rateMultiplier}x, trajectory: ${_trajectory?.length ?? 0} states)';
}

double _cosLat(double lat) {
  final r = lat * 3.141592653589793 / 180.0;
  final c = _fastCos(r);
  return c < 0.001 ? 0.001 : c;
}

double _fastCos(double x) {
  const c1 = 0.9999932946;
  const c2 = -0.4999124377;
  const c3 = 0.0414877472;
  const c4 = -0.0012712095;
  final x2 = x * x;
  return c1 + c2 * x2 + c3 * x2 * x2 + c4 * x2 * x2 * x2;
}

bool _listsEqual<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
