---
name: and-workflow-contract
description: Use when an AND skill needs to read, write, validate, or reason about GitHub workflow state.
---

# AND Workflow Contract

GitHub Issues, labels, native relationships, comments, and assignees are the authoritative workflow state for the AND delivery loop. Branches, commits, pull requests, CI, and review results are implementation artifacts linked from that state.

Use this contract before an AND workflow skill reads or mutates workflow state. The calling skill owns its stage behavior and receipt content; this contract owns shared concepts, GitHub representation, operations, and invariants.

## Source Of Truth

| Concept | GitHub representation |
| --- | --- |
| Work record | GitHub issue. |
| Delivery unit | Single issue package, or parent PRD issue plus all native sub-issues. |
| Stage state | One active queue label on an open top-level issue. |
| State Reason | Latest issue comment headed `## State Reason`. |
| Package Contract | Body of the single issue package or parent PRD issue. |
| Containment relationship | Native parent/sub-issue relationship under a parent carrying `parent-prd`. |
| Map relationship | Native parent/sub-issue relationship under a parent carrying `wayfinder:map`. |
| Dependency relationship | Native blocked-by/blocking relationship. |
| External blocker | Current State Reason while work is in `needs-info`, or an explicit Package Contract note when it blocks execution after packaging. |
| Ownership | Sole delivery-unit assignee plus latest valid ownership receipt when assignment is available and allowed by repository policy; otherwise the latest valid receipt. |
| Investigation ownership | Exactly one assignee on an open investigation. |
| Receipt | Issue comment on the work record whose operation it evidences. |
| Lifecycle outcome | GitHub closed state plus completion or close-reason evidence. |
| Implementation artifact | Branch, commit, PR, CI, or review link referenced by a receipt. |

Repository files may describe the workflow but do not carry package state, ownership, relationships, or lifecycle outcomes.

## Core Concepts

| Concept | Meaning |
| --- | --- |
| Work record | A durable GitHub issue that may be raw, triaged, a Wayfinding map or investigation, packaged, a parent PRD, or a child slice. |
| Delivery unit | The public unit that can be picked, claimed, implemented, and completed: a single package or parent PRD package. |
| Stage state | The active queue position of an open top-level work record. |
| State Reason | The structured current reason a top-level work record is waiting in `needs-info`. |
| Package Contract | The implementation source of truth published by `and-pack`. |
| Wayfinding map | A shared planning index that holds a destination, decisions, fog, and scope until work can be packaged. It is not a delivery unit. |
| Investigation | One sharp question under a Wayfinding map, sized for one Agent session and carrying no public stage. |
| Fog | In-scope uncertainty that cannot yet be phrased as a sharp investigation question. |
| Frontier | Open, unblocked, unclaimed investigations on a map. |
| Investigation asset | Linked evidence produced to answer an investigation; it becomes repository truth only when a Package Contract promotes it. |
| External blocker | Missing access, third-party state, human acceptance, or another wait outside the work-record graph. |
| Ownership | Responsibility for the complete delivery unit. |
| Receipt | Append-only evidence from a workflow stage. |
| Lifecycle outcome | A terminal result such as completed, rejected, duplicate, or superseded. |

## Relationship Vocabulary

| Relationship | Expresses | Does not express |
| --- | --- | --- |
| Containment | Parent PRD and child-slice structure. | Execution order. |
| Map | Wayfinding map and investigation membership. | Delivery packaging or ownership. |
| Dependency | Work-record execution order. | Parent/child structure. |
| External blocker | A wait outside the work-record graph. | A native dependency edge. |
| State Reason | Why top-level work currently waits in `needs-info`. | A permanent blocker log. |

The parent kind determines whether a parent/sub-issue edge is PRD containment or map membership. A parent is not a blocker for its children merely because it is the parent. Use blocked-by only for execution dependencies.

## Setup Readiness

AND is ready when all of these facts are proven:

