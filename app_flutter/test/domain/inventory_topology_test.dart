import 'package:app_flutter/domain/inventory_topology.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InventoryTopologyNetworkType', () {
    test('should have identity name "inventory-topology"', () {
      const networkType = InventoryTopologyNetworkType(isPresent: true);
      expect(InventoryTopologyNetworkType.identityName, 'inventory-topology');
      expect(networkType.isPresent, isTrue);
    });
  });

  group('NodeInventoryMapping', () {
    test('should be mapped when neRef is present', () {
      const mapping = NodeInventoryMapping(neRef: 'example:NE-SW1');
      expect(mapping.neRef, equals('example:NE-SW1'));
      expect(mapping.isMapped(), isTrue);
    });

    test('should not be mapped when neRef is null', () {
      const mapping = NodeInventoryMapping();
      expect(mapping.neRef, isNull);
      expect(mapping.isMapped(), isFalse);
    });
  });

  group('LinkInventoryMedia', () {
    test('should record unknown classification when link type is "unknown"', () {
      const media = LinkInventoryMedia(linkType: 'unknown');
      expect(media.linkType, equals('unknown'));
      expect(media.isClassified(), isTrue);
      expect(media.isUnknown, isTrue);
      expect(media.isUnassessed, isFalse);
    });

    test('should be unassessed when link type is null', () {
      const media = LinkInventoryMedia();
      expect(media.linkType, isNull);
      expect(media.isClassified(), isFalse);
      expect(media.isUnknown, isFalse);
      expect(media.isUnassessed, isTrue);
    });

    test('should accept "fiber" when link type is from extensible registry', () {
      const media = LinkInventoryMedia(linkType: 'fiber');
      expect(media.linkType, equals('fiber'));
      expect(media.isClassified(), isTrue);
      expect(LinkInventoryMedia.validLinkTypes.contains('fiber'), isTrue);
    });

    test('should be semantically distinct when unassessed vs unknown', () {
      const unassessed = LinkInventoryMedia();
      const unknown = LinkInventoryMedia(linkType: 'unknown');
      expect(unassessed.isClassified(), isFalse);
      expect(unknown.isClassified(), isTrue);
      expect(unassessed, isNot(equals(unknown)));
    });
  });

  group('TpInventoryMapping', () {
    test('should be mapped when neRef is set', () {
      const mapping = TpInventoryMapping(neRef: 'example:NE-SW1');
      expect(mapping.isMapped(), isTrue);
    });

    test('should be mapped when portRef is set', () {
      const mapping = TpInventoryMapping(portRef: 'example:eth-port-1');
      expect(mapping.isMapped(), isTrue);
    });

    test('should not be mapped when both refs are null', () {
      const mapping = TpInventoryMapping();
      expect(mapping.neRef, isNull);
      expect(mapping.portRef, isNull);
      expect(mapping.isMapped(), isFalse);
    });
  });

  group('PortBreakout', () {
    test('should be channelized when breakout capable with channel count', () {
      const breakout = PortBreakout(isBreakoutCapable: true, channelCount: 4);
      expect(breakout.isBreakoutCapable, isTrue);
      expect(breakout.channelCount, equals(4));
      expect(breakout.isChannelized(), isTrue);
    });

    test('should not be channelized when breakout capable but no channels', () {
      const breakout = PortBreakout(isBreakoutCapable: true, channelCount: 0);
      expect(breakout.isBreakoutCapable, isTrue);
      expect(breakout.isChannelized(), isFalse);

      const notCapable = PortBreakout();
      expect(notCapable.isBreakoutCapable, isFalse);
      expect(notCapable.isChannelized(), isFalse);
    });
  });
}
