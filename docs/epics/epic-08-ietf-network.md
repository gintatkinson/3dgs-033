---
issue_id: 124
title: "ietf-network: Base Network Data Model"
type: "epic"
generation_mode: "subagent"
spec_source: "Project Constitution"
---

# Epic: ietf-network: Base Network Data Model

## 1. Context
This Epic covers the specification of the `ietf-network` YANG module defined in the IETF Network Topologies YANG Data Model specification. This is the foundational abstract (base) network data model that defines a common base for representing networks, their node inventories, and hierarchical network layering (network stacks). The module establishes the core abstraction: networks contain nodes; networks can be layered on top of supporting (underlay) networks; nodes can be mapped to supporting nodes in underlay networks.

The module defines two custom typedefs (`node-id` and `network-id`, both based on `inet:uri`), two reusable groupings (`network-ref` and `node-ref`), and the primary data tree rooted at the `networks` container with `network` list entries. The `network-types` container serves as an augmentation target for technology-specific network type classification.

This is the **base network module** upon which `ietf-network-topology` augments topology information (links, termination points). All technology-specific topology and inventory models ultimately build on this abstraction layer.

**Parent Epics:**
- [ ] #12 - [ietf-inet-types: Internet Protocol Suite Data Types](https://github.com/gintatkinson/3dgs-033/blob/main/docs/epics/epic-02-ietf-inet-types.md) (imported module providing `inet:uri` typedef used for node-id and network-id, RFC 6991)
- [ ] #11 - [ietf-yang-types: Core YANG Data Types](https://github.com/gintatkinson/3dgs-033/blob/main/docs/epics/epic-01-ietf-yang-types.md) (transitive import dependency via ietf-inet-types)

## 2. Requirements & Checklist
- [ ] #126 - [Define Networks Root Container](https://github.com/gintatkinson/3dgs-033/blob/main/docs/features/feat-38-networks-container.md) (YANG container nw:networks, top-level root for the network list, lines 119-121)
- [ ] #127 - [Define Network List Entry](https://github.com/gintatkinson/3dgs-033/blob/main/docs/features/feat-39-network-list.md) (YANG list nw:network keyed by network-id, contains network-types, supporting-network, and node children, lines 122-153)
- [ ] #128 - [Define Network Types Container](https://github.com/gintatkinson/3dgs-033/blob/main/docs/features/feat-40-network-types.md) (YANG container nw:network-types, augmentation target for network type classification, lines 134-139)
- [ ] #129 - [Define Supporting Network List](https://github.com/gintatkinson/3dgs-033/blob/main/docs/features/feat-41-supporting-network-list.md) (YANG list nw:supporting-network keyed by network-ref, underlay network layering hierarchy, lines 140-153)
- [ ] #130 - [Define Node List](https://github.com/gintatkinson/3dgs-033/blob/main/docs/features/feat-42-node-list.md) (YANG list nw:node keyed by node-id, inventory of nodes within a network, lines 155-164)
- [ ] #131 - [Define Supporting Node List](https://github.com/gintatkinson/3dgs-033/blob/main/docs/features/feat-43-supporting-node-list.md) (YANG list nw:supporting-node keyed by network-ref and node-ref, underlay node mapping hierarchy, lines 165-188)

### Associated Use Cases & User Stories

#### Associated Use Cases
- N/A — Use Cases are not generated for this phase

#### Associated User Stories
- N/A — User Stories are not generated for this phase

## 3. Architecture

### Subsystem Component Definition
The `ietf-network` module is the **Abstract Network Subsystem** that defines the foundational data model for network representation. It provides read-write (`config true`) containers for networks and nodes with hierarchical layering through supporting-network and supporting-node lists. The subsystem exports its data tree at `/nw:networks` and defines reusable groupings for cross-module referencing (`network-ref`, `node-ref`). It consumes the `ietf-inet-types` module for the `inet:uri` typedef used in its custom `network-id` and `node-id` types.

The subsystem is designed to be augmented by topology modules (adding links and termination points), inventory modules (adding device-specific node attributes), and technology-specific modules (adding network-type classifications and type-specific attributes).

