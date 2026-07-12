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

The configured backend is exclusive. A repository may reference investigation assets and implementation artifacts from tools outside the backend, but those artifacts do not become workflow state. Do not maintain GitHub issue state and markdown-file workflow state as parallel sources of truth.

## Core Concepts

| Concept | Meaning |
| --- | --- |
| Work record | A durable record in the configured backend. It may be raw, triaged, a Wayfinding map or investigation, packaged, a parent PRD, or a child slice. |
| Delivery unit | The public unit that can be picked, claimed, implemented, and completed: a single package or parent PRD package. |
| Stage state | The active queue position of an open top-level work record. |
| State Reason | The current structured reason a top-level work record is waiting in `needs-info`. |
| Package Contract | The implementation source of truth published by `and-pack`. |
| Containment relationship | Parent PRD contains child slices. |
| Dependency relationship | Work record A must wait for work record B. |
| Wayfinding map | A shared planning index that holds a destination, decisions, fog, and scope until work can be packaged. It is not a delivery unit. |
| Investigation | One sharp question under a Wayfinding map, sized for one Agent session and carrying no public stage. |
| Map relationship | A Wayfinding map owns investigation records. It is distinct from PRD containment even when a backend uses the same native parent/sub-issue primitive. |
| Fog | In-scope uncertainty that cannot yet be phrased as a sharp investigation question. |
| Frontier | Open, unblocked, unclaimed investigations on a map. |
| Investigation ownership | Responsibility for one investigation. It grants no delivery ownership. |
| Investigation asset | Linked evidence produced to answer an investigation. It is not workflow state or repository truth unless a Package Contract promotes it. |
| External blocker | A blocker outside the work record graph. |
| Ownership | The current owner of the full delivery unit. |
| Receipt | Append-only evidence from a workflow stage. |
| Lifecycle outcome | A terminal result such as completed, rejected, duplicate, or superseded. |
| Completion evidence | A receipt or linked proof that justifies a lifecycle outcome. |
| Implementation artifact | A delivery branch, commit, PR, CI result, or review result referenced from workflow state. |

## Relationship Vocabulary

Keep these waiting and relationship concepts separate:

| Concept | Used for | Not used for |
| --- | --- | --- |
| Containment relationship | PRD parent and child slice structure. | Execution order or blocking. |
| Map relationship | Wayfinding map and investigation structure. | Delivery packaging, execution order, or ownership. |
| Dependency relationship | Work-record execution order. | Parent/child structure. |
| External blocker | Missing access, third-party state, manual acceptance, or another wait outside the work graph. | Work-record dependency. |
| State Reason | Current reason a top-level work record is in `needs-info`. | Permanent blocker log or execution graph. |

Rules:

- A parent PRD is not a blocker for its children merely because it is the parent.
- A Wayfinding map is not a PRD parent, and an investigation is not a child slice.
- The meaning of a native parent/sub-issue edge comes from the parent and child record kinds; map relationships and PRD containment must never be converted into each other.
- A dependency relationship should never express containment.
- External blockers can make a delivery unit unpickable, but they are not dependency relationships.
- State Reason explains the current `needs-info` route and names the skill to resume with.

## Backend-Neutral Operations

Workflow skills should express their work in these backend-neutral operations, then follow the configured backend reference for representation.

### Locate Work

Find candidate work records by stage, lifecycle, ownership, relationship, or drift condition using the configured backend.

### Read Work Record

Read one work record enough for the calling stage: body, stage, lifecycle, latest State Reason when present, receipts, relationships, and source evidence.

### Resolve Canonical Identity

Resolve the identity class required by the operation through the configured backend reference:

- session-recovery identity may follow a worktree-local record path when preserving an established local-buffer contract;
- durable-workflow identity must survive worktree changes and record-shape renames because its key is written to workflow state.

The calling skill names the identity class. Stored publication and handoff keys always use durable-workflow identity.

For an operation namespace `<operation>:v<version>`, hash exactly these three UTF-8 lines with SHA-256:

```text
<operation>:v<version>
<canonical repository identity>
<canonical work-record identity>
```

Use LF line endings, exactly one final LF, and no byte-order mark. Do not trim or otherwise normalize the backend-provided identities. Once a durable key is recorded, retries reuse that recorded key rather than deriving a replacement.

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

### Read Wayfinding Map

Read the map's destination, notes, decision pointers, fog, out-of-scope boundary, current stage and State Reason, investigation records, investigation dependencies, claims, resolutions, and linked assets.

The frontier is derived from current investigation state rather than stored as a second list.

### Chart Wayfinding Map

Promote one existing top-level work record into a Wayfinding map, preserve material source evidence, create currently sharp investigations, and write map relationships and investigation dependencies.

Before creating any initial or newly visible investigation batch, record a deterministic publication intent on the map. It lists stable investigation keys, methods, titles, and questions. Every investigation carries its key in its initial authoritative record. Retry searches those keys first, reuses a sole match, creates only missing records, and finishes missing membership or dependency edges. Multiple matches are drift and leave the map non-executable for `and-sweep`.

Map creation is authoritative only when the map, every planned investigation, and every created relationship can be recovered through the configured backend.

### Resolve Investigation

Record or resume one investigation claim, run its method only when no durable resolution exists, write one durable resolution, close that investigation, append a named context pointer to the map, and update newly visible investigations, dependencies, fog, or scope. A current owner may resume an open investigation; a closed resolved investigation with an incomplete map advance resumes that missing mutation before new frontier work. Resolution never establishes delivery ownership.

