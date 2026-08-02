import 'package:app_flutter/domain/rack_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RackLocation', () {
    test('valid reference with only locationRef set', () {
      final location = RackLocation(locationRef: 'Room-101');

      expect(location.locationRef, equals('Room-101'));
      expect(location.rowNumber, isNull);
      expect(location.columnNumber, isNull);
      expect(location.isValid(), isTrue);
    });

    test('valid grid position with rowNumber and columnNumber only', () {
      final location = RackLocation(rowNumber: 5, columnNumber: 3);

      expect(location.locationRef, isNull);
      expect(location.rowNumber, equals(5));
      expect(location.columnNumber, equals(3));
      expect(location.isValid(), isTrue);
    });

    test('null all fields is invalid', () {
      final location = RackLocation();

      expect(location.locationRef, isNull);
      expect(location.rowNumber, isNull);
      expect(location.columnNumber, isNull);
      expect(location.isValid(), isFalse);
    });

    test('JSON roundtrip preserves all fields', () {
      final location = RackLocation(
        locationRef: 'Room-101',
        rowNumber: 1,
        columnNumber: 1,
      );

      final json = location.toJson();
      final restored = RackLocation.fromJson(json);

      expect(restored.locationRef, equals(location.locationRef));
      expect(restored.rowNumber, equals(location.rowNumber));
      expect(restored.columnNumber, equals(location.columnNumber));
    });
  });
}
