import 'package:app_flutter/domain/nested_type.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NestedFieldDescriptor', () {
    test('should construct with nested fields and set type to nested', () {
      final nested = NestedFieldDescriptor(
        key: 'referenceFrame',
        label: 'Reference Frame',
        nestedFields: [
          const FieldDescriptor(
            key: 'astronomical-body',
            label: 'Astronomical Body',
            type: 'string',
          ),
          const FieldDescriptor(
            key: 'alternate-system',
            label: 'Alternate System',
            type: 'string',
          ),
        ],
      );

      expect(nested.key, equals('referenceFrame'));
      expect(nested.label, equals('Reference Frame'));
      expect(nested.type, equals('nested'));
      expect(nested.nestedFields, hasLength(2));
      expect(nested.nestedFields[0].key, equals('astronomical-body'));
      expect(nested is FieldDescriptor, isTrue);
    });
  });

  group('NestedTypeDescriptor flatten', () {
    test('should flatten one level of nesting with dotted keys and section labels', () {
      final type = NestedTypeDescriptor(
        typeName: 'test-type',
        displayName: 'Test',
        iconName: 'info',
        fields: [
          const FieldDescriptor(
            key: 'name',
            label: 'Name',
            type: 'string',
          ),
          NestedFieldDescriptor(
            key: 'frame',
            label: 'Frame',
            nestedFields: [
              const FieldDescriptor(
                key: 'body',
                label: 'Body',
                type: 'string',
              ),
            ],
          ),
        ],
        childTypes: [],
        relatedTypes: [],
        parentTypes: [],
      );

      final flat = type.flatten();

      expect(flat, hasLength(2));
      expect(flat[0].key, equals('name'));
      expect(flat[0].type, equals('string'));
      expect(flat[0].sectionLabel, isNull);
      expect(flat[1].key, equals('frame.body'));
      expect(flat[1].type, equals('string'));
      expect(flat[1].sectionLabel, equals('Frame'));
    });

    test('should flatten two levels of nesting with propagated section labels', () {
      final type = NestedTypeDescriptor(
        typeName: 'deep',
        displayName: 'Deep',
        iconName: 'layers',
        fields: [
          NestedFieldDescriptor(
            key: 'outer',
            label: 'Outer',
            nestedFields: [
              NestedFieldDescriptor(
                key: 'inner',
                label: 'Inner',
                nestedFields: [
                  const FieldDescriptor(
                    key: 'value',
                    label: 'Value',
                    type: 'double',
                  ),
                ],
              ),
            ],
          ),
        ],
        childTypes: [],
        relatedTypes: [],
        parentTypes: [],
      );

      final flat = type.flatten();

      expect(flat, hasLength(1));
      expect(flat[0].key, equals('outer.inner.value'));
      expect(flat[0].type, equals('double'));
      expect(flat[0].sectionLabel, equals('Inner'));
    });

    test('should build and flatten GeoLocation to ReferenceFrame to GeodeticSystem chain', () {
      final json = {
        'typeName': 'geo-location',
        'displayName': 'Geo Location',
        'iconName': 'public',
        'fields': [
          {'key': 'timestamp', 'label': 'Timestamp', 'type': 'date'},
          {'key': 'validUntil', 'label': 'Valid Until', 'type': 'date'},
          {'key': 'astronomicalBody', 'label': 'Astronomical Body', 'type': 'string'},
          {
            'key': 'referenceFrame',
            'label': 'Reference Frame',
            'type': 'nested',
            'nestedFields': [
              {'key': 'astronomical-body', 'label': 'Body', 'type': 'string'},
              {'key': 'alternate-system', 'label': 'Alternate System', 'type': 'string'},
              {
                'key': 'geodeticSystem',
                'label': 'Geodetic System',
                'type': 'nested',
                'nestedFields': [
                  {'key': 'geodetic-datum', 'label': 'Geodetic Datum', 'type': 'string'},
                  {'key': 'coord-accuracy', 'label': 'Coord Accuracy', 'type': 'double'},
                  {'key': 'height-accuracy', 'label': 'Height Accuracy', 'type': 'double'},
                ],
              },
            ],
          },
        ],
        'childTypes': [],
        'relatedTypes': [],
        'parentTypes': [],
      };

      final type = NestedTypeDescriptor.fromJson(json);

      expect(type.typeName, equals('geo-location'));
      expect(type.fields, hasLength(4));
      final refFrame = type.fields[3] as NestedFieldDescriptor;
      expect(refFrame.key, equals('referenceFrame'));
      expect(refFrame.nestedFields, hasLength(3));

      final geodetic = refFrame.nestedFields[2] as NestedFieldDescriptor;
      expect(geodetic.key, equals('geodeticSystem'));
      expect(geodetic.nestedFields, hasLength(3));

      final flat = type.flatten();

      expect(flat, hasLength(8));
      expect(flat[0].key, equals('timestamp'));
      expect(flat[1].key, equals('validUntil'));
      expect(flat[2].key, equals('astronomicalBody'));

      expect(flat[3].key, equals('referenceFrame.astronomical-body'));
      expect(flat[3].sectionLabel, equals('Reference Frame'));
      expect(flat[4].key, equals('referenceFrame.alternate-system'));
      expect(flat[4].sectionLabel, equals('Reference Frame'));

      expect(flat[5].key, equals('referenceFrame.geodeticSystem.geodetic-datum'));
      expect(flat[5].sectionLabel, equals('Geodetic System'));
      expect(flat[6].key, equals('referenceFrame.geodeticSystem.coord-accuracy'));
      expect(flat[7].key, equals('referenceFrame.geodeticSystem.height-accuracy'));
    });

    test('should return empty list when nested fields are empty', () {
      final type = NestedTypeDescriptor(
        typeName: 'empty-nested',
        displayName: 'Empty',
        iconName: 'block',
        fields: [
          NestedFieldDescriptor(
            key: 'empty',
            label: 'Empty',
            nestedFields: [],
          ),
          const FieldDescriptor(
            key: 'scalar',
            label: 'Scalar',
            type: 'string',
          ),
        ],
        childTypes: [],
        relatedTypes: [],
        parentTypes: [],
      );

      final flat = type.flatten();

      expect(flat, hasLength(1));
      expect(flat[0].key, equals('scalar'));
      expect(flat[0].type, equals('string'));
    });

    test('should preserve scalar field properties when flattening', () {
      final json = {
        'typeName': 'mixed',
        'displayName': 'Mixed',
        'iconName': 'blend',
        'fields': [
          {
            'key': 'count',
            'label': 'Count',
            'type': 'int',
            'minValue': 0,
            'maxValue': 100,
            'required': true,
          },
          {
            'key': 'sub',
            'label': 'Sub',
            'type': 'nested',
            'nestedFields': [
              {
                'key': 'flag',
                'label': 'Flag',
                'type': 'enum',
                'enumOptions': ['on', 'off'],
                'defaultValue': 'on',
              },
            ],
          },
        ],
        'childTypes': [],
        'relatedTypes': [],
        'parentTypes': [],
      };

      final type = NestedTypeDescriptor.fromJson(json);
      final flat = type.flatten();

      expect(flat, hasLength(2));
      expect(flat[0].key, equals('count'));
      expect(flat[0].type, equals('int'));
      expect(flat[0].minValue, equals(0));
      expect(flat[0].maxValue, equals(100));
      expect(flat[0].required, isTrue);

      expect(flat[1].key, equals('sub.flag'));
      expect(flat[1].type, equals('enum'));
      expect(flat[1].enumOptions, equals(['on', 'off']));
      expect(flat[1].defaultValue, equals('on'));
      expect(flat[1].sectionLabel, equals('Sub'));
    });

    test('should propagate section labels from nested fields to children', () {
      final type = NestedTypeDescriptor(
        typeName: 'sections',
        displayName: 'Sections',
        iconName: 'view_list',
        fields: [
          NestedFieldDescriptor(
            key: 'groupA',
            label: 'Group A',
            nestedFields: [
              NestedFieldDescriptor(
                key: 'subgroup',
                label: 'Subgroup',
                nestedFields: [
                  const FieldDescriptor(
                    key: 'alpha',
                    label: 'Alpha',
                    type: 'string',
                    sectionLabel: 'Override',
                  ),
                  const FieldDescriptor(
                    key: 'beta',
                    label: 'Beta',
                    type: 'string',
                  ),
                ],
              ),
            ],
          ),
        ],
        childTypes: [],
        relatedTypes: [],
        parentTypes: [],
      );

      final flat = type.flatten();

      expect(flat, hasLength(2));
      expect(flat[0].key, equals('groupA.subgroup.alpha'));
      expect(flat[0].sectionLabel, equals('Override'));
      expect(flat[1].key, equals('groupA.subgroup.beta'));
      expect(flat[1].sectionLabel, equals('Subgroup'));
    });
  });

  group('NestedTypeDescriptor.fromJson', () {
    test('should roundtrip a full type descriptor with child and related types', () {
      final json = {
        'typeName': 'device',
        'displayName': 'Device',
        'iconName': 'developer_board',
        'fields': [
          {'key': 'hostname', 'label': 'Hostname', 'type': 'string', 'sectionOrder': 1},
          {
            'key': 'position',
            'label': 'Position',
            'type': 'nested',
            'sectionOrder': 2,
            'nestedFields': [
              {'key': 'lat', 'label': 'Latitude', 'type': 'double'},
              {'key': 'lon', 'label': 'Longitude', 'type': 'double'},
            ],
          },
        ],
        'childTypes': [
          {
            'relationName': 'contains',
            'childTypeName': 'port',
            'childLabel': 'Ports',
          },
        ],
        'relatedTypes': [
          {
            'relationName': 'logged_by',
            'childTypeName': 'event',
            'childLabel': 'Events',
          },
        ],
        'parentTypes': [
          {
            'relationName': 'belongs_to',
            'childTypeName': 'rack',
            'childLabel': 'Racks',
          },
        ],
      };

      final type = NestedTypeDescriptor.fromJson(json);

      expect(type.typeName, equals('device'));
      expect(type.displayName, equals('Device'));
      expect(type.iconName, equals('developer_board'));

      expect(type.fields, hasLength(2));
      expect(type.fields[0].key, equals('hostname'));
      expect(type.fields[0].sectionOrder, equals(1));

      final position = type.fields[1] as NestedFieldDescriptor;
      expect(position.key, equals('position'));
      expect(position.sectionOrder, equals(2));
      expect(position.nestedFields, hasLength(2));

      expect(type.childTypes, hasLength(1));
      expect(type.childTypes[0].relationName, equals('contains'));
      expect(type.childTypes[0].childTypeName, equals('port'));

      expect(type.relatedTypes, hasLength(1));
      expect(type.relatedTypes[0].childTypeName, equals('event'));

      expect(type.parentTypes, hasLength(1));
      expect(type.parentTypes[0].childTypeName, equals('rack'));

      final flat = type.flatten();
      expect(flat, hasLength(3));
      expect(flat[0].key, equals('hostname'));
      expect(flat[1].key, equals('position.lat'));
      expect(flat[1].sectionLabel, equals('Position'));
      expect(flat[2].key, equals('position.lon'));
    });

    test('should default displayName and iconName when absent', () {
      final json = {
        'typeName': 'bare',
        'fields': [],
        'childTypes': [],
        'relatedTypes': [],
        'parentTypes': [],
      };

      final type = NestedTypeDescriptor.fromJson(json);

      expect(type.displayName, equals('bare'));
      expect(type.iconName, equals('help_outline'));
      expect(type.fields, isEmpty);
    });
  });
}
