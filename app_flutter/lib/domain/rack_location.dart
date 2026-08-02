class RackLocationValidationException implements Exception {
  final String message;

  const RackLocationValidationException(this.message);

  @override
  String toString() => 'RackLocationValidationException: $message';
}

class RackLocation {
  final String? locationRef;
  final int? rowNumber;
  final int? columnNumber;

  RackLocation({this.locationRef, this.rowNumber, this.columnNumber});

  bool isValid() => locationRef != null || rowNumber != null || columnNumber != null;

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
