import 'package:app_flutter/domain/geodetic_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeodeticSystem', () {
    test('default wgs-84 datum and null accuracies', () {
      final gs = GeodeticSystem();
      expect(gs.geodeticDatum, equals('wgs-84'));
      expect(gs.coordAccuracy, isNull);
      expect(gs.heightAccuracy, isNull);
    });

    test('custom datum "me" for lunar', () {
      final gs = GeodeticSystem(geodeticDatum: 'me');
      expect(gs.geodeticDatum, equals('me'));
      expect(gs.coordAccuracy, isNull);
      expect(gs.heightAccuracy, isNull);
    });

    test('valid coord-accuracy with 6 decimal places', () {
      final gs = GeodeticSystem(coordAccuracy: 0.000001);
      expect(gs.coordAccuracy, equals(0.000001));
    });

    test('invalid coord-accuracy with 7 decimal places throws', () {
      expect(
        () => GeodeticSystem(coordAccuracy: 0.0000001),
        throwsA(isA<GeodeticSystemValidationException>()),
      );
    });

    test('invalid datum with control characters throws', () {
      expect(
        () => GeodeticSystem(geodeticDatum: 'bad\ndatum'),
        throwsA(isA<GeodeticSystemValidationException>()),
      );
    });

    test('null accuracy values', () {
      final gs = GeodeticSystem(coordAccuracy: null, heightAccuracy: null);
      expect(gs.coordAccuracy, isNull);
      expect(gs.heightAccuracy, isNull);
    });

    test('copyWith preserves unchanged fields', () {
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

    test('JSON roundtrip', () {
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
  });
}
