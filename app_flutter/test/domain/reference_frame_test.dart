import 'package:app_flutter/domain/reference_frame.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReferenceFrame', () {
    test('should default to earth when no astronomical body is specified', () {
      final frame = ReferenceFrame();
      expect(frame.astronomicalBody, equals('earth'));
      expect(frame.hasAlternateSystem, isFalse);
    });

    test('should accept "mars" when a valid non-earth body is provided', () {
      final frame = ReferenceFrame(astronomicalBody: 'mars');
      expect(frame.astronomicalBody, equals('mars'));
    });

    test('should throw AstronomicalBodyError when body name has control characters', () {
      expect(
        () => ReferenceFrame(astronomicalBody: 'earth\n'),
        throwsA(isA<AstronomicalBodyError>()),
      );
    });

    test('should report alternate system when alternateSystem is set', () {
      final frame = ReferenceFrame(alternateSystem: 'simulation-xyz');
      expect(frame.alternateSystem, equals('simulation-xyz'));
      expect(frame.hasAlternateSystem, isTrue);
    });

    test('should not have alternate system when none is provided', () {
      final frame = ReferenceFrame();
      expect(frame.alternateSystem, isNull);
      expect(frame.hasAlternateSystem, isFalse);
    });

    test('should preserve unchanged fields when copyWith is called', () {
      final frame = ReferenceFrame(astronomicalBody: 'mars');
      final copy = frame.copyWith(alternateSystem: 'sim');
      expect(copy.astronomicalBody, equals('mars'));
      expect(copy.alternateSystem, equals('sim'));
      final copyBody = copy.copyWith(astronomicalBody: 'moon');
      expect(copyBody.astronomicalBody, equals('moon'));
      expect(copyBody.alternateSystem, equals('sim'));
    });

    test('should preserve all fields when roundtripping to JSON', () {
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

    test('should produce earth defaults when factory defaultEarth is used', () {
      final frame = ReferenceFrame.defaultEarth();
      expect(frame.astronomicalBody, equals('earth'));
      expect(frame.alternateSystem, isNull);
      expect(frame.hasAlternateSystem, isFalse);
    });

    /// @traces US-13
    test('should normalize uppercase "Earth" to lowercase', () {
      final frame = ReferenceFrame(astronomicalBody: 'Earth');
      expect(frame.astronomicalBody, equals('earth'));
    });

    /// @traces US-13
    test('should accept comet designation with forward slash', () {
      final frame = ReferenceFrame(astronomicalBody: '67p/churyumov-gerasimenko');
      expect(frame.astronomicalBody, equals('67p/churyumov-gerasimenko'));
    });

    /// @traces US-13
    test('should accept moon body when lunar deployment is configured', () {
      final frame = ReferenceFrame(astronomicalBody: 'moon');
      expect(frame.astronomicalBody, equals('moon'));
    });

    /// @traces US-13
    test('should report non-earth body when astronomical body is not earth', () {
      final mars = ReferenceFrame(astronomicalBody: 'mars');
      expect(mars.astronomicalBody, isNot(equals('earth')));

      final earth = ReferenceFrame();
      expect(earth.astronomicalBody, equals('earth'));
    });
  });
}
