# Workflow State Backend Contract

The AND delivery loop uses one authoritative workflow state backend per repository.

This contract defines the shared vocabulary and backend-neutral operations every workflow skill must use before applying the configured backend representation. The backend is the delivery-loop source of truth, not an issue tracker adapter or a mirror target.

## Config Contract

Every workflow skill must read `.and/config.yml` before backend-specific work.

Version 1 config is exactly:

```yaml
version: 1
workflow_state_backend: github-native
```

or:

```yaml
version: 1
workflow_state_backend: markdown-file-based
```

Rules:

- `version` must be `1`.
- `workflow_state_backend` must be `github-native` or `markdown-file-based`.
- Version 1 has no other fields.
- Missing, malformed, unsupported, or extended config routes to `setup-and`.

## Backend Values

| Backend | Source of truth |
| --- | --- |
| `github-native` | GitHub issues, labels, native relationships, comments, and assignees. |
| `markdown-file-based` | Markdown files under `.and/work`. |

The configured backend is exclusive. A repository may reference implementation artifacts from tools outside the backend, but those artifacts do not become workflow state. Do not maintain GitHub issue state and markdown-file workflow state as parallel sources of truth.

## Core Concepts

| Concept | Meaning |
| --- | --- |
| Work record | A durable record in the configured backend. It may be raw, triaged, packaged, a parent PRD, or a child slice. |
| Delivery unit | The public unit that can be picked, claimed, implemented, and completed: a single package or parent PRD package. |
| Stage state | The active queue state of a delivery unit before terminal lifecycle outcome. |
| State Reason | The current structured reason a delivery unit is waiting in `needs-info`. |
| Package Contract | The implementation source of truth published by `and-pack`. |
| Containment relationship | Parent PRD contains child slices. |
| Dependency relationship | Work record A must wait for work record B. |
| External blocker | A blocker outside the work record graph. |
| Ownership | The current owner of the full delivery unit. |
| Receipt | Append-only evidence from a workflow stage. |
| Lifecycle outcome | A terminal result such as completed, rejected, duplicate, or superseded. |
| Completion evidence | A receipt or linked proof that justifies a lifecycle outcome. |
| Implementation artifact | A branch, commit, PR, CI result, or review result referenced from workflow state. |

## Relationship Vocabulary

Keep four waiting and relationship concepts separate:

| Concept | Used for | Not used for |
| --- | --- | --- |
| Containment relationship | PRD parent and child slice structure. | Execution order or blocking. |
| Dependency relationship | Work-record execution order. | Parent/child structure. |
| External blocker | Missing access, third-party state, manual acceptance, or another wait outside the work graph. | Work-record dependency. |
| State Reason | Current reason a delivery unit is in `needs-info`. | Permanent blocker log or execution graph. |

Rules:

- A parent PRD is not a blocker for its children merely because it is the parent.
- A dependency relationship should never express containment.
- External blockers can make a delivery unit unpickable, but they are not dependency relationships.
- State Reason explains the current `needs-info` route and names the skill to resume with.

## Backend-Neutral Operations

Workflow skills should express their work in these backend-neutral operations, then follow the configured backend reference for representation.

### Locate Work

Find candidate work records by stage, lifecycle, ownership, relationship, or drift condition using the configured backend.

### Read Work Record

Read one work record enough for the calling stage: body, stage, lifecycle, latest State Reason when present, receipts, relationships, and source evidence.

### Read Delivery Unit

Read the complete implementation source of truth for one delivery unit:

- stage state and State Reason;
- Package Contract;
- containment relationships;
- dependency relationships;
- external blockers;
- receipts and decision notes;
- ownership;
- implementation artifacts;
- lifecycle outcome and completion evidence.

For PRD packages, reading the delivery unit means reading the parent PRD plus all child slices and relevant dependency relationships.

### Write Stage State

Set one public stage state for a delivery unit:

- `needs-triage`;
- `needs-info`;
- `needs-pack`;
- `ready-for-agent`.

Each delivery unit has at most one active stage state. PRD children do not carry public stage state. Closed, completed, rejected, duplicate, and superseded are lifecycle outcomes, not active stage states.

### Write State Reason

When the stage state is `needs-info`, write the latest State Reason through the configured backend. Material State Reason changes must also leave append-only evidence.

### Publish Package

Turn raw or triaged work into one delivery unit:

- single package; or
- PRD package with child slices.

Publishing a package writes the Package Contract, relationships, verification expectations, and `ready-for-agent` stage state. Package Contract content is owned by `and-pack`; this contract defines where it lives.

### Write Relationships

Write containment and dependency relationships without mixing their meanings.

- Containment: parent PRD contains child slices.
- Dependency: one work record is blocked by another work record.
- External blocker: missing access, external state, or human acceptance outside the work record graph.

### Record Ownership

Record one owner for the whole delivery unit. For a PRD package, ownership covers the parent PRD and all children. Child slices can be internal work units but are not public claim units.

Backends may represent current ownership directly or derive it from append-only receipts such as claim receipts. Follow the configured backend reference; do not invent extra ownership fields.

### Record Receipt

Append evidence from a workflow stage: grill decisions, pack publication, claim, implementation, review, verification, completion, rejection, or follow-up.

Receipt content is owned by the calling workflow skill. Receipt location and append rules are owned by the configured backend reference.

### Record Lifecycle Outcome

Record a terminal outcome such as completed, rejected, duplicate, or superseded. Terminal outcomes are lifecycle state, not active stage state. Completion evidence must be recorded as a receipt or linked proof.

### Reference Implementation Artifact

Attach branch, commit, PR, CI, or review evidence as an implementation artifact reference. Implementation artifacts do not establish ownership and do not replace the Package Contract.

### Audit Invariants

Check state, relationship, ownership, receipt, and lifecycle consistency for the configured backend.

## Cross-Backend Invariants

- Use exactly one configured backend.
- Do not maintain parallel GitHub and markdown workflow state.
- A delivery unit has at most one active stage state.
- PRD children do not carry public stage state.
- The claim unit equals the delivery unit.
- Parent PRD plus `ready-for-agent` means the whole PRD package is ready.
- Containment is not dependency.
- External blockers are not dependency relationships.
- Implementation artifacts are references, not workflow state.
- Lifecycle outcomes are terminal and not active stage states.

## State Reason Contract

State Reason is required when a delivery unit is in `needs-info`.

Required fields:

- `Cause`
- `Owner`
- `Question`
- `Resume with`
- `Exit criteria`

Allowed `Resume with` values should be workflow skills that can continue the work, usually `and-triage`, `and-clarify`, or `and-pack`.

The latest State Reason is queryable according to the backend reference. Material State Reason changes must leave append-only evidence.

```markdown
## State Reason

State: needs-info
Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
Owner: <reporter, maintainer, human, agent, or external-system>
Question: <one specific question, decision, permission, external event, or acceptance gate>
Resume with: <and-triage, and-clarify, or and-pack>
Exit criteria: <what must be true before this delivery unit can leave needs-info>
```

## Receipt Contract

Receipts are append-only evidence from workflow stages.

The backend reference defines where receipts live. The calling workflow skill defines what the receipt says.

Use receipts for turning points:

- State Reason changes;
- and-clarify decisions;
- package publication;
- claim;
- implementation;
- review;
- verification;
- lifecycle outcome;
- follow-up work.

Receipts should not become a duplicate Package Contract unless the calling stage is `and-pack`.

## References

- [GitHub-native backend](backends/github-native.md)
- [Markdown-file-based backend](backends/markdown-file-based.md)
