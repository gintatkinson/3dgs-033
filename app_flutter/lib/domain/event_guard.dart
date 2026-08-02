import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

@immutable
class _StreamRecord<T> {
  final String direction;
  final T message;
  final DateTime timestamp;

  const _StreamRecord(this.direction, this.message, this.timestamp);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _StreamRecord<T> &&
        other.direction == direction &&
        other.message == message &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(direction, message, timestamp);
}

/// Prevents re-entrant events by tracking recently processed event
/// identifiers and their processing timestamps.
///
/// Every mutating operation returns a new immutable instance.
@immutable
@realizes(r'UML::EventEchoGuard.guards')
class EventEchoGuard {
  final Map<String, DateTime> _guards;

  const EventEchoGuard._({required Map<String, DateTime> guards})
      : _guards = guards;

  /// Creates an empty guard with no active event tracking.
  const EventEchoGuard() : _guards = const {};

  /// Returns `true` if [eventId] was recently processed and is still
  /// being guarded against re-entry.
  bool isGuarded(String eventId) {
    return _guards.containsKey(eventId);
  }

  /// Marks [eventId] as processed at the current wall-clock time and
  /// returns a new [EventEchoGuard].
  EventEchoGuard markProcessed(String eventId) {
    final newGuards = Map<String, DateTime>.from(_guards);
    newGuards[eventId] = DateTime.now();
    return EventEchoGuard._(guards: newGuards);
  }

  /// Removes guard entries whose timestamp is older than [maxAge] and
  /// returns a new [EventEchoGuard].
  EventEchoGuard expireStale(Duration maxAge) {
    final now = DateTime.now();
    final cutoff = now.subtract(maxAge);
    final newGuards = Map<String, DateTime>.from(_guards);
    newGuards.removeWhere((_, ts) => ts.isBefore(cutoff));
    return EventEchoGuard._(guards: newGuards);
  }

  /// Returns the number of currently active guard entries.
  int get activeGuardCount => _guards.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EventEchoGuard) return false;
    if (other.activeGuardCount != activeGuardCount) return false;
    for (final key in _guards.keys) {
      if (!other._guards.containsKey(key)) return false;
      if (other._guards[key] != _guards[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(
        _guards.entries.expand(
          (e) => [Object.hash(e.key, e.value)],
        ),
      );

  @override
  String toString() =>
      'EventEchoGuard(active: $activeGuardCount)';
}

/// The result of evaluating a bidirectional stream guard.
///
/// Carries the [nextGuard] instance reflecting the updated history
/// and a [shouldForward] flag indicating whether the message should
/// be forwarded or suppressed as an echo.
@immutable
class GuardDecision<T> {
  final BidirectionalStreamGuard<T> nextGuard;
  final bool shouldForward;

  const GuardDecision({
    required this.nextGuard,
    required this.shouldForward,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuardDecision<T> &&
        other.nextGuard == nextGuard &&
        other.shouldForward == shouldForward;
  }

  @override
  int get hashCode => Object.hash(nextGuard, shouldForward);

  @override
  String toString() =>
      'GuardDecision(shouldForward: $shouldForward)';
}

/// Generic guard for bidirectional message streams that prevents echo
/// loops caused by outbound messages looping back as inbound.
///
/// An echo is detected when an inbound message matches a recently
/// sent outbound message (or vice versa). Every mutating operation
/// returns a new immutable instance.
@immutable
@realizes(r'UML::BidirectionalStreamGuard.history')
class BidirectionalStreamGuard<T> {
  final List<_StreamRecord<T>> _history;

  const BidirectionalStreamGuard._({
    required List<_StreamRecord<T>> history,
  }) : _history = history;

  /// Creates an empty guard with no message history.
  const BidirectionalStreamGuard() : _history = const [];

  int get _historyLength => _history.length;

  BidirectionalStreamGuard<T> _record(String direction, T message) {
    final newHistory = List<_StreamRecord<T>>.from(_history)
      ..add(_StreamRecord(direction, message, DateTime.now()));
    return BidirectionalStreamGuard._(history: newHistory);
  }

  /// Evaluates whether [message] travelling in [direction] should be
  /// forwarded (returns true) or suppressed as an echo (returns false).
  ///
  /// An inbound message is treated as an echo when an identical outbound
  /// message was recorded prior to it. An outbound message is treated as
  /// an echo when an identical inbound message was recorded prior to it.
  ///
  /// Returns a [GuardDecision] carrying the updated guard state and the
  /// forwarding decision.
  GuardDecision<T> guard(String direction, T message) {
    final shouldForward = !_isEcho(direction, message);
    final nextGuard = _record(direction, message);
    return GuardDecision(nextGuard: nextGuard, shouldForward: shouldForward);
  }

  bool _isEcho(String direction, T message) {
    if (direction == 'inbound') {
      return _history.any(
        (r) => r.direction == 'outbound' && r.message == message,
      );
    }
    if (direction == 'outbound') {
      return _history.any(
        (r) => r.direction == 'inbound' && r.message == message,
      );
    }
    return false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BidirectionalStreamGuard<T>) return false;
    if (other._historyLength != _historyLength) return false;
    for (int i = 0; i < _historyLength; i++) {
      if (_history[i] != other._history[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_history);

  @override
  String toString() =>
      'BidirectionalStreamGuard(history: $_historyLength)';
}
