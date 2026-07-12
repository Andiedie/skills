# Separate Wayfinding Records From Delivery Units

Status: Accepted

## Context

Wayfinding investigations answer planning questions before implementation scope is knowable. PRD children, by contrast, are executable slices inside one claimed delivery unit. Reusing one record shape for both would make planning work publicly claimable, blur relationship meaning, and force a completed map to change identity when delivery begins.

## Decision

Represent Wayfinding as one map with child investigation records. A clear map hands its confirmed decisions to `and-pack`, which publishes a separate single-issue or PRD delivery unit. The new Package Contract alone governs implementation; the map remains linked planning evidence and completes only after package publication is authoritative.

## Consequences

- Map membership and PRD containment remain distinct even when a backend uses the same parent/sub-issue primitive.
- Investigation ownership covers one investigation and never becomes delivery ownership.
- Investigation records are not reused as implementation slices.
- Handoff adds one explicit record boundary, but each source has one stable meaning and failed publication can resume without converting or duplicating the map.
