enum LocationCoordinateType { ellipsoid, cartesian }

abstract class LocationCoordinate {
  LocationCoordinateType get type;

  Map<String, dynamic> toJson();

  static LocationCoordinateType? detectType(Map<String, dynamic> json) {
    if (json.containsKey('latitude') || json.containsKey('longitude') || json.containsKey('height')) {
      return LocationCoordinateType.ellipsoid;
    }
    if (json.containsKey('x') || json.containsKey('y') || json.containsKey('z')) {
      return LocationCoordinateType.cartesian;
    }
    return null;
  }

  static bool isEllipsoid(Map<String, dynamic> json) =>
      detectType(json) == LocationCoordinateType.ellipsoid;

  static bool isCartesian(Map<String, dynamic> json) =>
      detectType(json) == LocationCoordinateType.cartesian;
}
