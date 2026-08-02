import 'package:app_flutter/domain/annotations.dart';
import 'package:app_flutter/domain/location_coordinate.dart';
import 'package:meta/meta.dart';

/// Represents a 3D Cartesian coordinate as defined in UML::Cartesian.
///
/// [x], [y], and [z] are the three spatial axes.
@immutable
@realizes(r'UML::Cartesian')
class CartesianCoordinate extends LocationCoordinate {
  final double x;
  final double y;
  final double z;

  CartesianCoordinate({
    required this.x,
    required this.y,
    required this.z,
  });

  @override
  LocationCoordinateType get type => LocationCoordinateType.cartesian;

  @override
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }

  factory CartesianCoordinate.fromJson(Map<String, dynamic> json) {
    return CartesianCoordinate(
      x: json['x'] as double,
      y: json['y'] as double,
      z: json['z'] as double,
    );
  }
}
