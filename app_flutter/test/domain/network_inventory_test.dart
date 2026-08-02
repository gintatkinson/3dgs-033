import 'package:app_flutter/domain/network_inventory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkElement', () {
    test('should be valid when neId is "NE-001"', () {
      final ne = NetworkElement(neId: 'NE-001');
      expect(ne.neId, equals('NE-001'));
      expect(ne.isValid(), isTrue);
    });

    test('should throw NeIdError when neId is empty', () {
      expect(
        () => NetworkElement(neId: ''),
        throwsA(isA<NeIdError>()),
      );
      expect(
        () => NetworkElement(neId: '  '),
        throwsA(isA<NeIdError>()),
      );
    });

    test('should be valid when all optional fields are provided', () {
      final ne = NetworkElement(
        neId: 'NE-001',
        neType: 'nwi:ne-physical',
        uuid: '550e8400-e29b-41d4-a716-446655440000',
        name: 'Core Router NYC-01',
        alias: 'CR-NYC-01',
        description: 'Core router at NYC data center',
        mfgName: 'Cisco Systems',
        productName: 'ASR 9000 Series',
        productRev: 'R6.5.3',
      );

      expect(ne.neId, equals('NE-001'));
      expect(ne.neType, equals('nwi:ne-physical'));
      expect(ne.uuid, equals('550e8400-e29b-41d4-a716-446655440000'));
      expect(ne.name, equals('Core Router NYC-01'));
      expect(ne.alias, equals('CR-NYC-01'));
      expect(ne.description, equals('Core router at NYC data center'));
      expect(ne.mfgName, equals('Cisco Systems'));
      expect(ne.productName, equals('ASR 9000 Series'));
      expect(ne.productRev, equals('R6.5.3'));
      expect(ne.isValid(), isTrue);
    });

    test('should preserve all fields when roundtripping to JSON', () {
      final ne = NetworkElement(
        neId: 'NE-001',
        neType: 'nwi:ne-physical',
        uuid: '550e8400-e29b-41d4-a716-446655440000',
        name: 'Core Router NYC-01',
        alias: 'CR-NYC-01',
        description: 'Core router at NYC data center',
        mfgName: 'Cisco Systems',
        productName: 'ASR 9000 Series',
        productRev: 'R6.5.3',
      );

      final json = ne.toJson();
      final restored = NetworkElement.fromJson(json);

      expect(restored.neId, equals(ne.neId));
      expect(restored.neType, equals(ne.neType));
      expect(restored.uuid, equals(ne.uuid));
      expect(restored.name, equals(ne.name));
      expect(restored.alias, equals(ne.alias));
      expect(restored.description, equals(ne.description));
      expect(restored.mfgName, equals(ne.mfgName));
      expect(restored.productName, equals(ne.productName));
      expect(restored.productRev, equals(ne.productRev));
    });

    test('should preserve null optional fields when roundtripping minimal element', () {
      final ne = NetworkElement(neId: 'NE-Minimal');

      final json = ne.toJson();
      final restored = NetworkElement.fromJson(json);

      expect(restored.neId, equals('NE-Minimal'));
      expect(restored.neType, isNull);
      expect(restored.uuid, isNull);
      expect(restored.name, isNull);
      expect(restored.alias, isNull);
      expect(restored.description, isNull);
      expect(restored.mfgName, isNull);
      expect(restored.productName, isNull);
      expect(restored.productRev, isNull);
    });
  });

  group('Component', () {
    test('should be valid when componentId is "Chassis-01"', () {
      final comp = Component(componentId: 'Chassis-01');
      expect(comp.componentId, equals('Chassis-01'));
      expect(comp.isValid(), isTrue);
    });

    test('should throw ComponentIdError when componentId is empty', () {
      expect(
        () => Component(componentId: ''),
        throwsA(isA<ComponentIdError>()),
      );
      expect(
        () => Component(componentId: '  '),
        throwsA(isA<ComponentIdError>()),
      );
    });

    test('should support parent references when parent list is provided', () {
      final comp = Component(
        componentId: 'Port-01',
        parent: ['Slot-01'],
      );
      expect(comp.parent, equals(['Slot-01']));
      expect(comp.isValid(), isTrue);

      final noParent = Component(componentId: 'Chassis-01');
      expect(noParent.parent, isEmpty);
    });

    test('should indicate whether component is an FRU', () {
      final fru = Component(componentId: 'Module-01', isFru: true);
      expect(fru.isFru, isTrue);

      final nonFru = Component(componentId: 'Screw-01', isFru: false);
      expect(nonFru.isFru, isFalse);

      final unspecified = Component(componentId: 'Unknown');
      expect(unspecified.isFru, isNull);
    });

    test('should indicate whether component is the main chassis', () {
      final comp = Component(
        componentId: 'Chassis-01',
        class_: 'ianahw:chassis',
        isMain: true,
      );
      expect(comp.isMain, isTrue);
      expect(comp.class_, equals('ianahw:chassis'));

      final nonChassis = Component(
        componentId: 'Port-01',
        class_: 'ianahw:port',
        isMain: false,
      );
      expect(nonChassis.isMain, isFalse);
    });

    test('should preserve all fields when roundtripping to JSON', () {
      final comp = Component(
        componentId: 'Chassis-01',
        class_: 'ianahw:chassis',
        mfgName: 'Cisco Systems',
        productName: 'ASR 9006 Chassis',
        hardwareRev: '1.2',
        partNumber: 'ASR-9006-AC',
        serialNumber: 'FTX12345678',
        isFru: true,
        parent: ['Slot-01'],
        parentRelPos: '0',
        isMain: true,
      );

      final json = comp.toJson();
      final restored = Component.fromJson(json);

      expect(restored.componentId, equals(comp.componentId));
      expect(restored.class_, equals(comp.class_));
      expect(restored.mfgName, equals(comp.mfgName));
      expect(restored.productName, equals(comp.productName));
      expect(restored.hardwareRev, equals(comp.hardwareRev));
      expect(restored.partNumber, equals(comp.partNumber));
      expect(restored.serialNumber, equals(comp.serialNumber));
      expect(restored.isFru, equals(comp.isFru));
      expect(restored.parent, equals(comp.parent));
      expect(restored.parentRelPos, equals(comp.parentRelPos));
      expect(restored.isMain, equals(comp.isMain));
    });
  });

  group('NetworkInventory', () {
    test('should be empty when created with empty factory', () {
      final inventory = NetworkInventory.empty();
      expect(inventory.isEmpty, isTrue);
    });

    test('should roundtrip empty state through JSON', () {
      final inventory = NetworkInventory.empty();
      final json = inventory.toJson();
      final restored = NetworkInventory.fromJson(json);
      expect(restored.isEmpty, isTrue);
    });
  });
}
