import 'package:app_flutter/domain/annotations.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:meta/meta.dart';

/// A [FieldDescriptor] whose value is itself a structured sub-object with its
/// own editable fields.
///
/// When the data source declares a field of type `"nested"`, the UI can render
/// it as an expandable section containing [nestedFields]. Each nested field is
/// a full [FieldDescriptor], which means nesting can be arbitrarily deep.
///
/// Use [NestedTypeDescriptor.flatten] to convert a nested type hierarchy into
/// a flat list of fields suitable for the [PropertyGrid].
@immutable
@realizes(r'UML::NestedFieldDescriptor')
class NestedFieldDescriptor extends FieldDescriptor {
  /// The sub-fields that describe the internals of this nested object.
  ///
  /// May be empty (degenerate case — renders as a label-only section).
  /// May contain additional [NestedFieldDescriptor] entries for deeper
  /// nesting. The list is immutable; modify via copy operations only.
  final List<FieldDescriptor> nestedFields;

  /// Creates an immutable [NestedFieldDescriptor] with the given key, label,
  /// and nested field definitions.
  ///
  /// The [type] is always `"nested"`. [sectionLabel] and [sectionOrder]
  /// propagate to children when [NestedTypeDescriptor.flatten] is called.
  const NestedFieldDescriptor({
    required super.key,
    required super.label,
    required this.nestedFields,
    super.sectionLabel,
    super.sectionOrder = 0,
  }) : super(type: 'nested');
}

/// A [TypeDescriptor] whose fields may include [NestedFieldDescriptor] entries,
/// enabling complex domain objects such as `GeoLocation` (which composites
/// `ReferenceFrame`, `Location`, and `Velocity`) to be described generically.
///
/// Obtain instances from a seed JSON map via [NestedTypeDescriptor.fromJson].
/// Call [flatten] to convert the nested hierarchy into a single flat
/// `List<FieldDescriptor>` that the [PropertyGrid] can render section-by-section.
@immutable
@realizes(r'UML::NestedTypeDescriptor')
class NestedTypeDescriptor extends TypeDescriptor {
  /// Creates an immutable [NestedTypeDescriptor].
  ///
  /// All parameters match [TypeDescriptor]. There is no separate registry for
  /// nested sub-types — the nesting relationship is encoded directly in the
  /// [fields] list via [NestedFieldDescriptor] entries.
  const NestedTypeDescriptor({
    required super.typeName,
    required super.displayName,
    required super.iconName,
    required super.fields,
    required super.childTypes,
    required super.relatedTypes,
    required super.parentTypes,
  });

  /// Builds a [NestedTypeDescriptor] tree from a seed JSON map.
  ///
  /// The JSON schema mirrors [FieldDescriptor] and [TypeDescriptor]:
  ///
  /// ```json
  /// {
  ///   "typeName": "geo-location",
  ///   "displayName": "Geo Location",
  ///   "iconName": "public",
  ///   "fields": [
  ///     {"key": "timestamp", "label": "Timestamp", "type": "date"},
  ///     {
  ///       "key": "referenceFrame",
  ///       "label": "Reference Frame",
  ///       "type": "nested",
  ///       "nestedFields": [
  ///         {"key": "astronomical-body", "label": "Body", "type": "string"}
  ///       ]
  ///     }
  ///   ],
  ///   "childTypes": [],
  ///   "relatedTypes": [],
  ///   "parentTypes": []
  /// }
  /// ```
  ///
  /// Fields with `"type": "nested"` must supply a `"nestedFields"` array.
  /// Nesting is recursive — nested fields may themselves contain further
  /// `"type": "nested"` entries.
  ///
  /// Returns a fully constructed tree. All [List] and [Map] parameters default
  /// to empty when absent from the JSON — this method never throws on missing
  /// optional fields.
  factory NestedTypeDescriptor.fromJson(Map<String, dynamic> json) {
    return NestedTypeDescriptor(
      typeName: json['typeName'] as String,
      displayName: (json['displayName'] as String?) ?? json['typeName'] as String,
      iconName: (json['iconName'] as String?) ?? 'help_outline',
      fields: _parseFieldList(json['fields']),
      childTypes: _parseTypeRelations(json['childTypes']),
      relatedTypes: _parseTypeRelations(json['relatedTypes']),
      parentTypes: _parseTypeRelations(json['parentTypes']),
    );
  }