- one Git remote identifies one GitHub repository with Issues available;
- the active queue labels exist: `needs-triage`, `needs-info`, `needs-pack`, and `ready-for-agent`;
- structural labels required by installed workflow features exist, including `parent-prd` and the [Wayfinding labels](wayfinding.md#representation);
- the authenticated actor can create, edit, comment on, label, close, and reopen issues, and can assign itself for investigation ownership;
- native parent/sub-issue and blocked-by relationships are readable and their required write capability is proven;
- the root repository instructions direct Agents to GitHub workflow state, `ask-andie`, the installed AND skills, and this contract;
- no effective repository instruction names another workflow-state source or relationship convention.

Missing labels are repairable setup gaps. An unavailable or unverified native capability keeps the repository unready. Read [relationship-api.md](relationship-api.md) when `setup-and` verifies native relationship capability.

## Operation Index

| Operation | Authority |
| --- | --- |
| Locate Work | [Stage State](#stage-state), [Package Shapes](#package-shapes), [Ownership](#ownership), [Relationships](#relationships), and open or closed issue state; load [wayfinding.md](wayfinding.md#read-a-map) for Wayfinding criteria or [sweep-checks.md](sweep-checks.md) for drift criteria. |
| Read Work Record | [Source Of Truth](#source-of-truth), [State Reason](#state-reason), [Relationships](#relationships), and [Receipts](#receipts-and-implementation-artifacts). |
| Write Work Record | [Raw Work Records](#raw-work-records). |
| Resolve Canonical Identity | [Canonical Identities](#canonical-identities). |
| Read Delivery Unit | [Stage State](#stage-state), [State Reason](#state-reason), [Package Shapes](#package-shapes), [Relationships](#relationships), [External Blockers](#external-blockers), [Ownership](#ownership), [Receipts](#receipts-and-implementation-artifacts), and [Lifecycle](#lifecycle). |
| Read Wayfinding Map | [wayfinding.md](wayfinding.md#read-a-map). |
| Chart Wayfinding Map | [wayfinding.md](wayfinding.md#chart-a-map). |
| Resolve Investigation | [wayfinding.md](wayfinding.md#resolve-an-investigation). |
| Hand Off Wayfinding Map | [wayfinding.md](wayfinding.md#hand-off-a-clear-map). |
| Write Stage State | [Stage State](#stage-state). |
| Write State Reason | [State Reason](#state-reason). |
| Publish Package | [Package Shapes](#package-shapes) and [Relationships](#relationships). |
| Write Relationships | [Relationships](#relationships); load [relationship-api.md](relationship-api.md) before native relationship mutation. |
| Record Ownership | [Ownership](#ownership). |
| Record Investigation Ownership | [wayfinding.md](wayfinding.md#investigation-ownership). |
| Record Receipt | [Receipts](#receipts-and-implementation-artifacts). |
| Record Lifecycle Outcome | [Lifecycle](#lifecycle). |
| Reference Implementation Artifact | [Receipts](#receipts-and-implementation-artifacts). |
| Finish Delivery | [Finish Delivery](#finish-delivery). |
| Audit Invariants | [sweep-checks.md](sweep-checks.md). |

The caller reads this `SKILL.md` plus only the direct conditional reference named by its operation. Sibling references are terminal; they do not route to one another.

## Raw Work Records

Create a new top-level issue with caller-provided title and body, open lifecycle, and `needs-triage`. Updating an identified issue merges new evidence while preserving stage, lifecycle, relationships, ownership, and earlier receipts unless another named operation changes them.

## Canonical Identities

Session-recovery and durable-workflow identity use:

- repository identity: lowercase `<host>/<owner>/<repository>` from the issue URL;
- work-record identity: decimal issue number without `#`.

Canonical actor identity is the authenticated GitHub login, lowercased and without `@`. Resolve it from GitHub's authenticated-user endpoint.

For an operation namespace `<operation>:v<version>`, hash exactly these UTF-8 lines with SHA-256:

```text
<operation>:v<version>
<canonical repository identity>
<canonical work-record identity>
```

Use LF endings, exactly one final LF, and no byte-order mark. Stored publication and handoff keys always use durable-workflow identity. Once a durable key is recorded, retries reuse that key.

## Stage State

The complete active queue label set is:

- `needs-triage`;
- `needs-info`;
- `needs-pack`;
- `ready-for-agent`.

Apply exactly one to an open top-level work issue. A PRD parent carries the package stage; its children carry none. Investigations carry none. An active Wayfinding map uses `needs-info` or `needs-pack` and never `ready-for-agent`. `parent-prd` and `wayfinder:map` are structural. Closed work uses GitHub closed state rather than a stage label.

## State Reason

An issue in `needs-info` requires a current append-only comment:

```markdown
## State Reason

State: needs-info
Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
Owner: <reporter, maintainer, human, agent, or external-system>
Question: <one specific question, decision, permission, external event, or acceptance gate>
Resume with: <and-triage, and-clarify, and-wayfind, or and-pack>
Exit criteria: <what must be true before this work record can leave needs-info>
```

The latest State Reason supersedes earlier comments. When work leaves `needs-info`, append:

```markdown
## State Reason

State: cleared
```

Ordinary work names one specific missing input. A Wayfinding map names destination-level uncertainty and delegates changing sharp questions to its frontier.

## Package Shapes

### Single Issue Package

The issue body contains the complete Package Contract and carries `ready-for-agent`.

### PRD Package

The parent issue body contains the complete Package Contract and carries `parent-prd` plus `ready-for-agent`. Native sub-issues are internal execution slices and carry no active stage. The parent is the sole public pick, claim, and finish target.

## Relationships

Use native parent/sub-issue edges for PRD containment and map membership, and native blocked-by/blocking edges for dependencies. Native edges are the sole relationship representation; package bodies do not duplicate them as task lists.

Cross-PRD dependencies connect the delivery units or child records that actually wait. Read [relationship-api.md](relationship-api.md) before reading capability-sensitive results or mutating a relationship.

## External Blockers

Record an external blocker in the current State Reason while work is in `needs-info`, or as an explicit Package Contract note when it blocks execution after packaging. Reading a delivery unit includes both locations and their related receipts. An unresolved external blocker makes the unit unpickable and must not be represented as a native dependency edge.

## Ownership

A claim sets one owner only when the delivery unit is unowned. Use the sole assignee plus the latest valid ownership receipt when the actor is assignable and no authoritative repository policy reserves assignees for another meaning. Use receipt-only ownership when either condition fails; the latest valid receipt determines the owner and the delivery unit has no assignee.

An explicitly approved release clears ownership; an explicitly approved override replaces it. Each transition appends the calling skill's durable receipt. For a PRD package, ownership covers the parent and every child without assigning children separately. Branches and pull requests are implementation evidence, not ownership.

An assignee on a receipt-only unit, an assignee/receipt mismatch, multiple delivery assignees, or conflicting latest receipts is ownership drift. Investigation ownership follows [wayfinding.md](wayfinding.md#investigation-ownership) and never grants delivery ownership.

## Receipts And Implementation Artifacts

Receipts are append-only comments on the record whose operation they evidence. Top-level stage receipts live on the original top-level issue or delivery unit; map publication and handoff receipts live on the map; investigation resolutions live on the investigation. The calling skill owns receipt content.

Use receipts for material turning points: State Reason changes, clarification decisions, Wayfinding publication and resolution, package publication, claim and approved ownership repair, implementation, review, verification, lifecycle outcome, and follow-up work.

Branches, commits, pull requests, CI, and reviews are implementation artifacts linked from receipts. Investigation assets remain planning evidence unless a Package Contract promotes them. Neither kind of artifact replaces workflow state or ownership.

## Lifecycle

Terminal outcomes include completed, rejected, duplicate, and superseded. Represent them with GitHub closed state plus the caller-owned completion or close-reason evidence. Remove active stage labels before or as the terminal operation requires.

## Finish Delivery

Keep the delivery-unit issue open with its active stage until the reviewed pull request reaches the authorized target. Then:

1. for a PRD package, close each contained child after verifying it belongs to the claimed package;
2. append the `and-finish` Completion receipt;
3. remove the active queue label; and
4. close the single package or parent PRD issue.

Complete a parent only after every claimed child requirement is integrated and every contained child is closed. Leave merely related work unchanged. If merge succeeds before lifecycle mutation completes, resume from the missing GitHub operation without repeating merge. Clean source artifacts only after completion evidence, label removal, and closed state verify.

## Invariants

- GitHub is the sole authority for workflow state.
- A delivery unit has at most one active stage and one current owner.
- A Wayfinding map has at most one active stage, carries no delivery ownership, and never carries `ready-for-agent`.
- PRD children and Wayfinding investigations carry no public stage.
- The claim unit equals the delivery unit; a parent PRD claim covers every child.
- Investigation ownership covers one investigation and never becomes delivery ownership.
- Containment, map membership, dependency, external blocker, and State Reason retain distinct meanings.
- An unresolved external blocker makes a delivery unit unpickable.
- Implementation artifacts are evidence rather than workflow state or ownership.
- Lifecycle outcomes are terminal rather than active queue state.
- A completed delivery unit has implementation on its authorized target and completion evidence in GitHub.
- Delivery cleanup follows authoritative lifecycle completion.

## Boundaries

- This skill defines and locates shared workflow rules; it does not run a workflow stage.
- `setup-and` owns missing readiness prerequisites; workflow skills route incomplete repository readiness there.
- Calling skills own their decisions, confirmation gates, receipt bodies, and user-facing reports.
- Keep every normative rule in one authority and load conditional mechanics only at the branch that needs them.
