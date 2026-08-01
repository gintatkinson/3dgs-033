---
title: "ietf-ni-location: Network Inventory Location"
issue_id: 49
type: "epic"
generation_mode: "subagent"
spec_source: "Project Constitution"
---

# Epic: ietf-ni-location: Network Inventory Location

## 1. Context
This Epic covers the specification of the `ietf-ni-location` YANG module defined in draft-ietf-ivy-network-inventory-location-06. This module augments the base `ietf-network-inventory` model (RFC AAAA) to enrich network elements with comprehensive location information. The module provides a read-only (`config false`) hierarchical location model supporting geographical locations (sites, buildings, equipment rooms), physical addresses with postal data, geodetic coordinates via RFC 9179's `ietf-geo-location` grouping, physical equipment racks with dimensional and electrical specifications, and rack positioning with grid coordinates. It also defines an extensible rack security classification identity hierarchy (`rack-class-type`) and a location reference typedef (`ni-location-ref`) for referential integrity between racks and locations. This is a functional module with four concrete containers: `locations`, `physical-address`, `racks`, and `rack-location`.

**Parent Epics:** [Parent Epic: ietf-network-inventory](https://github.com/gintatkinson/3dgs-033/blob/main/docs/epics/epic-05-ietf-network-inventory.md)
- [ ] #67 - [ietf-network-inventory: Base Network Inventory Data Model](https://github.com/gintatkinson/3dgs-033/blob/main/docs/epics/epic-05-ietf-network-inventory.md) (imported base module augmented via `/nwi:network-inventory`, draft-ietf-ivy-network-inventory-yang)
- [ ] #30 - [ietf-geo-location: Geographic Location Data Model](https://github.com/gintatkinson/3dgs-033/blob/main/docs/epics/epic-03-ietf-geo-location.md) (imported module providing `geo:geo-location` grouping, RFC 9179)
- [ ] #11 - [ietf-yang-types: Core YANG Data Types](https://github.com/gintatkinson/3dgs-033/blob/main/docs/epics/epic-01-ietf-yang-types.md) (imported module providing `yang:date-and-time` and `yang:uuid` types, RFC 9911)

## 2. Requirements & Checklist
- [ ] #45 - [Define Locations Container](https://github.com/gintatkinson/3dgs-033/blob/main/docs/features/feat-18-locations-container.md) (top-level augment container anchoring all location data, draft-ietf-ivy-network-inventory-location Section 2)
- [ ] #46 - [Define Physical Address](https://github.com/gintatkinson/3dgs-033/blob/main/docs/features/feat-19-physical-address.md) (nested container providing postal address with ISO ALPHA-2 country code pattern constraint, draft-ietf-ivy-network-inventory-location Section 2)
- [ ] #47 - [Define Racks Container](https://github.com/gintatkinson/3dgs-033/blob/main/docs/features/feat-20-racks-container.md) (container for physical equipment racks with dimensions, power specs, and extensible security classification, draft-ietf-ivy-network-inventory-location Section 3)
- [ ] #48 - [Define Rack Location](https://github.com/gintatkinson/3dgs-033/blob/main/docs/features/feat-21-rack-location.md) (nested container for rack positioning with location leafref and grid coordinates, draft-ietf-ivy-network-inventory-location Section 3)

### Associated Use Cases & User Stories

#### Associated Use Cases
- [ ] #60 - [Manage Hierarchical Network Inventory Locations](https://github.com/gintatkinson/3dgs-033/blob/main/docs/use-cases/uc-10-manage-hierarchical-locations.md) (Use Case for hierarchical location CRUD, Feature feat-18)
- [ ] #61 - [Manage Physical Address for Network Inventory Locations](https://github.com/gintatkinson/3dgs-033/blob/main/docs/use-cases/uc-11-manage-physical-address.md) (Use Case for physical address annotation, Feature feat-19)
- [ ] #63 - [Manage Physical Equipment Racks in Network Inventory](https://github.com/gintatkinson/3dgs-033/blob/main/docs/use-cases/uc-12-manage-equipment-racks.md) (Use Case for rack management, Feature feat-20)
- [ ] #62 - [Position Equipment Rack Within a Network Inventory Location](https://github.com/gintatkinson/3dgs-033/blob/main/docs/use-cases/uc-13-position-rack-within-location.md) (Use Case for rack-to-location positioning, Feature feat-21)

#### Associated User Stories
- [ ] #58 - [Validate Location Dispatch Readiness from Address, Geo-Location, and Validity Data](https://github.com/gintatkinson/3dgs-033/blob/main/docs/user-stories/us-16-validate-location-dispatch-readiness.md) (validates composite readiness from address/geo/validity, Features feat-18 and feat-19)
- [ ] #50 - [Expire Location Record at valid-until Temporal Boundary](https://github.com/gintatkinson/3dgs-033/blob/main/docs/user-stories/us-17-expire-location-valid-until.md) (validates temporal expiry lifecycle for locations, Feature feat-18)
- [ ] #51 - [Expire Rack Record at valid-until Temporal Boundary](https://github.com/gintatkinson/3dgs-033/blob/main/docs/user-stories/us-18-expire-rack-valid-until.md) (validates temporal expiry lifecycle for racks, Feature feat-20)
- [ ] #52 - [Validate Geographic Coordinate Ranges Against Bounded Constraints](https://github.com/gintatkinson/3dgs-033/blob/main/docs/user-stories/us-19-validate-geo-coordinate-ranges.md) (validates geodetic coordinate range constraints, Features feat-13 and feat-15)
- [ ] #53 - [Resolve Hierarchical Location Parent-Child Chain to Root](https://github.com/gintatkinson/3dgs-033/blob/main/docs/user-stories/us-20-traverse-hierarchical-location-tree.md) (validates parent-child hierarchy traversal, Feature feat-18)
- [ ] #59 - [Validate Rack-to-Location Referential Integrity](https://github.com/gintatkinson/3dgs-033/blob/main/docs/user-stories/us-21-validate-rack-location-referential-integrity.md) (validates rack location leafref integrity constraint, Features feat-20 and feat-21)
- [ ] #54 - [Deploy Distributed Network Element Across Multiple Physical Locations](https://github.com/gintatkinson/3dgs-033/blob/main/docs/user-stories/us-22-deploy-distributed-multi-chassis-ne.md) (validates multi-chassis NE location deployment, Feature feat-18)
- [ ] #55 - [Paginate Large Inventory Location Query Results](https://github.com/gintatkinson/3dgs-033/blob/main/docs/user-stories/us-23-paginate-large-inventory-queries.md) (validates pagination for large location datasets, Feature feat-18)
- [ ] #56 - [Deploy Non-Rack Equipment Directly at a Location](https://github.com/gintatkinson/3dgs-033/blob/main/docs/user-stories/us-24-deploy-non-rack-equipment-at-location.md) (validates non-rack equipment at location, Feature feat-18)
- [ ] #57 - [Resolve Rack Security Classification from Extensible Identity Hierarchy](https://github.com/gintatkinson/3dgs-033/blob/main/docs/user-stories/us-25-resolve-rack-security-classification.md) (validates rack security classification resolution, Feature feat-20)

## 3. Architecture

### Subsystem Component Definition
The `ietf-ni-location` module is a **Network Inventory Location Subsystem** that extends the base network inventory model with structured location data. It provides read-only operational state containers for hierarchical locations, physical addresses, equipment rack specifications, and rack placement information. The subsystem consumes the `ietf-geo-location` grouping (RFC 9179) for geodetic coordinate data and the `ietf-yang-types` module (RFC 9911) for temporal and UUID types. It exports a single augment point at `/nwi:network-inventory` via the `locations` grouping.

### System-Level UML Class Diagram
```mermaid
classDiagram
    class IetfNiLocationSubsystem {
        <<component>>
        +Boolean provideLocationHierarchy() [1]
        +Boolean providePhysicalAddresses() [1]
        +Boolean provideRackInventory() [1]
        +Boolean provideRackPositioning() [1]
    }
    class Locations {
        +String id "[1]"
        +String type "[0..1]"
        +String parent "[0..1]"
        +String timestamp "[0..1]"
        +String validUntil "[0..1]"
    }
    class PhysicalAddress {
        +String address "[0..1]"
        +String postalCode "[0..1]"
        +String state "[0..1]"
        +String city "[0..1]"
        +String countryCode "[0..1]"
    }
    class Racks {
    }
    class RackLocation {
        +String locationRef "[0..1]"
        +Integer rowNumber "[0..1]"
        +Integer columnNumber "[0..1]"
    }
    IetfNiLocationSubsystem *-- Locations : "contains"
    IetfNiLocationSubsystem *-- Racks : "contains"
    Locations *-- PhysicalAddress : "contains"
    Racks *-- RackLocation : "contains"
```

## State Machine Definitions

### System State Machine Diagram
```mermaid
stateDiagram-v2
    [*] --> DataUnavailable
    DataUnavailable --> DataFetching : fetchLocations()
    DataFetching --> DataLoaded : onSuccess(payload)
    DataFetching --> DataUnavailable : onError(error)
    DataLoaded --> DataFetching : refreshLocations()
    DataLoaded --> DataStale : validUntilElapsed()
    DataStale --> DataLoaded : validUntilUpdated()
    DataStale --> [*] : pruneStaleRecords()
```

## 4. Operational Considerations
This model provides a read-only perspective of network inventory location information known to the controller. It reports the physical locations of network elements and components installed in the network, enabling queries for site, rack, and other location-related information. In brownfield scenarios, existing deployments are based on proprietary inventory OSS solutions, and the migration path is highly dependent on the specific proprietary implementation.

The model is designed with the controller maintaining authoritative location data through automated tooling, while OSS systems consume this data as read-only operational state. Sources of controller location data may include RFID tooling, geolocation services, and manual entry via controller interfaces. The controller does not support OSS modification of location records.

OSS systems obtain location information via standard YANG retrieval operations (NETCONF, RESTCONF). In large-scale inventories, mechanisms such as RESTCONF or NETCONF pagination should be utilized for queries involving large result sets. Data quality is indicated through timestamps recording the last update time, as well as an optional expiration time for location validity.

Before using a location for field dispatch or planning, verification is required to ensure at least one of physical-address or geo-location is present, and that the valid-until leaf is either not present or indicates a future time. Once the valid-until time has passed, the location MUST be considered stale and MUST NOT be used for operational purposes.

## 5. Security & Governance
The `ietf-ni-location` YANG module defines a data model designed to be accessed via YANG-based management protocols (NETCONF, RESTCONF). These protocols must use a secure transport layer (e.g., SSH, TLS, QUIC) and require mutual authentication.

The Network Configuration Access Control Model (NACM) provides the means to restrict access for particular NETCONF or RESTCONF users to a preconfigured subset of all available protocol operations and content.

The `locations` container reports physical deployment information including facility structures (sites, buildings, rooms), rack physical attributes (dimensions, power capacity, security classification), and geographic coordinates. It also references network elements and components by their inventory identifiers (ne-id, component-id). Uncontrolled disclosure may enable association of inventory identifiers with physical facility structures and geographic coordinates, reveal facility layouts and equipment density, expose precise geographic coordinates facilitating physical location identification, and indicate physical protection levels through rack security classifications.

Read access to these data nodes (e.g., via get, get-config, or notification) must be carefully controlled in sensitive network environments.

## Specification Context
> This document defines a YANG data model for Network Inventory location (e.g., site, room, rack, geo-location data), which provides location information with different granularity levels for inventoried network elements. Accurate location information is useful for network planning, deployment, and maintenance. However, such information cannot be obtained or verified from the Network Elements themselves.

> The Network Inventory location model is to record physical locations, such as sites, building, equipment rooms, racks, and so on. Additionally, it includes provisions for physical addresses or geo-location data (geographic coordinates). The location model augments the base network inventory to enrich NEs with location information.

> The Network Inventory location model is classified as a network model (Section 3.5.1 of [I-D.ietf-netmod-rfc8407bis]).

## 6. Source References
Structural Schema: [ietf-ni-location@2026-07-06.yang](https://github.com/gintatkinson/3dgs-033/blob/main/ietf-ni-location.yang) (Clause: module ietf-ni-location)
Normative Specification: [draft-ietf-ivy-network-inventory-location-06](https://datatracker.ietf.org/doc/html/draft-ietf-ivy-network-inventory-location) (Clause: Sections 2-5)
