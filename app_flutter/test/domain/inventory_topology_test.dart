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

    /// @traces US-41
    test('should expose channel count as read-only hardware capability', () {
      const dr4 = PortBreakout(isBreakoutCapable: true, channelCount: 4);
      expect(dr4.isBreakoutCapable, isTrue);
      expect(dr4.channelCount, equals(4));

      const sfp = PortBreakout();
      expect(sfp.isBreakoutCapable, isFalse);
      expect(sfp.channelCount, isNull);
    });

    /// @traces US-41
    test('should retain breakout hardware capability regardless of configuration', () {
      const trunkMode = PortBreakout(isBreakoutCapable: true, channelCount: 4);
      expect(trunkMode.isBreakoutCapable, isTrue);
      expect(trunkMode.channelCount, equals(4));

      const breakoutMode = PortBreakout(isBreakoutCapable: true, channelCount: 4);
      expect(breakoutMode.isBreakoutCapable, isTrue);
      expect(breakoutMode.channelCount, equals(4));
    });

    /// @traces US-42
    group('canAssignChannel', () {
      test('should allow assignment when channel is free', () {
        const breakout = PortBreakout(isBreakoutCapable: true, channelCount: 4);
        expect(breakout.canAssignChannel(1, const {}), isTrue);
      });

      test('should reject assignment when channel is already allocated', () {
        const breakout = PortBreakout(isBreakoutCapable: true, channelCount: 4);
        expect(breakout.canAssignChannel(1, const {1, 2}), isFalse);
      });

      test('should reject assignment when channelId is out of bounds', () {
        const breakout = PortBreakout(isBreakoutCapable: true, channelCount: 4);
        expect(breakout.canAssignChannel(5, const {}), isFalse);
        expect(breakout.canAssignChannel(0, const {}), isFalse);
      });

      test('should reject assignment when port is not breakout capable', () {
        const breakout = PortBreakout();
        expect(breakout.canAssignChannel(1, const {}), isFalse);
      });

      test('should allow reassignment after channel is released', () {
        const breakout = PortBreakout(isBreakoutCapable: true, channelCount: 4);
        const initiallyAllocated = {1};
        expect(breakout.canAssignChannel(1, initiallyAllocated), isFalse);
        const released = <int>{};
        expect(breakout.canAssignChannel(1, released), isTrue);
      });

      test('should enforce all channels exclusive when fully allocated', () {
        const breakout = PortBreakout(isBreakoutCapable: true, channelCount: 4);
        const allAllocated = {1, 2, 3, 4};
        for (var i = 1; i <= 4; i++) {
          expect(breakout.canAssignChannel(i, allAllocated), isFalse);
        }
      });
    });
  });
}