### Hand Off Wayfinding Map

When a map is clear, derive and record a deterministic handoff key on the map before creating a separate delivery unit. The replacement carries that key in its initial authoritative record, so retry can recover an identity even if creation succeeded before its ID was written back to the map.

Re-read the map and exact-key matches immediately before allocation and again after creation. Continue publication only when exactly one replacement matches. If concurrent writers create multiple matches, keep the map open and every matching replacement non-executable, then route the drift to `and-sweep`; do not choose a winner inside `and-pack`.

Finish Package promotion and temporary-asset disposition before making the sole replacement ready, then complete the map.

### Write Stage State

Set one public stage state for a top-level work record:

- `needs-triage`;
- `needs-info`;
- `needs-pack`;
- `ready-for-agent`.

Each top-level work record has at most one active stage state. PRD children and Wayfinding investigations do not carry public stage state. A map uses `needs-info` while fog or investigations remain and `needs-pack` when its route is clear; maps never use `ready-for-agent`. Closed, completed, rejected, duplicate, and superseded are lifecycle outcomes, not active stage states.

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
- Map relationship: Wayfinding map owns investigations.
- Dependency: one work record is blocked by another work record.
- External blocker: missing access, external state, or human acceptance outside the work record graph.

### Record Ownership

Record one owner for the whole delivery unit. For a PRD package, ownership covers the parent PRD and all children. Child slices can be internal work units but are not public claim units.

Backends may represent current ownership directly or derive it from append-only receipts such as claim receipts. Follow the configured backend reference; do not invent extra ownership fields.

### Record Investigation Ownership

Record one owner for one frontier investigation immediately before work. The same owner may resume it across invocations and may explicitly release unfinished ownership after preserving recovery or blocker evidence. The map remains shared and unclaimed. Investigation ownership ends with that investigation and never authorizes `and-pick`, `and-claim`, implementation, or delivery closure.

### Record Receipt

Append evidence from a workflow stage: grill decisions, Wayfinding claims and resolutions, map handoff, pack publication, claim, implementation, review, verification, completion, rejection, or follow-up.

Receipt content is owned by the calling workflow skill. Receipt location and append rules are owned by the configured backend reference.

### Record Lifecycle Outcome

Record a terminal outcome such as completed, rejected, duplicate, or superseded. Terminal outcomes are lifecycle state, not active stage state. Completion evidence must be recorded as a receipt or linked proof.

### Reference Implementation Artifact

Attach branch, commit, PR, CI, or review evidence as an implementation artifact reference. Implementation artifacts do not establish ownership and do not replace the Package Contract.

### Finish Delivery

Coordinate one reviewed implementation artifact with the delivery unit's terminal lifecycle outcome.

- Prove that the implementation reached the authorized target.
- Record completion evidence using the calling skill's receipt contract.
- Make `completed` authoritative only when delivery and backend completion evidence are both authoritative.
- Begin source-branch and worktree cleanup only after authoritative completion.

The configured backend reference defines when its completion state becomes authoritative and where the receipt is recorded.

### Audit Invariants

Check state, relationship, ownership, receipt, and lifecycle consistency for the configured backend.

## Cross-Backend Invariants

- Use exactly one configured backend.
- Do not maintain parallel GitHub and markdown workflow state.
- A delivery unit has at most one active stage state.
- A Wayfinding map has at most one active stage state and never carries `ready-for-agent`.
- PRD children do not carry public stage state.
- Wayfinding investigations do not carry public stage state.
- The claim unit equals the delivery unit.
- Investigation ownership covers one investigation and never becomes delivery ownership.
- Parent PRD plus `ready-for-agent` means the whole PRD package is ready.
- Containment is not dependency.
- Map relationship is not PRD containment or dependency.
- External blockers are not dependency relationships.
- Implementation artifacts are references, not workflow state.
- Lifecycle outcomes are terminal and not active stage states.
- A completed delivery unit has implementation on its authorized target and completion evidence in the configured backend.
- Delivery cleanup follows authoritative lifecycle completion.

## State Reason Contract

State Reason is required when a top-level work record is in `needs-info`.

Required fields:

- `Cause`
- `Owner`
- `Question`
- `Resume with`
- `Exit criteria`

Allowed `Resume with` values should be workflow skills that can continue the work, usually `and-triage`, `and-clarify`, `and-wayfind`, or `and-pack`.

Ordinary `needs-info` work names one specific missing input. A structurally identified Wayfinding map instead names the destination-level uncertainty and delegates its changing sharp questions to the map's frontier; its `Resume with` is `and-wayfind`.

The latest State Reason is queryable according to the backend reference. Material State Reason changes must leave append-only evidence.

```markdown
## State Reason

State: needs-info
Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
Owner: <reporter, maintainer, human, agent, or external-system>
Question: <one specific question, decision, permission, external event, or acceptance gate>
Resume with: <and-triage, and-clarify, and-wayfind, or and-pack>
Exit criteria: <what must be true before this work record can leave needs-info>
```

## Receipt Contract

Receipts are append-only evidence from workflow stages.

The backend reference defines where receipts live. The calling workflow skill defines what the receipt says.

Use receipts for turning points:

- State Reason changes;
- and-clarify decisions;
- Wayfinding chart, investigation, and map-handoff evidence;
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
