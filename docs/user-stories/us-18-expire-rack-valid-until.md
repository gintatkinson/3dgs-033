---
title: "Expire Rack Record at valid-until Temporal Boundary"
issue_id: 51
type: "user-story"
generation_mode: "subagent"
spec_source: "draft-ietf-ivy-network-inventory-location-06"
---

# User Story: Expire Rack Record at valid-until Temporal Boundary

## Parent Epic
- [ ] #49 - [ietf-ni-location: Network Inventory Location](https://github.com/gintatkinson/3dgs-033/blob/main/docs/epics/epic-04-ietf-ni-location.md) (the racks container defines the valid-until leaf on each rack entry and governs the rack data lifecycle from valid to stale)

## Domain Object Mapping
- **Primary Domain Objects:** Racks
- **Actor/Role:** RackExpiryMonitor — the system component that evaluates the current time against the rack-level valid-until timestamp and transitions the rack state accordingly

## BDD Scenario (OOA/OOD Realization)
**As a** RackExpiryMonitor
**I want to** detect when a rack record's valid-until timestamp has passed the current system time
**So that** expired rack data is flagged as stale and consumers avoid relying on out-of-date rack specifications and placement data

**Given** a rack record with valid-until set to "2028-01-15T10:00:00Z"
**And** the current system time is "2028-01-16T00:00:00Z"
**When** the rack expiry monitor evaluates the record
**Then** the rack is transitioned from the Valid state to the Stale state
**And** any consumer querying the record is informed that the rack data has expired

**Given** a rack record with valid-until set to "2028-01-15T10:00:00Z"
**And** the current system time is "2026-06-15T12:00:00Z"
**When** the rack expiry monitor evaluates the record
**Then** the rack remains in the Valid state
**And** the record is considered current for operational use including power planning and equipment placement

**Given** a rack record with no valid-until value set
**When** the rack expiry monitor evaluates the record
**Then** the rack is treated as having no specific expiration time
**And** the record remains in the Valid state indefinitely

**Given** a rack record in the Stale state
**And** the valid-until is updated to a future timestamp "2030-01-01T00:00:00Z"
**When** the rack expiry monitor re-evaluates the record
**Then** the rack transitions from Stale back to the Valid state
**And** the rack dimensions, power capacity, and placement data are once again considered current

**Given** a rack record in the Stale state
**And** the rack-location still references a valid location from the location list
**When** the rack data is queried for historical inventory reporting
**Then** the full rack data is returned complete with its Stale status flag and all contained-chassis entries

**Given** a rack record with valid-until set to a timestamp that equals the current time exactly
**When** the rack expiry monitor evaluates the record at the boundary instant
**Then** the record is treated as expired (inclusive boundary: the data is valid until but not at the timestamp itself)

## UML Sequence Diagram
```mermaid
sequenceDiagram
    autonumber
    actor rackExpiryMonitor as "rackExpiryMonitor : RackExpiryMonitor"
    actor expiryChecker as "expiryChecker : ExpiryChecker"
    participant racks as "racks : Racks"

    rackExpiryMonitor->>expiryChecker: evaluateRackExpiry(rackId: Identifier)
    Note over expiryChecker, racks: Read the valid-until leaf from the target rack and obtain the current system time
    alt [validUntil is null]
        expiryChecker-->rackExpiryMonitor: status : Valid
        Note over rackExpiryMonitor: No expiration set, rack data remains valid indefinitely
    else [currentTime > validUntil]
        Note over expiryChecker, racks: The valid-until timestamp has passed, transition the rack to Stale
        expiryChecker-->rackExpiryMonitor: status : Stale
    else [currentTime <= validUntil]
        expiryChecker-->rackExpiryMonitor: status : Valid
        Note over rackExpiryMonitor: Rack data is within its validity window
    end
```

## UML State Machine Diagram
```mermaid
stateDiagram-v2
    [*] --> Valid
    Valid --> Stale : expire [currentTime > validUntil] / flagRackAsStale
    Stale --> Valid : revalidate [updatedValidUntil > currentTime] / extendRackValidity
    Valid --> Valid : refreshRackData [newDataArrives] / updateRackTimestamp
    Stale --> Stale : queryHistorical [readOnlyAccess] / returnFullRackData
```

## Operational Context
> The timestamp for which this rack is valid until. If unspecified, the rack has no specific expiration time. (ietf-ni-location.yang — leaf valid-until on list rack)

> Data quality is indicated through timestamps recording the last update time, as well as an optional expiration time for location validity. (draft-ietf-ivy-network-inventory-location-06, Section 6)

> "racks" represent physical equipment racks in which NEs can be installed, which facilitate device maintenance. Through "rack-location", each rack can be assigned to a site or a specific location within a site, such as an equipment room. (draft-ietf-ivy-network-inventory-location-06, Section 3)

## Required Features Matrix
- [ ] #47 - [Define Racks Container](https://github.com/gintatkinson/3dgs-033/blob/main/docs/features/feat-20-racks-container.md) (provides the rack entry with the valid-until leaf of type yang:date-and-time that defines the expiry boundary for this temporal lifecycle)

## Source References
Structural Schema: [ietf-ni-location@2026-07-06.yang](https://github.com/ietf-ivy-wg/network-inventory-location/blob/main/ietf-ni-location.yang) (Clause: leaf valid-until on list rack)
Normative Specification: [draft-ietf-ivy-network-inventory-location-06](https://datatracker.ietf.org/doc/html/draft-ietf-ivy-network-inventory-location) (Clause: Section 3, Rack; Section 6, Operational Considerations)

> [!WARNING]
> **Mermaid Block Closing Constraints & Code Fence Integrity:**
> - Every Mermaid diagram MUST be strictly closed with ``` ``` ``` on a new line. Leaking Mermaid blocks (e.g. having headings like `##` inside an unclosed diagram) or stray/unclosed code fences will fail downstream validation checks.
> - Ensure there are no stray backticks or unmatched code fences in the document.
> - **All Mermaid syntax constraints are defined in `rules/platform-independence.md` and MUST be observed in full** — including the prohibition on semicolons in `Note` and message text, colons in class members and note strings, stereotypes on relationship lines, and curly braces in class member lines. Do not maintain a local subset here; subsets drift (issue #289).
