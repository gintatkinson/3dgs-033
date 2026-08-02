import 'package:app_flutter/domain/event_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventEchoGuard', () {
    test('markProcessed then isGuarded returns true', () {
      var guard = const EventEchoGuard();

      guard = guard.markProcessed('event-001');

      expect(guard.isGuarded('event-001'), isTrue);
    });

    test('isGuarded returns false for unmarked event', () {
      const guard = EventEchoGuard();

      expect(guard.isGuarded('event-999'), isFalse);
    });

    test('expireStale removes entries older than maxAge', () async {
      var guard = const EventEchoGuard();

      guard = guard.markProcessed('event-old');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      guard = guard.expireStale(const Duration(milliseconds: 5));

      expect(guard.isGuarded('event-old'), isFalse);
    });

    test('activeGuardCount reflects number of active guards', () {
      var guard = const EventEchoGuard();

      guard = guard.markProcessed('a');
      guard = guard.markProcessed('b');
      guard = guard.markProcessed('c');

      expect(guard.activeGuardCount, 3);

      guard = guard.markProcessed('a');

      expect(guard.activeGuardCount, 3);
    });
  });

  group('BidirectionalStreamGuard', () {
    test('guard returns shouldForward=true for first message', () {
      var streamGuard = const BidirectionalStreamGuard<String>();
      final decision = streamGuard.guard('inbound', 'hello');

      expect(decision.shouldForward, isTrue);
      expect(decision.nextGuard, isNotNull);
      expect(decision.nextGuard == streamGuard, isFalse);
    });

    test('guard detects echo when outbound message returns as inbound', () {
      var streamGuard = const BidirectionalStreamGuard<String>();

      streamGuard = streamGuard.guard('outbound', 'update').nextGuard;
      final decision = streamGuard.guard('inbound', 'update');

      expect(decision.shouldForward, isFalse);
    });

    test('guard detects echo when inbound message re-sent as outbound', () {
      var streamGuard = const BidirectionalStreamGuard<int>();

      streamGuard = streamGuard.guard('inbound', 42).nextGuard;
      final decision = streamGuard.guard('outbound', 42);

      expect(decision.shouldForward, isFalse);
    });

    test('guard allows distinct messages regardless of direction', () {
      var streamGuard = const BidirectionalStreamGuard<String>();

      streamGuard = streamGuard.guard('inbound', 'alpha').nextGuard;
      final decision = streamGuard.guard('inbound', 'beta');

      expect(decision.shouldForward, isTrue);
    });
  });
}
