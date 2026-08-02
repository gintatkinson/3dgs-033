import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Thrown when an inventory topology type has an invalid identity.
@immutable
class TopologyIdentityError implements Exception {
  final String message;
  const TopologyIdentityError(this.message);

  @override
  String toString() => 'TopologyIdentityError: $message';
}

/// Thrown when a port breakout configuration is invalid.
@immutable
class BreakoutConfigError implements Exception {
  final String message;
  const BreakoutConfigError(this.message);

  @override
  String toString() => 'BreakoutConfigError: $message';
}

/// Represents the inventory topology network type as defined in UML::InventoryTopologyNetworkType.
@immutable
@realizes(r'UML::InventoryTopologyNetworkType')
class InventoryTopologyNetworkType {
  static const String identityName = 'inventory-topology';
  final bool isPresent;

  const InventoryTopologyNetworkType({this.isPresent = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryTopologyNetworkType && other.isPresent == isPresent;

  @override
  int get hashCode => isPresent.hashCode;

  @override
  String toString() => 'InventoryTopologyNetworkType(isPresent: $isPresent)';
}

/// Represents a mapping from a topology node to a network element as defined in UML::NodeInventoryMapping.
@immutable
@realizes(r'UML::NodeInventoryMapping')
class NodeInventoryMapping {
  final String? neRef;

  const NodeInventoryMapping({this.neRef});

  bool isMapped() => neRef != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeInventoryMapping && other.neRef == neRef;

  @override
  int get hashCode => neRef.hashCode;

  @override
  String toString() => 'NodeInventoryMapping(neRef: $neRef)';
}

/// Represents the link inventory media classification as defined in UML::LinkInventoryMedia.
@immutable
@realizes(r'UML::LinkInventoryMedia')
class LinkInventoryMedia {
  final String? linkType;

  static const Set<String> validLinkTypes = {
    'unknown',
    'copper',
    'fiber',
    'coax',
    'microwave',
    'wlan',
    'leased-fiber',
  };

  const LinkInventoryMedia({this.linkType});

  bool isClassified() => linkType != null;

  bool get isUnknown => linkType == 'unknown';

  bool get isUnassessed => linkType == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkInventoryMedia && other.linkType == linkType;

  @override
  int get hashCode => linkType.hashCode;

  @override
  String toString() => 'LinkInventoryMedia(linkType: $linkType)';
}

/// Represents a mapping from a topology termination point to inventory as defined in UML::TpInventoryMapping.
@immutable
@realizes(r'UML::TpInventoryMapping')
class TpInventoryMapping {
  final String? neRef;
  final String? portRef;

  const TpInventoryMapping({this.neRef, this.portRef});

  bool isMapped() => neRef != null || portRef != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TpInventoryMapping &&
          other.neRef == neRef &&
          other.portRef == portRef;

  @override
  int get hashCode => Object.hash(neRef, portRef);

  @override
  String toString() =>
      'TpInventoryMapping(neRef: $neRef, portRef: $portRef)';
}

/// Represents a port breakout configuration as defined in UML::PortBreakout.
@immutable
@realizes(r'UML::PortBreakout')
class PortBreakout {
  final bool isBreakoutCapable;
  final int? channelCount;

  const PortBreakout({this.isBreakoutCapable = false, this.channelCount});

  bool isChannelized() =>
      isBreakoutCapable && channelCount != null && channelCount! > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortBreakout &&
          other.isBreakoutCapable == isBreakoutCapable &&
          other.channelCount == channelCount;

  @override
  int get hashCode => Object.hash(isBreakoutCapable, channelCount);

  @override
  String toString() =>
      'PortBreakout(isBreakoutCapable: $isBreakoutCapable, channelCount: $channelCount)';
}
