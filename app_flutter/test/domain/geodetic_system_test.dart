import 'package:app_flutter/domain/geodetic_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeodeticSystem', () {
    test('should default to wgs-84 when no datum is provided', () {
      final gs = GeodeticSystem();
      expect(gs.geodeticDatum, equals('wgs-84'));
      expect(gs.coordAccuracy, isNull);
      expect(gs.heightAccuracy, isNull);
    });

    test('should accept "me" when custom lunar datum is provided', () {
      final gs = GeodeticSystem(geodeticDatum: 'me');
      expect(gs.geodeticDatum, equals('me'));
      expect(gs.coordAccuracy, isNull);
      expect(gs.heightAccuracy, isNull);
    });

    test('should accept 0.000001 when coord-accuracy has 6 decimal places', () {
      final gs = GeodeticSystem(coordAccuracy: 0.000001);
      expect(gs.coordAccuracy, equals(0.000001));
    });

    test('should throw AccuracyRangeError when coord-accuracy has 7 decimal places', () {
      expect(
        () => GeodeticSystem(coordAccuracy: 0.0000001),
        throwsA(isA<AccuracyRangeError>()),
      );
    });

    test('should throw GeodeticDatumError when datum has control characters', () {
      expect(
        () => GeodeticSystem(geodeticDatum: 'bad\ndatum'),
        throwsA(isA<GeodeticDatumError>()),
      );
    });

    test('should accept null when accuracy values are not provided', () {
      final gs = GeodeticSystem(coordAccuracy: null, heightAccuracy: null);
      expect(gs.coordAccuracy, isNull);
      expect(gs.heightAccuracy, isNull);
    });

    test('should preserve unchanged fields when copyWith is called', () {
      final gs = GeodeticSystem(
        geodeticDatum: 'wgs-84-96',
        coordAccuracy: 0.01,
      );
      final copy = gs.copyWith(heightAccuracy: 0.001);
      expect(copy.geodeticDatum, equals('wgs-84-96'));
      expect(copy.coordAccuracy, equals(0.01));
      expect(copy.heightAccuracy, equals(0.001));
      final copyDatum = copy.copyWith(geodeticDatum: 'me');
      expect(copyDatum.geodeticDatum, equals('me'));
      expect(copyDatum.coordAccuracy, equals(0.01));
      expect(copyDatum.heightAccuracy, equals(0.001));
    });

    test('should preserve all fields when roundtripping to JSON', () {
      final gs = GeodeticSystem(
        geodeticDatum: 'wgs-84',
        coordAccuracy: 0.000001,
        heightAccuracy: 0.01,
      );
      final json = gs.toJson();
      expect(json['geodetic-datum'], equals('wgs-84'));
      expect(json['coord-accuracy'], equals(0.000001));
      expect(json['height-accuracy'], equals(0.01));
      final restored = GeodeticSystem.fromJson(json);
      expect(restored.geodeticDatum, equals('wgs-84'));
      expect(restored.coordAccuracy, equals(0.000001));
      expect(restored.heightAccuracy, equals(0.01));
    });

    /// @traces US-14
    test('should use explicit coord-accuracy override over datum default', () {
      final gs = GeodeticSystem(
        geodeticDatum: 'wgs-84',
        coordAccuracy: 0.000001,
      );
      expect(gs.coordAccuracy, equals(0.000001));
      expect(gs.heightAccuracy, isNull);
    });

    /// @traces US-14
    test('should fall back to null accuracy when no override configured', () {
      final gs = GeodeticSystem(geodeticDatum: 'wgs-84');
      expect(gs.coordAccuracy, isNull);
      expect(gs.heightAccuracy, isNull);
    });

    /// @traces US-14
    test('should accept height-accuracy override without coord-accuracy', () {
      final gs = GeodeticSystem(heightAccuracy: 0.01);
      expect(gs.coordAccuracy, isNull);
      expect(gs.heightAccuracy, equals(0.01));
    });

    test('should throw AccuracyRangeError when accuracy is NaN', () {
      expect(
        () => GeodeticSystem(coordAccuracy: double.nan),
        throwsA(isA<AccuracyRangeError>()),
      );
    });

    test('should throw AccuracyRangeError when accuracy is infinite', () {
      expect(
        () => GeodeticSystem(coordAccuracy: double.infinity),
        throwsA(isA<AccuracyRangeError>()),
      );
    });
  });
}
