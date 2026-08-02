import 'dart:math' as math;

import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Thrown when a velocity component fails validation.
@immutable
class VelocityComponentError implements Exception {
  final String message;
  const VelocityComponentError(this.message);

  @override
  String toString() => 'VelocityComponentError: $message';
}

/// Represents a velocity vector with north, east, and up components as defined in UML::Velocity.
///
/// [vNorth] is the velocity component in meters per second toward true north.
/// [vEast] is the velocity component in meters per second toward true east.
/// [vUp] is the velocity component in meters per second upward.
@immutable
@realizes(r'UML::Velocity.vNorth')
@realizes(r'UML::Velocity.vEast')
@realizes(r'UML::Velocity.vUp')
class Velocity {
  final double vNorth;
  final double vEast;
  final double vUp;

  const Velocity({
    this.vNorth = 0.0,
    this.vEast = 0.0,
    this.vUp = 0.0,
  });

  double speed() {
    return math.sqrt(vNorth * vNorth + vEast * vEast);
  }

  double heading() {
    if (vNorth == 0.0 && vEast == 0.0) return 0.0;
    final degrees = math.atan2(vEast, vNorth) * 180.0 / math.pi;
    return degrees < 0 ? degrees + 360.0 : degrees;
  }

  double speed3D() {
    return math.sqrt(vNorth * vNorth + vEast * vEast + vUp * vUp);
  }

  bool get isStationary => vNorth == 0.0 && vEast == 0.0 && vUp == 0.0;

  Velocity copyWith({
    double? vNorth,
    double? vEast,
    double? vUp,
  }) {
    return Velocity(
      vNorth: vNorth ?? this.vNorth,
      vEast: vEast ?? this.vEast,
      vUp: vUp ?? this.vUp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'v-north': vNorth,
      'v-east': vEast,
      'v-up': vUp,
    };
  }

  factory Velocity.fromJson(Map<String, dynamic> json) {
    return Velocity(
      vNorth: (json['v-north'] as num).toDouble(),
      vEast: (json['v-east'] as num).toDouble(),
      vUp: (json['v-up'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Velocity &&
        other.vNorth == vNorth &&
        other.vEast == vEast &&
        other.vUp == vUp;
  }

  @override
  int get hashCode => Object.hash(vNorth, vEast, vUp);

  @override
  String toString() => 'Velocity(vNorth: $vNorth, vEast: $vEast, vUp: $vUp)';
}
