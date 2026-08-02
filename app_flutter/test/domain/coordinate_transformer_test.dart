import 'package:app_flutter/domain/coordinate_transformer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DatumRegistry', () {
    test('should return a registered datum with correct ellipsoid parameters', () {
      final datum = DatumRegistry.lookup('wgs-84');
      expect(datum, isNotNull);
      expect(datum!.name, equals('wgs-84'));
      expect(datum.semiMajorAxis, equals(6378137.0));
      expect(datum.inverseFlattening, equals(298.257223563));
    });

    test('should return null when a datum is not registered', () {
      expect(DatumRegistry.lookup('nonexistent'), isNull);
    });

    test('should have all five pre-registered datums available', () {
      expect(DatumRegistry.isRegistered('wgs-84'), isTrue);
      expect(DatumRegistry.isRegistered('nad83'), isTrue);
      expect(DatumRegistry.isRegistered('etrs89'), isTrue);
      expect(DatumRegistry.isRegistered('jgd2011'), isTrue);
      expect(DatumRegistry.isRegistered('cgcs2000'), isTrue);
    });
  });

  group('CoordinateTransformer ellipsoid <-> cartesian', () {
    test('should roundtrip geodetic coordinates through Cartesian and back', () {
      final datum = DatumRegistry.lookup('wgs-84')!;
      const lat = 52.0;
      const lon = 13.0;
      const h = 100.0;

      final cart = CoordinateTransformer.ellipsoidToCartesian(lat, lon, h, datum);
      final geo = CoordinateTransformer.cartesianToEllipsoid(cart[0], cart[1], cart[2], datum);

      expect(geo[0], closeTo(lat, 1e-9));
      expect(geo[1], closeTo(lon, 1e-9));
      expect(geo[2], closeTo(h, 1e-6));
    });

    test('should roundtrip with a non-WGS84 ellipsoid', () {
      final datum = DatumRegistry.lookup('nad83')!;
      const lat = -33.0;
      const lon = 151.0;
      const h = 50.0;

      final cart = CoordinateTransformer.ellipsoidToCartesian(lat, lon, h, datum);
      final geo = CoordinateTransformer.cartesianToEllipsoid(cart[0], cart[1], cart[2], datum);

      expect(geo[0], closeTo(lat, 1e-9));
      expect(geo[1], closeTo(lon, 1e-9));
      expect(geo[2], closeTo(h, 1e-6));
    });

    test('should handle the equator case correctly', () {
      final datum = DatumRegistry.lookup('wgs-84')!;
      final cart = CoordinateTransformer.ellipsoidToCartesian(0.0, 0.0, 0.0, datum);

      expect(cart[0], closeTo(datum.semiMajorAxis, 1e-6));
      expect(cart[1], closeTo(0.0, 1e-12));
      expect(cart[2], closeTo(0.0, 1e-12));
    });
  });

  group('CoordinateTransformer datum transform', () {
    test('should return identical coordinates for an identity transform', () {
      final result = CoordinateTransformer.transform(
        'wgs-84', 'wgs-84', 52.0, 13.0, 100.0,
      );
      expect(result[0], closeTo(52.0, 1e-9));
      expect(result[1], closeTo(13.0, 1e-9));
      expect(result[2], closeTo(100.0, 1e-9));
    });

    test('should roundtrip through an intermediate datum back to origin', () {
      final result = CoordinateTransformer.transform(
        'wgs-84', 'nad83', 52.0, 13.0, 100.0,
      );
      final back = CoordinateTransformer.transform(
        'nad83', 'wgs-84', result[0], result[1], result[2],
      );

      expect(back[0], closeTo(52.0, 1e-9));
      expect(back[1], closeTo(13.0, 1e-9));
      expect(back[2], closeTo(100.0, 1e-6));
    });

    test('should produce a measurable shift between datums with non-zero offsets', () {
      final wgs = CoordinateTransformer.transform(
        'wgs-84', 'wgs-84', 48.0, 11.0, 100.0,
      );
      final nad = CoordinateTransformer.transform(
        'wgs-84', 'nad83', 48.0, 11.0, 100.0,
      );

      final latDiff = (nad[0] - wgs[0]).abs();
      final lonDiff = (nad[1] - wgs[1]).abs();
      expect(latDiff + lonDiff, greaterThan(0.0));
    });
  });

  group('CoordinateTransformer error handling', () {
    test('should throw UnsupportedDatumError when from-datum is unknown', () {
      expect(
        () => CoordinateTransformer.transform('invalid', 'wgs-84', 0.0, 0.0, 0.0),
        throwsA(isA<UnsupportedDatumError>()),
      );
    });

    test('should throw TransformationError when lat is NaN', () {
      expect(
        () => CoordinateTransformer.transform('wgs-84', 'wgs-84', double.nan, 13.0, 100.0),
        throwsA(isA<TransformationError>()),
      );
    });
  });
}
