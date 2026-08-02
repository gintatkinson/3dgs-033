class ReferenceFrameValidationException implements Exception {
  final String message;

  const ReferenceFrameValidationException(this.message);

  @override
  String toString() => 'ReferenceFrameValidationException: $message';
}

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
      throw ReferenceFrameValidationException(
        'Invalid astronomical-body: "$value" contains invalid characters',
      );
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
