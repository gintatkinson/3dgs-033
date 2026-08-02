import 'dart:math' as math;

import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Thrown when a datum name is not found in [DatumRegistry].
@immutable
class UnsupportedDatumError implements Exception {
  final String value;
  const UnsupportedDatumError(this.value);

  @override
  String toString() => 'UnsupportedDatumError: "$value" is not a registered datum';
}

/// Thrown when a coordinate transformation produces invalid results,
/// such as when input values are NaN or infinite.
@immutable
class TransformationError implements Exception {
  final String message;
  const TransformationError(this.message);

  @override
  String toString() => 'TransformationError: $message';
}

/// Describes a geodetic reference ellipsoid with Helmert transformation
/// parameters relative to WGS-84 for use by [CoordinateTransformer].
@immutable
class Datum {
  final String name;
  final double semiMajorAxis;
  final double inverseFlattening;
  final double dx;
  final double dy;
  final double dz;
  final double rx;
  final double ry;
  final double rz;
  final double ds;

  const Datum({
    required this.name,
    required this.semiMajorAxis,
    required this.inverseFlattening,
    required this.dx,
    required this.dy,
    required this.dz,
    required this.rx,
    required this.ry,
    required this.rz,
    required this.ds,
  });

  double get _flattening => 1.0 / inverseFlattening;

  double get _eccentricitySquared {
    final f = _flattening;
    return 2.0 * f - f * f;
  }
}

/// Static registry of known geodetic datums keyed by name.
///
/// Five datums are pre-registered: **wgs-84**, **nad83**, **etrs89**,
/// **jgd2011**, and **cgcs2000**. Register additional datums with [register].
class DatumRegistry {
  static final Map<String, Datum> _datums = {};
  static bool _initialized = false;

  /// Pre-registered datum names.
  static const String wgs84 = 'wgs-84';
  static const String nad83 = 'nad83';
  static const String etrs89 = 'etrs89';
  static const String jgd2011 = 'jgd2011';
  static const String cgcs2000 = 'cgcs2000';

  DatumRegistry._();

  static void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;

    register(const Datum(
      name: wgs84,
      semiMajorAxis: 6378137.0,
      inverseFlattening: 298.257223563,
      dx: 0.0, dy: 0.0, dz: 0.0,
      rx: 0.0, ry: 0.0, rz: 0.0,
      ds: 0.0,
    ));

    register(const Datum(
      name: nad83,
      semiMajorAxis: 6378137.0,
      inverseFlattening: 298.257222101,
      dx: 0.9910, dy: -1.9072, dz: -0.5129,
      rx: 0.02579, ry: 0.00965, rz: 0.01166,
      ds: 0.0,
    ));

    register(const Datum(
      name: etrs89,
      semiMajorAxis: 6378137.0,
      inverseFlattening: 298.257222101,
      dx: 0.0547, dy: 0.0522, dz: -0.0741,
      rx: 0.0001, ry: -0.00005, rz: 0.00008,
      ds: 0.0,
    ));

    register(const Datum(
      name: jgd2011,
      semiMajorAxis: 6378137.0,
      inverseFlattening: 298.257222101,
      dx: 0.0, dy: 0.0, dz: 0.0,
      rx: 0.0, ry: 0.0, rz: 0.0,
      ds: 0.0,
    ));

    register(const Datum(
      name: cgcs2000,
      semiMajorAxis: 6378137.0,
      inverseFlattening: 298.257222101,
      dx: 0.0, dy: 0.0, dz: 0.0,
      rx: 0.0, ry: 0.0, rz: 0.0,
      ds: 0.0,
    ));
  }

  /// Registers a [datum] so it can be retrieved by [lookup].
  static void register(Datum datum) {
    _datums[datum.name.toLowerCase()] = datum;
  }

  /// Looks up a datum by case-insensitive [name], or returns `null`.
  static Datum? lookup(String name) {
    _ensureInitialized();
    return _datums[name.toLowerCase()];
  }

  /// Whether a datum named [name] has been registered.
  static bool isRegistered(String name) {
    _ensureInitialized();
    return _datums.containsKey(name.toLowerCase());
  }
}

/// Transforms geodetic coordinates between datums via ECEF Cartesian
/// using the standard 7-parameter Bursa-Wolf (Helmert) transformation.
///
/// Rotation parameters are in arc-seconds; scale offset is in ppm.
@immutable
@realizes(r'UML::CoordinateTransformer')
class CoordinateTransformer {
  static const double _arcSecToRad = math.pi / (180.0 * 3600.0);
  static const double _ppmToScale = 1.0e-6;

  CoordinateTransformer._();

