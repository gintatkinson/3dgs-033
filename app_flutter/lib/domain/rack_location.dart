import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Represents a rack location as defined in UML::RackLocation.
///
/// [locationRef] is a named location reference.
/// [rowNumber] and [columnNumber] are grid coordinates.
/// At least one field must be non-null for a valid location.
@immutable
@realizes(r'UML::RackLocation')
class RackLocation {
  final String? locationRef;
  final int? rowNumber;
  final int? columnNumber;

  RackLocation({this.locationRef, this.rowNumber, this.columnNumber});

  bool isValid() => locationRef != null || rowNumber != null || columnNumber != null;

  bool validateRef(Set<String> existingLocationIds) {
    if (locationRef == null) return true;
    return existingLocationIds.contains(locationRef);
  }

  Map<String, dynamic> toJson() => {
        if (locationRef != null) 'location_ref': locationRef,
        if (rowNumber != null) 'row_number': rowNumber,
        if (columnNumber != null) 'column_number': columnNumber,
      };

  factory RackLocation.fromJson(Map<String, dynamic> json) {
    return RackLocation(
      locationRef: json['location_ref'] as String?,
      rowNumber: json['row_number'] as int?,
      columnNumber: json['column_number'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RackLocation &&
          other.locationRef == locationRef &&
          other.rowNumber == rowNumber &&
          other.columnNumber == columnNumber;

  @override
  int get hashCode => Object.hash(locationRef, rowNumber, columnNumber);

  @override
  String toString() =>
      'RackLocation(locationRef: $locationRef, rowNumber: $rowNumber, columnNumber: $columnNumber)';
}
