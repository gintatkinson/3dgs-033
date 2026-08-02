import 'package:app_flutter/domain/inventory_topology.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InventoryTopologyNetworkType', () {
    test('identity name is inventory-topology', () {
      const networkType = InventoryTopologyNetworkType(isPresent: true);
      expect(InventoryTopologyNetworkType.identityName, 'inventory-topology');
      expect(networkType.isPresent, isTrue);
    });
  });

  group('NodeInventoryMapping', () {
    test('isMapped true when neRef is present', () {
      const mapping = NodeInventoryMapping(neRef: 'example:NE-SW1');
      expect(mapping.neRef, equals('example:NE-SW1'));
      expect(mapping.isMapped(), isTrue);
    });

    test('isMapped false when neRef is null', () {
      const mapping = NodeInventoryMapping();
      expect(mapping.neRef, isNull);
      expect(mapping.isMapped(), isFalse);
    });
  });

  group('LinkInventoryMedia', () {
    test('unknown classification explicitly records unclassifiable medium', () {
      const media = LinkInventoryMedia(linkType: 'unknown');
      expect(media.linkType, equals('unknown'));
      expect(media.isClassified(), isTrue);
      expect(media.isUnknown, isTrue);
      expect(media.isUnassessed, isFalse);
    });

    test('unassessed classification means not yet assessed', () {
      const media = LinkInventoryMedia();
      expect(media.linkType, isNull);
      expect(media.isClassified(), isFalse);
      expect(media.isUnknown, isFalse);
      expect(media.isUnassessed, isTrue);
    });

    test('valid link type from extensible registry', () {
      const media = LinkInventoryMedia(linkType: 'fiber');
      expect(media.linkType, equals('fiber'));
      expect(media.isClassified(), isTrue);
      expect(LinkInventoryMedia.validLinkTypes.contains('fiber'), isTrue);
    });

    test('unassessed is semantically distinct from unknown', () {
      const unassessed = LinkInventoryMedia();
      const unknown = LinkInventoryMedia(linkType: 'unknown');
      expect(unassessed.isClassified(), isFalse);
      expect(unknown.isClassified(), isTrue);
      expect(unassessed, isNot(equals(unknown)));
    });
  });

  group('TpInventoryMapping', () {
    test('isMapped true when neRef is set', () {
      const mapping = TpInventoryMapping(neRef: 'example:NE-SW1');
      expect(mapping.isMapped(), isTrue);
    });

    test('isMapped true when portRef is set', () {
      const mapping = TpInventoryMapping(portRef: 'example:eth-port-1');
      expect(mapping.isMapped(), isTrue);
    });

    test('isMapped false when both refs are null', () {
      const mapping = TpInventoryMapping();
      expect(mapping.neRef, isNull);
      expect(mapping.portRef, isNull);
      expect(mapping.isMapped(), isFalse);
    });
  });

  group('PortBreakout', () {
    test('breakout capable with channel count', () {
      const breakout = PortBreakout(isBreakoutCapable: true, channelCount: 4);
      expect(breakout.isBreakoutCapable, isTrue);
      expect(breakout.channelCount, equals(4));
      expect(breakout.isChannelized(), isTrue);
    });

    test('not channelized when breakout capable but no channels', () {
      const breakout = PortBreakout(isBreakoutCapable: true, channelCount: 0);
      expect(breakout.isBreakoutCapable, isTrue);
      expect(breakout.isChannelized(), isFalse);

      const notCapable = PortBreakout();
      expect(notCapable.isBreakoutCapable, isFalse);
      expect(notCapable.isChannelized(), isFalse);
    });
  });
}