### System-Level UML Class Diagram
```mermaid
classDiagram
    class IetfNetworkSubsystem {
        <<component>>
        +Boolean provideNetworksContainer() [1]
        +Boolean provideNetworkList() [1]
        +Boolean provideNetworkTypesAugmentationTarget() [1]
        +Boolean provideSupportingNetworkHierarchy() [1]
        +Boolean provideNodeInventory() [1]
        +Boolean provideSupportingNodeMapping() [1]
    }
    class Networks {
        <<container>>
    }
    class Network {
        <<list>>
        +String networkId "[1]"
    }
    class NetworkTypes {
        <<augmentation_target>>
    }
    class SupportingNetwork {
        <<list>>
        +String networkRef "[1]"
    }
    class Node {
        <<list>>
        +String nodeId "[1]"
    }
    class SupportingNode {
        <<list>>
        +String networkRef "[1]"
        +String nodeRef "[1]"
    }
    IetfNetworkSubsystem *-- Networks
    Networks *-- Network
    Network *-- NetworkTypes
    Network *-- SupportingNetwork
    Network *-- Node
    Node *-- SupportingNode
    SupportingNetwork --> Network : "references underlay network"
    SupportingNode --> Network : "references underlay network"
    SupportingNode --> Node : "references underlay node"
```

## State Machine Definitions

### System State Machine Diagram
```mermaid
stateDiagram-v2
    [*] --> EmptyDatastore
    EmptyDatastore --> NetworksInstantiated : create networks container
    NetworksInstantiated --> NetworkPopulated : create network entry
    NetworkPopulated --> NetworkLayered : add supporting-network
    NetworkPopulated --> NodeInventoried : add node
    NodeInventoried --> NodeMapped : add supporting-node
    NodeMapped --> NetworkLayered
    NetworkLayered --> NetworkReduced : delete supporting-network
    NetworkPopulated --> NetworkEmpty : delete last node
    NetworkEmpty --> NetworksInstantiated : delete network
    NetworksInstantiated --> EmptyDatastore : delete networks container
    note right of NodeInventoried : Node lifecycle within a network
    note right of NetworkLayered : Hierarchical layering established
```

## 4. Operational Considerations
The `ietf-network` module is designated as `config true` — all data is configuration data in the YANG schema. However, the distinction between configured (client-created) and system-controlled (discovered) data is provided through the NMDA datastores [RFC 8342]. Network data that is discovered is automatically populated as part of the operational state datastore (`<operational>`). Configured network data resides in the intended datastore (`<intended>`) and, when effective, is also reflected in the operational state datastore.

The use of `require-instance false` on all leafref paths means that dangling references (e.g., a supporting-network referencing a deleted underlay network) are tolerated in the intended datastore but excluded from the operational state datastore. Applications maintaining overlay networks must handle churn in underlay networks by monitoring operational state changes and updating references accordingly.

The module is designed for implementation as part of the ephemeral datastore, enabling configured overlay topologies to refer to discovered underlay topologies while maintaining referential integrity boundaries.

## 5. Security & Governance
- All data nodes are `config true` — write access to network topology data MUST be restricted to authorized management applications
- The `network-id` and `node-id` values are URIs that MAY contain sensitive organizational or topological information — access control SHOULD consider data sensitivity
- Supporting-network and supporting-node relationships expose cross-network dependencies that MAY reveal layering information across security domains — access control at the network level SHOULD restrict visibility of underlay dependencies
- Deletion of a network causes cascading removal of all child nodes, supporting-network entries, and augmented topology data — authorized clients MUST be aware of the blast radius
- Referential integrity violations (dangling leafrefs) result in automatic exclusion from operational state — applications SHOULD monitor for and resolve such conditions

## Specification Context
From the IETF Network Topologies YANG Data Model specification, Section 1 (Introduction):

"This document introduces an abstract (base) YANG data model to represent networks and topologies. The data model is divided into two parts: The first part of the data model defines a network data model that enables the definition of network hierarchies, or network stacks (i.e., networks that are layered on top of each other) and maintenance of an inventory of nodes contained in a network."

"The data model can be augmented to describe the specifics of particular types of networks and topologies. For example, an augmenting data model can provide network node information with attributes that are specific to a particular network type."

From the IETF Network Topologies YANG Data Model specification, Section 4.1 (Base Network Model):

"The abstract (base) network data model is defined in the 'ietf-network' module. Its structure is shown in Figure 4."

"Network data of a network at a particular layer can come into being in one of two ways: (1) the network data is configured by client applications -- for example, in the case of overlay networks that are configured by an SDN Controller application, or (2) the network data is automatically controlled by the system, in the case of networks that can be discovered. It is possible for a configured (overlay) network to refer to a (discovered) underlay network."

## 6. Source References
Structural Schema: [ietf-network@2018-02-26.yang](https://github.com/YangModels/yang/blob/main/standard/ietf/RFC/ietf-network%402018-02-26.yang) (Clause: 6.1)
Normative Specification: [the IETF Network Topologies YANG Data Model specification](https://datatracker.ietf.org/doc/rfc8345/) (Clause: 4.1)
