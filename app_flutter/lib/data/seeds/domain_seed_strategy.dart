import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/data/database_initializer.dart';

/// Concrete implementation of [SeedStrategy] that seeds the database with domain-specific mock data.
///
/// This includes base type definitions, attributes, space nodes, real NTT exchanges,
/// cable landing stations, and their interconnectivity links.
class DomainSeedStrategy implements SeedStrategy {
  
  /// Seeds the database by batch-inserting default schemas, nodes, and instances.
  ///
  /// Assumes the database tables have been successfully created by [DatabaseInitializer].
  @override
  Future<void> seed(Database db) async {
    final batch = db.batch();

    final spaceDetails = ['Components', 'Telemetry', 'Logs', 'Links'];
    final nttDetails = ['Components', 'Alarms', 'Links'];
    final landingDetails = ['Components', 'Links'];

    final displayNames = {
      'Components': 'Components',
      'Telemetry': 'Telemetry',
      'Logs': 'Logs',
      'Alarms': 'Alarms',
      'Links': 'Links',
    };

    // 1. Seed base system type definitions and their 50 generic attributes
    for (final d in displayNames.keys) {
      batch.insert('type_definitions', {
        'type_name': d,
        'display_name': displayNames[d] ?? d,
        'icon_name': 'widgets',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      for (int i = 1; i <= 50; i++) {
        batch.insert('type_attributes', {
          'type_name': d,
          'attr_key': 'field_$i',
          'label': 'Field $i',
          'attr_type': 'string',
          'section_label': 'General',
          'section_order': 0,
          'is_required': 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }

    // Register Counter32 as a visible domain type in the PropertyGrid
    batch.insert('type_definitions', {
      'type_name': 'Counter32',
      'display_name': 'Counter 32',
      'icon_name': 'plus_one',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Counter32',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'int',
      'section_label': 'Counter',
      'section_order': 0,
      'is_required': 1,
      'min_value': 0,
      'max_value': 4294967295,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Counter32',
      'attr_key': 'hasWrapped',
      'label': 'Has Wrapped',
      'attr_type': 'enum',
      'section_label': 'Counter',
      'section_order': 1,
      'is_required': 0,
      'enum_options': jsonEncode(['true', 'false']),
      'enum_display_names': jsonEncode(['Yes', 'No']),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'Counter32',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'Counter32',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': 0, 'hasWrapped': 'false'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // OID
    batch.insert('type_definitions', {
      'type_name': 'OID',
      'display_name': 'OID',
      'icon_name': 'tag',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'OID',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'string',
      'section_label': 'OID',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'OID',
      'attr_key': 'subIdentifierCount',
      'label': 'Sub Identifier Count',
      'attr_type': 'int',
      'section_label': 'OID',
      'section_order': 1,
      'is_required': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'OID',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'OID',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': '1.3.6.1.2.1.1', 'subIdentifierCount': 7}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Gauge32
    batch.insert('type_definitions', {
      'type_name': 'Gauge32',
      'display_name': 'Gauge 32',
      'icon_name': 'speed',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Gauge32',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'int',
      'section_label': 'Gauge',
      'section_order': 0,
      'is_required': 1,
      'min_value': 0,
      'max_value': 4294967295,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Gauge32',
      'attr_key': 'isSaturated',
      'label': 'Is Saturated',
      'attr_type': 'enum',
      'section_label': 'Gauge',
      'section_order': 1,
      'is_required': 0,
      'enum_options': jsonEncode(['true', 'false']),
      'enum_display_names': jsonEncode(['Yes', 'No']),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'Gauge32',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'Gauge32',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': 1000, 'isSaturated': 'false'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // YangDateTime
    batch.insert('type_definitions', {
      'type_name': 'YangDateTime',
      'display_name': 'Yang Date Time',
      'icon_name': 'schedule',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'YangDateTime',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'string',
      'section_label': 'Date Time',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'YangDateTime',
      'attr_key': 'timezone',
      'label': 'Time Zone',
      'attr_type': 'string',
      'section_label': 'Date Time',
      'section_order': 1,
      'is_required': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'YangDateTime',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'YangDateTime',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': '2025-01-15T10:30:00Z', 'timezone': 'UTC'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Hours32
    batch.insert('type_definitions', {
      'type_name': 'Hours32',
      'display_name': 'Hours 32',
      'icon_name': 'timelapse',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Hours32',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'int',
      'section_label': 'Hours',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Hours32',
      'attr_key': 'secondsEquivalent',
      'label': 'Seconds Equivalent',
      'attr_type': 'int',
      'section_label': 'Hours',
      'section_order': 1,
      'is_required': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'Hours32',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'Hours32',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': 48, 'secondsEquivalent': 172800}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // TimeTicks
    batch.insert('type_definitions', {
      'type_name': 'TimeTicks',
      'display_name': 'Time Ticks',
      'icon_name': 'timer',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'TimeTicks',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'int',
      'section_label': 'Time Ticks',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'TimeTicks',
      'attr_key': 'duration',
      'label': 'Duration',
      'attr_type': 'string',
      'section_label': 'Time Ticks',
      'section_order': 1,
      'is_required': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'TimeTicks',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'TimeTicks',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': 360000, 'duration': '1 hour 0 minutes'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // MacAddress
    batch.insert('type_definitions', {
      'type_name': 'MacAddress',
      'display_name': 'MAC Address',
      'icon_name': 'lan',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'MacAddress',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'string',
      'section_label': 'MAC',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'MacAddress',
      'attr_key': 'isLocal',
      'label': 'Is Local',
      'attr_type': 'enum',
      'section_label': 'MAC',
      'section_order': 1,
      'is_required': 0,
      'enum_options': jsonEncode(['true', 'false']),
      'enum_display_names': jsonEncode(['Yes', 'No']),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'MacAddress',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'MacAddress',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': '00:1A:2B:3C:4D:5E', 'isLocal': 'false'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // IpVersion
    batch.insert('type_definitions', {
      'type_name': 'IpVersion',
      'display_name': 'IP Version',
      'icon_name': 'settings_ethernet',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'IpVersion',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'enum',
      'section_label': 'IP Version',
      'section_order': 0,
      'is_required': 1,
      'enum_options': jsonEncode(['unknown', 'ipv4', 'ipv6']),
      'enum_display_names': jsonEncode(['Unknown', 'IPv4', 'IPv6']),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'IpVersion',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'IpVersion',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': 'ipv4'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // PortNumber
    batch.insert('type_definitions', {
      'type_name': 'PortNumber',
      'display_name': 'Port Number',
      'icon_name': 'settings_input_component',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'PortNumber',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'int',
      'section_label': 'Port',
      'section_order': 0,
      'is_required': 1,
      'min_value': 0,
      'max_value': 65535,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'PortNumber',
      'attr_key': 'serviceName',
      'label': 'Service Name',
      'attr_type': 'string',
      'section_label': 'Port',
      'section_order': 1,
      'is_required': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'PortNumber',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'PortNumber',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': 443, 'serviceName': 'HTTPS'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // AsNumber
    batch.insert('type_definitions', {
      'type_name': 'AsNumber',
      'display_name': 'AS Number',
      'icon_name': 'router',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'AsNumber',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'int',
      'section_label': 'AS',
      'section_order': 0,
      'is_required': 1,
      'min_value': 0,
      'max_value': 4294967295,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'AsNumber',
      'attr_key': 'isPrivate',
      'label': 'Is Private',
      'attr_type': 'enum',
      'section_label': 'AS',
      'section_order': 1,
      'is_required': 0,
      'enum_options': jsonEncode(['true', 'false']),
      'enum_display_names': jsonEncode(['Yes', 'No']),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'AsNumber',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'AsNumber',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': 64512, 'isPrivate': 'true'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Ipv4Address
    batch.insert('type_definitions', {
      'type_name': 'Ipv4Address',
      'display_name': 'IPv4 Address',
      'icon_name': 'language',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Ipv4Address',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'string',
      'section_label': 'IPv4',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Ipv4Address',
      'attr_key': 'isPrivate',
      'label': 'Is Private',
      'attr_type': 'enum',
      'section_label': 'IPv4',
      'section_order': 1,
      'is_required': 0,
      'enum_options': jsonEncode(['true', 'false']),
      'enum_display_names': jsonEncode(['Yes', 'No']),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'Ipv4Address',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'Ipv4Address',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': '192.168.1.1', 'isPrivate': 'true'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Ipv6Address
    batch.insert('type_definitions', {
      'type_name': 'Ipv6Address',
      'display_name': 'IPv6 Address',
      'icon_name': 'language',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Ipv6Address',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'string',
      'section_label': 'IPv6',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Ipv6Address',
      'attr_key': 'isLinkLocal',
      'label': 'Is Link Local',
      'attr_type': 'enum',
      'section_label': 'IPv6',
      'section_order': 1,
      'is_required': 0,
      'enum_options': jsonEncode(['true', 'false']),
      'enum_display_names': jsonEncode(['Yes', 'No']),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'Ipv6Address',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'Ipv6Address',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': 'fe80::1', 'isLinkLocal': 'true'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Ipv4Prefix
    batch.insert('type_definitions', {
      'type_name': 'Ipv4Prefix',
      'display_name': 'IPv4 Prefix',
      'icon_name': 'filter_none',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Ipv4Prefix',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'string',
      'section_label': 'Prefix',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Ipv4Prefix',
      'attr_key': 'prefixLength',
      'label': 'Prefix Length',
      'attr_type': 'int',
      'section_label': 'Prefix',
      'section_order': 1,
      'is_required': 0,
      'min_value': 0,
      'max_value': 32,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'Ipv4Prefix',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'Ipv4Prefix',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': '192.168.0.0', 'prefixLength': 16}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // DomainName
    batch.insert('type_definitions', {
      'type_name': 'DomainName',
      'display_name': 'Domain Name',
      'icon_name': 'public',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'DomainName',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'string',
      'section_label': 'Domain',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'DomainName',
      'attr_key': 'isFqdn',
      'label': 'Is FQDN',
      'attr_type': 'enum',
      'section_label': 'Domain',
      'section_order': 1,
      'is_required': 0,
      'enum_options': jsonEncode(['true', 'false']),
      'enum_display_names': jsonEncode(['Yes', 'No']),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'DomainName',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'DomainName',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': 'example.com', 'isFqdn': 'true'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Uri
    batch.insert('type_definitions', {
      'type_name': 'Uri',
      'display_name': 'URI',
      'icon_name': 'link',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Uri',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'string',
      'section_label': 'URI',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Uri',
      'attr_key': 'scheme',
      'label': 'Scheme',
      'attr_type': 'string',
      'section_label': 'URI',
      'section_order': 1,
      'is_required': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'Uri',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'Uri',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': 'https://example.com/api', 'scheme': 'https'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // EmailAddress
    batch.insert('type_definitions', {
      'type_name': 'EmailAddress',
      'display_name': 'Email Address',
      'icon_name': 'email',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'EmailAddress',
      'attr_key': 'value',
      'label': 'Value',
      'attr_type': 'string',
      'section_label': 'Email',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'EmailAddress',
      'attr_key': 'domain',
      'label': 'Domain',
      'attr_type': 'string',
      'section_label': 'Email',
      'section_order': 1,
      'is_required': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'EmailAddress',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'EmailAddress',
      'parent_node_id': null,
      'data_json': jsonEncode({'value': 'admin@example.com', 'domain': 'example.com'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // GeoLocation
    batch.insert('type_definitions', {
      'type_name': 'GeoLocation',
      'display_name': 'Geo Location',
      'icon_name': 'location_on',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'GeoLocation',
      'attr_key': 'timestamp',
      'label': 'Timestamp',
      'attr_type': 'string',
      'section_label': 'Geo',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'GeoLocation',
      'attr_key': 'validUntil',
      'label': 'Valid Until',
      'attr_type': 'string',
      'section_label': 'Geo',
      'section_order': 1,
      'is_required': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'GeoLocation',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'GeoLocation',
      'parent_node_id': null,
      'data_json': jsonEncode({'timestamp': '2025-01-15T10:30:00Z', 'validUntil': '2025-12-31T23:59:59Z'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // ReferenceFrame
    batch.insert('type_definitions', {
      'type_name': 'ReferenceFrame',
      'display_name': 'Reference Frame',
      'icon_name': 'gps_fixed',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'ReferenceFrame',
      'attr_key': 'astronomicalBody',
      'label': 'Astronomical Body',
      'attr_type': 'string',
      'section_label': 'Reference',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'ReferenceFrame',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'ReferenceFrame',
      'parent_node_id': null,
      'data_json': jsonEncode({'astronomicalBody': 'earth'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // GeodeticSystem
    batch.insert('type_definitions', {
      'type_name': 'GeodeticSystem',
      'display_name': 'Geodetic System',
      'icon_name': 'terrain',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'GeodeticSystem',
      'attr_key': 'geodeticDatum',
      'label': 'Geodetic Datum',
      'attr_type': 'string',
      'section_label': 'Geodetic',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'GeodeticSystem',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'GeodeticSystem',
      'parent_node_id': null,
      'data_json': jsonEncode({'geodeticDatum': 'wgs-84'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Velocity
    batch.insert('type_definitions', {
      'type_name': 'Velocity',
      'display_name': 'Velocity',
      'icon_name': 'trending_up',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Velocity',
      'attr_key': 'vNorth',
      'label': 'V North',
      'attr_type': 'real',
      'section_label': 'Velocity',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Velocity',
      'attr_key': 'vEast',
      'label': 'V East',
      'attr_type': 'real',
      'section_label': 'Velocity',
      'section_order': 1,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Velocity',
      'attr_key': 'speed',
      'label': 'Speed',
      'attr_type': 'real',
      'section_label': 'Velocity',
      'section_order': 2,
      'is_required': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'Velocity',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'Velocity',
      'parent_node_id': null,
      'data_json': jsonEncode({'vNorth': 10.5, 'vEast': 20.3, 'speed': 22.84}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // EllipsoidCoordinate
    batch.insert('type_definitions', {
      'type_name': 'EllipsoidCoordinate',
      'display_name': 'Ellipsoid Coordinate',
      'icon_name': 'explore',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'EllipsoidCoordinate',
      'attr_key': 'latitude',
      'label': 'Latitude',
      'attr_type': 'real',
      'section_label': 'Coordinate',
      'section_order': 0,
      'is_required': 1,
      'min_value': -90,
      'max_value': 90,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'EllipsoidCoordinate',
      'attr_key': 'longitude',
      'label': 'Longitude',
      'attr_type': 'real',
      'section_label': 'Coordinate',
      'section_order': 1,
      'is_required': 1,
      'min_value': -180,
      'max_value': 180,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'EllipsoidCoordinate',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'EllipsoidCoordinate',
      'parent_node_id': null,
      'data_json': jsonEncode({'latitude': 35.6762, 'longitude': 139.6503}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // NetworkElement
    batch.insert('type_definitions', {
      'type_name': 'NetworkElement',
      'display_name': 'Network Element',
      'icon_name': 'device_hub',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'NetworkElement',
      'attr_key': 'neId',
      'label': 'NE ID',
      'attr_type': 'string',
      'section_label': 'Network',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'NetworkElement',
      'attr_key': 'neType',
      'label': 'NE Type',
      'attr_type': 'string',
      'section_label': 'Network',
      'section_order': 1,
      'is_required': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'NetworkElement',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'NetworkElement',
      'parent_node_id': null,
      'data_json': jsonEncode({'neId': 'NE-001', 'neType': 'Router'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Component
    batch.insert('type_definitions', {
      'type_name': 'Component',
      'display_name': 'Component',
      'icon_name': 'memory',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Component',
      'attr_key': 'componentId',
      'label': 'Component ID',
      'attr_type': 'string',
      'section_label': 'Component',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Component',
      'attr_key': 'isFru',
      'label': 'Is FRU',
      'attr_type': 'enum',
      'section_label': 'Component',
      'section_order': 1,
      'is_required': 0,
      'enum_options': jsonEncode(['true', 'false']),
      'enum_display_names': jsonEncode(['Yes', 'No']),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'Component',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'Component',
      'parent_node_id': null,
      'data_json': jsonEncode({'componentId': 'COMP-001', 'isFru': 'true'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Rack
    batch.insert('type_definitions', {
      'type_name': 'Rack',
      'display_name': 'Rack',
      'icon_name': 'dns',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Rack',
      'attr_key': 'id',
      'label': 'ID',
      'attr_type': 'string',
      'section_label': 'Rack',
      'section_order': 0,
      'is_required': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_attributes', {
      'type_name': 'Rack',
      'attr_key': 'rackClass',
      'label': 'Rack Class',
      'attr_type': 'enum',
      'section_label': 'Rack',
      'section_order': 1,
      'is_required': 0,
      'enum_options': jsonEncode(['standard', 'secure-baseline', 'secure-medium', 'secure-high']),
      'enum_display_names': jsonEncode(['Standard', 'Secure Baseline', 'Secure Medium', 'Secure High']),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('type_relations', {
      'parent_type_name': 'Rack',
      'relation_name': 'has_component',
      'child_type_name': 'Components',
      'child_label': 'Components',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert('properties', {
      'node_id': 'Rack',
      'parent_node_id': null,
      'data_json': jsonEncode({'id': 'RACK-001', 'rackClass': 'standard'}),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // 2. Generate 100 space orbit telemetry nodes
    final spaceNodes = <String>[];
    for (int i = 0; i < 100; i++) {
      final id = 'space_$i';
      spaceNodes.add(id);
      final lat = 25.0 + (i / 100.0) * 20.0;
      final lon = 125.0 + (i % 20) * 1.0;
      _addNodeToBatch(batch, id, null, spaceDetails, lat: lat, lon: lon, height: 500000.0);
    }

    // 3. Load and parse real NTT exchanges data from assets
    final nttFile = File('assets/ntt_exchanges_japan_763.json');
    String nttJsonString;
    if (await nttFile.exists()) {
      nttJsonString = await nttFile.readAsString();
    } else {
      nttJsonString = await rootBundle.loadString('assets/ntt_exchanges_japan_763.json');
    }
    final nttJson = jsonDecode(nttJsonString) as List;

    final nttNodes = <Map<String, dynamic>>[];
    for (int i = 0; i < nttJson.length; i++) {
      final item = nttJson[i];
      final lat = (item['latitude'] as num?)?.toDouble();
      final lon = (item['longitude'] as num?)?.toDouble();
      if (lat == null || lon == null) continue;
      final id = 'ntt_exchange_$i';
      nttNodes.add({'id': id, 'lat': lat, 'lon': lon});
      _addNodeToBatch(batch, id, null, nttDetails, lat: lat, lon: lon, height: 0.0);
    }

    // 4. Load and parse cable landing stations data from assets
    final landingFile = File('assets/cable_landing_stations_japan.json');
    String landingJsonString;
    if (await landingFile.exists()) {
      landingJsonString = await landingFile.readAsString();
    } else {
      landingJsonString = await rootBundle.loadString('assets/cable_landing_stations_japan.json');
    }
    final landingJson = jsonDecode(landingJsonString) as List;

    final landingNodes = <Map<String, dynamic>>[];
    for (int i = 0; i < landingJson.length; i++) {
      final item = landingJson[i];
      final lat = (item['latitude'] as num?)?.toDouble();
      final lon = (item['longitude'] as num?)?.toDouble();
      if (lat == null || lon == null) continue;
      final id = 'cable_landing_$i';
      landingNodes.add({'id': id, 'lat': lat, 'lon': lon});
      _addNodeToBatch(batch, id, null, landingDetails, lat: lat, lon: lon, height: 0.0);
    }

    // 5. Interconnect stations, exchanges, and orbits with interface links
    final Set<String> addedLinks = {};
    int linkIdCounter = 0;

    void addLink(String from, String to) {
      final key1 = '${from}_$to';
      final key2 = '${to}_$from';
      if (!addedLinks.contains(key1) && !addedLinks.contains(key2)) {
        addedLinks.add(key1);
        addedLinks.add(key2);
        batch.insert('instances', {
          'id': 'link_${linkIdCounter++}',
          'parent_node_id': from,
          'type_name': 'interface',
          'data_json': jsonEncode({'description': 'link to node $to'}),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }

    double distSq(double lat1, double lon1, double lat2, double lon2) {
      return (lat1 - lat2) * (lat1 - lat2) + (lon1 - lon2) * (lon1 - lon2);
    }

    for (int i = 0; i < nttNodes.length; i++) {
      final current = nttNodes[i];
      final distances = <Map<String, dynamic>>[];
      for (int j = 0; j < nttNodes.length; j++) {
        if (i == j) continue;
        final target = nttNodes[j];
        distances.add({
          'id': target['id'],
          'dist': distSq(
            current['lat'] as double,
            current['lon'] as double,
            target['lat'] as double,
            target['lon'] as double,
          ),
        });
      }
      distances.sort((a, b) => (a['dist'] as double).compareTo(b['dist'] as double));
      for (int k = 0; k < 2 && k < distances.length; k++) {
        addLink(current['id'] as String, distances[k]['id'] as String);
      }
      
      final space1 = spaceNodes[(i * 2) % 100];
      final space2 = spaceNodes[(i * 2 + 1) % 100];
      addLink(current['id'] as String, space1);
      addLink(current['id'] as String, space2);
    }

    for (int i = 0; i < landingNodes.length; i++) {
      final current = landingNodes[i];
      final distances = <Map<String, dynamic>>[];
      for (int j = 0; j < nttNodes.length; j++) {
        final target = nttNodes[j];
        distances.add({
          'id': target['id'],
          'dist': distSq(
            current['lat'] as double,
            current['lon'] as double,
            target['lat'] as double,
            target['lon'] as double,
          ),
        });
      }
      distances.sort((a, b) => (a['dist'] as double).compareTo(b['dist'] as double));
      for (int k = 0; k < 5 && k < distances.length; k++) {
        addLink(current['id'] as String, distances[k]['id'] as String);
      }
    }

    await batch.commit(noResult: true);
  }

  /// Helper helper to insert a complete node configuration (type_definition, relation, properties, and instances).
  void _addNodeToBatch(
    Batch batch,
    String node,
    String? parent,
    List<String> details, {
    required double lat,
    required double lon,
    required double height,
  }) {
    batch.insert('type_definitions', {
      'type_name': node,
      'display_name': node.replaceAll('_', ' '),
      'icon_name': 'insert_drive_file',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    for (final d in details) {
      batch.insert('type_relations', {
        'parent_type_name': node,
        'relation_name': 'contains',
        'child_type_name': d,
        'child_label': d == 'Components' ? 'Components' : d.replaceAll('_', ' ').split(' ').map((s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1)).join(' '),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    for (int i = 1; i <= 50; i++) {
      batch.insert('type_attributes', {
        'type_name': node,
        'attr_key': 'field_$i',
        'label': 'Field $i',
        'attr_type': 'string',
        'section_label': 'General',
        'section_order': 0,
        'is_required': 0,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    final propertiesMap = {
      for (int j = 1; j <= 50; j++) 'field_$j': 'val_${node}_field_$j',
      'location': {
        'ellipsoid': {
          'latitude': lat,
          'longitude': lon,
          'height': height,
        }
      }
    };
    batch.insert('properties', {
      'node_id': node,
      'parent_node_id': parent,
      'data_json': jsonEncode(propertiesMap),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    for (final d in details) {
      for (int k = 1; k <= 5; k++) {
        final instId = 'inst_${node}_${d}_$k';
        final instanceMap = {
          for (int j = 1; j <= 50; j++) 'field_$j': 'val_inst_${node}_${d}_${k}_field_$j'
        };
        batch.insert('instances', {
          'id': instId,
          'parent_node_id': node,
          'type_name': d,
          'data_json': jsonEncode(instanceMap),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
  }
}