  /// Converts geodetic coordinates ([lat], [lon] in degrees, [height]
  /// in metres) to Earth-Centred Earth-Fixed Cartesian (x, y, z) using
  /// the ellipsoid defined by [datum].
  static List<double> ellipsoidToCartesian(
    double lat,
    double lon,
    double height,
    Datum datum,
  ) {
    final latRad = lat * math.pi / 180.0;
    final lonRad = lon * math.pi / 180.0;
    final sinLat = math.sin(latRad);
    final cosLat = math.cos(latRad);
    final cosLon = math.cos(lonRad);
    final sinLon = math.sin(lonRad);

    final e2 = datum._eccentricitySquared;
    final n = datum.semiMajorAxis / math.sqrt(1.0 - e2 * sinLat * sinLat);

    return [
      (n + height) * cosLat * cosLon,
      (n + height) * cosLat * sinLon,
      (n * (1.0 - e2) + height) * sinLat,
    ];
  }

  /// Converts ECEF Cartesian [x], [y], [z] (metres) to geodetic
  /// coordinates (lat, lon in degrees, height in metres) using the
  /// ellipsoid defined by [datum].
  static List<double> cartesianToEllipsoid(
    double x,
    double y,
    double z,
    Datum datum,
  ) {
    final e2 = datum._eccentricitySquared;
    final a = datum.semiMajorAxis;
    final p = math.sqrt(x * x + y * y);

    if (p < 1e-12) {
      final lat = z >= 0 ? 90.0 : -90.0;
      final sinLat = z >= 0 ? 1.0 : -1.0;
      final n = a / math.sqrt(1.0 - e2 * sinLat * sinLat);
      return [lat, 0.0, z.abs() - n * (1.0 - e2)];
    }

    double lat = math.atan2(z, p * (1.0 - e2));
    double n = 0.0;
    double h = 0.0;

    for (int i = 0; i < 6; i++) {
      final sinLat = math.sin(lat);
      n = a / math.sqrt(1.0 - e2 * sinLat * sinLat);
      h = p / math.cos(lat) - n;
      final denominator = p * (1.0 - e2 * n / (n + h));
      lat = math.atan2(z, denominator);
    }

    final lon = math.atan2(y, x);

    return [
      lat * 180.0 / math.pi,
      lon * 180.0 / math.pi,
      h,
    ];
  }

  static void _applyHelmert(
    double x,
    double y,
    double z,
    double tx,
    double ty,
    double tz,
    double rx,
    double ry,
    double rz,
    double ds,
    List<double> out,
  ) {
    final rxRad = rx * _arcSecToRad;
    final ryRad = ry * _arcSecToRad;
    final rzRad = rz * _arcSecToRad;
    final scale = 1.0 + ds * _ppmToScale;

    out[0] = tx + scale * (x + rzRad * y - ryRad * z);
    out[1] = ty + scale * (-rzRad * x + y + rxRad * z);
    out[2] = tz + scale * (ryRad * x - rxRad * y + z);
  }

  /// Transforms geodetic coordinates ([lat], [lon] in degrees,
  /// [height] in metres) from [fromDatumName] to [toDatumName].
  ///
  /// Throws [UnsupportedDatumError] if either datum is unknown.
  /// Throws [TransformationError] if any coordinate is NaN or infinite.
  static List<double> transform(
    String fromDatumName,
    String toDatumName,
    double lat,
    double lon,
    double height,
  ) {
    _validateFinite(lat, 'lat');
    _validateFinite(lon, 'lon');
    _validateFinite(height, 'height');

    final fromDatum = DatumRegistry.lookup(fromDatumName);
    if (fromDatum == null) {
      throw UnsupportedDatumError(fromDatumName);
    }

    final toDatum = DatumRegistry.lookup(toDatumName);
    if (toDatum == null) {
      throw UnsupportedDatumError(toDatumName);
    }

    final cart = ellipsoidToCartesian(lat, lon, height, fromDatum);

    final wgsCart = [0.0, 0.0, 0.0];
    _applyHelmert(
      cart[0], cart[1], cart[2],
      fromDatum.dx, fromDatum.dy, fromDatum.dz,
      fromDatum.rx, fromDatum.ry, fromDatum.rz,
      fromDatum.ds,
      wgsCart,
    );

    final targetCart = [0.0, 0.0, 0.0];
    _applyHelmert(
      wgsCart[0], wgsCart[1], wgsCart[2],
      -toDatum.dx, -toDatum.dy, -toDatum.dz,
      -toDatum.rx, -toDatum.ry, -toDatum.rz,
      -toDatum.ds,
      targetCart,
    );

    return cartesianToEllipsoid(
      targetCart[0], targetCart[1], targetCart[2],
      toDatum,
    );
  }

  static void _validateFinite(double value, String label) {
    if (value.isNaN || value.isInfinite) {
      throw TransformationError('$label must be finite, got $value');
    }
  }
}