  /// Recursively flattens this type's field hierarchy into a single flat
  /// `List<FieldDescriptor>`.
  ///
  /// Scalar fields are included as-is (their keys unchanged). Nested fields
  /// are unwrapped: each descendant [FieldDescriptor] receives a dotted key
  /// (e.g. `referenceFrame.astronomical-body`) and a [FieldDescriptor.sectionLabel]
  /// matching the parent nested field's [FieldDescriptor.label], so the
  /// [PropertyGrid] groups them into titled sections automatically.
  ///
  /// Nested fields more than one level deep receive the label of their
  /// immediate parent as the section label.
  ///
  /// Example:
  /// ```dart
  /// final type = NestedTypeDescriptor.fromJson(geoLocationJson);
  /// final flat = type.flatten();
  /// // flat contains "timestamp", "referenceFrame.astronomical-body" (section
  /// // label "Reference Frame"), "referenceFrame.geodeticSystem.geodetic-datum"
  /// // (section label "Geodetic System"), etc.
  /// ```
  List<FieldDescriptor> flatten() {
    return _flattenRecursive(fields, '', null);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Parses a JSON array of field maps into [FieldDescriptor] instances.
  ///
  /// Recurses into `"nested"` entries to produce [NestedFieldDescriptor] trees.
  static List<FieldDescriptor> _parseFieldList(dynamic fieldListJson) {
    if (fieldListJson == null) return [];
    final list = fieldListJson as List<dynamic>;
    return list
        .map((e) => _parseField(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Parses a single JSON field map into a [FieldDescriptor] or
  /// [NestedFieldDescriptor].
  static FieldDescriptor _parseField(Map<String, dynamic> json) {
    final type = json['type'] as String;
    if (type == 'nested') {
      return NestedFieldDescriptor(
        key: json['key'] as String,
        label: (json['label'] as String?) ?? json['key'] as String,
        nestedFields: _parseFieldList(json['nestedFields']),
        sectionLabel: json['sectionLabel'] as String?,
        sectionOrder: (json['sectionOrder'] as num?)?.toInt() ?? 0,
      );
    }
    return FieldDescriptor(
      key: json['key'] as String,
      label: (json['label'] as String?) ?? json['key'] as String,
      type: type,
      sectionLabel: json['sectionLabel'] as String?,
      sectionOrder: (json['sectionOrder'] as num?)?.toInt() ?? 0,
      required: json['required'] as bool? ?? false,
      minValue: json['minValue'] as num?,
      maxValue: json['maxValue'] as num?,
      pattern: json['pattern'] as String?,
      enumOptions: (json['enumOptions'] as List<dynamic>?)?.cast<String>(),
      enumDisplayNames:
          (json['enumDisplayNames'] as List<dynamic>?)?.cast<String>(),
      defaultValue: json['defaultValue'],
      inputFormatters:
          (json['inputFormatters'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Parses a JSON array of type relation maps.
  static List<TypeRelationDescriptor> _parseTypeRelations(dynamic jsonList) {
    if (jsonList == null) return [];
    final list = jsonList as List<dynamic>;
    return list
        .map((e) {
          final m = e as Map<String, dynamic>;
          return TypeRelationDescriptor(
            relationName: (m['relationName'] as String?) ?? '',
            childTypeName: m['childTypeName'] as String,
            childLabel: (m['childLabel'] as String?) ?? m['childTypeName'] as String,
          );
        })
        .toList(growable: false);
  }

  /// Recursively flattens [fields] into a flat list, prepending [keyPrefix]
  /// to each key and applying [parentSectionLabel] as the section label when
  /// the field does not already carry one.
  static List<FieldDescriptor> _flattenRecursive(
    List<FieldDescriptor> fields,
    String keyPrefix,
    String? parentSectionLabel,
  ) {
    final result = <FieldDescriptor>[];
    for (final field in fields) {
      final prefixedKey =
          keyPrefix.isEmpty ? field.key : '$keyPrefix.${field.key}';
      final effectiveSection = field.sectionLabel ?? parentSectionLabel;

      if (field is NestedFieldDescriptor) {
        result.addAll(_flattenRecursive(
          field.nestedFields,
          prefixedKey,
          field.label,
        ));
      } else {
        result.add(FieldDescriptor(
          key: prefixedKey,
          label: field.label,
          type: field.type,
          sectionLabel: effectiveSection,
          sectionOrder: field.sectionOrder,
          required: field.required,
          minValue: field.minValue,
          maxValue: field.maxValue,
          pattern: field.pattern,
          enumOptions: field.enumOptions,
          enumDisplayNames: field.enumDisplayNames,
          defaultValue: field.defaultValue,
          inputFormatters: field.inputFormatters,
        ));
      }
    }
    return result;
  }
}
