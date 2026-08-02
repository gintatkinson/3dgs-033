import 'package:app_flutter/domain/reference_frame.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReferenceFrame', () {
    test('Default earth reference frame', () {
      final frame = ReferenceFrame();
      expect(frame.astronomicalBody, equals('earth'));
      expect(frame.hasAlternateSystem, isFalse);
    });

    test('Valid non-earth body "mars"', () {
      final frame = ReferenceFrame(astronomicalBody: 'mars');
      expect(frame.astronomicalBody, equals('mars'));
    });

    test('Invalid body name with control characters', () {
      expect(
        () => ReferenceFrame(astronomicalBody: 'earth\n'),
        throwsA(isA<ReferenceFrameValidationException>()),
      );
    });

    test('Has alternate system when set', () {
      final frame = ReferenceFrame(alternateSystem: 'simulation-xyz');
      expect(frame.alternateSystem, equals('simulation-xyz'));
      expect(frame.hasAlternateSystem, isTrue);
    });

    test('No alternate system by default', () {
      final frame = ReferenceFrame();
      expect(frame.alternateSystem, isNull);
      expect(frame.hasAlternateSystem, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      final frame = ReferenceFrame(astronomicalBody: 'mars');
      final copy = frame.copyWith(alternateSystem: 'sim');
      expect(copy.astronomicalBody, equals('mars'));
      expect(copy.alternateSystem, equals('sim'));
      final copyBody = copy.copyWith(astronomicalBody: 'moon');
      expect(copyBody.astronomicalBody, equals('moon'));
      expect(copyBody.alternateSystem, equals('sim'));
    });

    test('JSON roundtrip', () {
      final frame = ReferenceFrame(
        astronomicalBody: 'moon',
        alternateSystem: 'sim',
      );
      final json = frame.toJson();
      expect(json['astronomical-body'], equals('moon'));
      expect(json['alternate-system'], equals('sim'));
      final restored = ReferenceFrame.fromJson(json);
      expect(restored.astronomicalBody, equals('moon'));
      expect(restored.alternateSystem, equals('sim'));
    });

    test('Earth factory produces correct defaults', () {
      final frame = ReferenceFrame.defaultEarth();
      expect(frame.astronomicalBody, equals('earth'));
      expect(frame.alternateSystem, isNull);
      expect(frame.hasAlternateSystem, isFalse);
    });
  });
}
