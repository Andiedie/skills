# Separate Wayfinding Records From Delivery Units

Status: Accepted

## Context

Wayfinding investigations answer planning questions before implementation scope is knowable. PRD children, by contrast, are executable slices inside one claimed delivery unit. Reusing one record shape for both would make planning work publicly claimable, blur relationship meaning, and force a completed map to change identity when delivery begins.

## Decision

Represent Wayfinding as one map with child investigation records. The map is a compact index: detailed answers live in investigation resolutions and the map carries only named linked gists. A clear map hands its confirmed package-ready input to `and-pack`, which publishes a separate single-issue or PRD delivery unit. That Package Contract alone governs implementation; the map remains linked planning evidence and completes only after package publication is authoritative.

## Consequences

- Map membership and PRD containment remain distinct even though both use GitHub's parent/sub-issue primitive.
- Investigation ownership covers one investigation and grants no delivery ownership.
- Investigation records are not reused as implementation slices.
- Handoff adds one explicit record boundary, but each source has one stable meaning and failed publication can resume without converting or duplicating the map.
