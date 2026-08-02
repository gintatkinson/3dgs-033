import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Thrown when an astronomical body name contains invalid characters.
@immutable
class AstronomicalBodyError implements Exception {
  final String value;
  const AstronomicalBodyError(this.value);

  @override
  String toString() => 'AstronomicalBodyError: invalid astronomical-body: "$value"';
}

/// Represents a reference frame for coordinate systems as defined in UML::ReferenceFrame.
///
/// [astronomicalBody] identifies the celestial body (default: "earth").
/// [alternateSystem] is an optional label for a non-standard coordinate system.
@immutable
@realizes(r'UML::ReferenceFrame')
class ReferenceFrame {
  static const String defaultAstronomicalBody = 'earth';

  static const String earth = 'earth';
  static const String moon = 'moon';
  static const String mars = 'mars';
  static const String sun = 'sun';
  static const String enceladus = 'enceladus';
  static const String ceres = 'ceres';

  static final _pattern = RegExp(r'^[\x20-\x40\x5b-\x7e]*$');

  final String astronomicalBody;
  final String? alternateSystem;

  const ReferenceFrame._(this.astronomicalBody, this.alternateSystem);

  ReferenceFrame({
    String? astronomicalBody,
    this.alternateSystem,
  }) : astronomicalBody = _normalize(astronomicalBody ?? defaultAstronomicalBody);

  factory ReferenceFrame.defaultEarth() => ReferenceFrame();

  static String _normalize(String value) {
    final normalized = value.toLowerCase();
    if (!_pattern.hasMatch(normalized)) {
      throw AstronomicalBodyError(value);
    }
    return normalized;
  }

  bool get hasAlternateSystem => alternateSystem != null;

  ReferenceFrame copyWith({String? astronomicalBody, String? alternateSystem}) {
    return ReferenceFrame(
      astronomicalBody: astronomicalBody ?? this.astronomicalBody,
      alternateSystem: alternateSystem ?? this.alternateSystem,
    );
  }

  Map<String, dynamic> toJson() => {
        'astronomical-body': astronomicalBody,
        if (alternateSystem != null) 'alternate-system': alternateSystem,
      };

  factory ReferenceFrame.fromJson(Map<String, dynamic> json) {
    return ReferenceFrame(
      astronomicalBody: json['astronomical-body'] as String?,
      alternateSystem: json['alternate-system'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceFrame &&
          other.astronomicalBody == astronomicalBody &&
          other.alternateSystem == alternateSystem;

  @override
  int get hashCode => Object.hash(astronomicalBody, alternateSystem);
}
