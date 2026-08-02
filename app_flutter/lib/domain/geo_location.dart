import 'package:app_flutter/domain/date_time.dart';

class GeoLocationValidationException implements Exception {
  final String message;

  const GeoLocationValidationException(this.message);

  @override
  String toString() => 'GeoLocationValidationException: $message';
}

class GeoLocation {
  final String? timestamp;
  final String? validUntil;
  final String astronomicalBody;
  final String? geodeticDatum;

  const GeoLocation({
    this.timestamp,
    this.validUntil,
    this.astronomicalBody = 'earth',
    this.geodeticDatum = 'wgs-84',
  });

  bool isValid() {
    final ts = timestamp;
    final vu = validUntil;
    if (ts != null) {
      try {
        YangDateTime.parse(ts);
      } on Exception {
        return false;
      }
    }
    if (vu != null) {
      try {
        YangDateTime.parse(vu);
      } on Exception {
        return false;
      }
    }
    return true;
  }

  Duration? validityWindow() {
    final ts = timestamp;
    final vu = validUntil;
    if (ts == null || vu == null) return null;
    try {
      final start = YangDateTime.parse(ts);
      final end = YangDateTime.parse(vu);
      if (start.parsed == null || end.parsed == null) return null;
      return end.parsed!.difference(start.parsed!);
    } on Exception {
      return null;
    }
  }

  bool isExpired(DateTime now) {
    final vu = validUntil;
    if (vu == null) return false;
    try {
      final end = YangDateTime.parse(vu);
      if (end.parsed == null) return false;
      return end.parsed!.isBefore(now);
    } on Exception {
      return false;
    }
  }

  static GeoLocation parse(String input) {
    final trimmed = input.trim();
    Map<String, dynamic> map;
    if (trimmed.startsWith('{')) {
      try {
        map = _jsonDecode(trimmed);
      } on Object {
        throw const GeoLocationValidationException('Invalid JSON for GeoLocation');
      }
    } else {
      throw const GeoLocationValidationException('GeoLocation must be a JSON object');
    }

    final gl = GeoLocation.fromJson(map);
    if (!gl.isValid()) {
      throw const GeoLocationValidationException('GeoLocation validation failed');
    }
    return gl;
  }

  static Map<String, dynamic> _jsonDecode(String input) {
    final map = <String, dynamic>{};
    final content = input.substring(1, input.length - 1).trim();
    if (content.isEmpty) return map;

    final pairs = _splitJsonPairs(content);
    for (final pair in pairs) {
      final colonIdx = pair.indexOf(':');
      if (colonIdx == -1) continue;
      final key = pair.substring(0, colonIdx).trim().replaceAll('"', '');
      final value = pair.substring(colonIdx + 1).trim().replaceAll('"', '');
      map[key] = value;
    }
    return map;
  }

  static List<String> _splitJsonPairs(String input) {
    final pairs = <String>[];
    var depth = 0;
    var start = 0;
    for (var i = 0; i < input.length; i++) {
      if (input[i] == '{' || input[i] == '[') depth++;
      if (input[i] == '}' || input[i] == ']') depth--;
      if (input[i] == ',' && depth == 0) {
        pairs.add(input.substring(start, i));
        start = i + 1;
      }
    }
    if (start < input.length) {
      pairs.add(input.substring(start));
    }
    return pairs;
  }

  Map<String, dynamic> toJson() {
    return {
      if (timestamp != null) 'timestamp': timestamp,
      if (validUntil != null) 'validUntil': validUntil,
      'astronomicalBody': astronomicalBody,
      if (geodeticDatum != null) 'geodeticDatum': geodeticDatum,
    };
  }

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      timestamp: json['timestamp'] as String?,
      validUntil: json['validUntil'] as String?,
      astronomicalBody: json['astronomicalBody'] as String? ?? 'earth',
      geodeticDatum: json['geodeticDatum'] as String? ?? 'wgs-84',
    );
  }
}
