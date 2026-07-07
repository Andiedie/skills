# Workflow State Backend Contract

The AI-native delivery loop reads and writes one authoritative workflow state backend per repository. The backend is not an issue tracker adapter. It is the source of truth for delivery-loop state.

Every workflow skill must read `.and/config.yml` before backend-specific work:

```yaml
version: 1
workflow_state_backend: github-native
```

or:

```yaml
version: 1
workflow_state_backend: markdown-file-based
```

The first config schema contains only `version` and `workflow_state_backend`.

## Backend Values

| Backend | Source of truth |
| --- | --- |
| `github-native` | GitHub issues, labels, native relationships, comments, and assignees. |
| `markdown-file-based` | Markdown files under `.and/work`. |

Use exactly one backend at a time. Do not maintain GitHub issue state and markdown-file workflow state as parallel sources of truth.

## Core Concepts

| Concept | Meaning |
| --- | --- |
| Work record | A durable record of work, such as a raw request, single package, parent PRD, or child slice. |
| Delivery unit | The public unit that can be picked, claimed, implemented, and completed. |
| Stage state | The public queue state of a delivery unit. |
| State Reason | The structured explanation for why a delivery unit is in its current stage state. |
| Package Contract | The behavior, scope, acceptance, and verification contract used for implementation. |
| Containment relationship | Parent PRD to child slice structure. |
| Dependency relationship | Execution ordering between work records. |
| External blocker | A blocker outside the work record graph. |
| Ownership | The current actor responsible for a delivery unit. |
| Receipt | Append-only evidence from a workflow stage. |
| Lifecycle outcome | A terminal result such as completed, rejected, duplicate, or superseded. |
| Completion evidence | The receipt or linked proof that explains why a lifecycle outcome is valid. |
| Implementation artifact | A branch, commit, PR, CI result, or review result produced during implementation. |

## Backend Operations

Workflow skills should express their work in these backend-neutral operations, then follow the configured backend reference for representation.

### Locate Work

Find raw requests, triage candidates, work waiting for information, work ready to pack, ready delivery units, claimed delivery units, and drift candidates.

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

### Write Stage State

Set one public stage state for a delivery unit:

- `needs-triage`;
- `needs-info`;
- `needs-pack`;
- `ready-for-agent`.

When the stage state is `needs-info`, write a State Reason with:

- `Cause`;
- `Owner`;
- `Question`;
- `Resume with`;
- `Exit criteria`.

Closed, completed, rejected, duplicate, and superseded are lifecycle outcomes, not active stage states.

### Write Relationships

Write containment and dependency relationships without mixing their meanings.

- Containment: parent PRD contains child slices.
- Dependency: one work record is blocked by another work record.
- External blocker: missing access, external state, or human acceptance outside the work record graph.

### Publish Package

Turn raw or triaged work into one delivery unit:

- single package; or
- PRD package with child slices.

Publishing a package writes the Package Contract, relationships, verification expectations, and `ready-for-agent` stage state.

### Record Ownership

Record one owner for the whole delivery unit. For a PRD package, ownership covers the parent PRD and all children. Child slices can be internal work units but are not public claim units.

Backends may represent current ownership directly or derive it from append-only receipts such as claim receipts. Follow the configured backend reference; do not invent extra ownership fields.

### Record Receipt

Append evidence from a workflow stage: grill decisions, pack publication, claim, implementation, review, verification, completion, rejection, or follow-up.

### Audit Invariants

Check state, relationship, ownership, receipt, and lifecycle consistency for the configured backend.

## State Reason

Use `State Reason` for stage-state explanation.

State Reason explains why a delivery unit is waiting in `needs-info`. Dependency relationships explain execution order. These are different concepts.

Backends may keep the latest State Reason in queryable metadata, but material State Reason changes must also leave append-only evidence through the backend's receipt or comment mechanism.

```markdown
## State Reason

State: needs-info
Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
Owner: <reporter, maintainer, human, agent, or external-system>
Question: <one specific question, decision, permission, external event, or acceptance gate>
Resume with: <issue-triage, issue-grill, or issue-pack>
Exit criteria: <what must be true before this delivery unit can leave needs-info>
```

## References

- [GitHub-native backend](backends/github-native.md)
- [Markdown-file-based backend](backends/markdown-file-based.md)
- [Workflow examples](workflow-examples.md)
