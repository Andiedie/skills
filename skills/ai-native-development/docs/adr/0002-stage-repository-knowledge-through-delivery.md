# Stage Repository Knowledge Through Delivery

Status: Accepted

## Context

Clarify and Wayfind refine durable project knowledge, but they are planning stages rather than claimed implementation. Writing repository documents during planning gives immediate visibility while also publishing decisions that may still be paused, redirected, or abandoned.

The existing delayed-write model preserves the delivery boundary. Its missing piece is an explicit record of whether a completed decision requires a long-lived repository update.

## Decision

Clarify and Wayfind keep repository files unchanged. Every completed decision result records one repository knowledge disposition:

- `Required` identifies each target, change, and reason.
- `None` explains why the authority test found no durable update.

Knowledge advances through three authorities:

1. the Clarification Notes, Investigation Resolution, or Wayfinding Exit before Pack;
2. the Package Contract, with source permalinks, after Pack;
3. the merged repository document after delivery.

Pack preserves confirmed dispositions. Implement applies every Required item and supplies the resulting diff to Spec review. A discovery that changes the disposition returns to the stage that owns the contract or decision.

Concurrent work uses current-state reads and normal review. Compatible edits can combine; semantic conflicts return to Pack. The contract applies to new results after this decision lands, while historical omission remains unclassified.

## Alternatives

- Inline planning writes shorten the feedback loop but publish knowledge before delivery is claimed.
- Historical Issues can preserve context but are not the long-term project authority.
- Coordination machinery—a global pending-decision index, lock, knowledge Issue, or local numbering—adds shared state without improving the delivery chain.
- A compatibility layer would assign invented meaning to historical omission; forward-only migration keeps one schema.

## Consequences

- Required updates remain traceable from decision to merged document.
- Reasoned None results stay visible without creating repository noise.
- Project-level visibility arrives at merge rather than during planning.
- Interrupted and concurrent deliveries keep their existing recovery and review boundaries.
