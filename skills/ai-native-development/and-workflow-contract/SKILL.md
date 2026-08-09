---
name: and-workflow-contract
description: Use when an AND skill needs to read, write, validate, or reason about GitHub workflow state.
---

# AND Workflow Contract

GitHub Issues, labels, native relationships, comments, and assignees are the authoritative workflow state for the AND delivery loop. Branches, commits, pull requests, CI, and review results are implementation artifacts linked from that state.

Use this always-loaded kernel before an AND workflow skill reads or mutates workflow state. The caller names the operation it is performing and loads only the direct references listed for that operation. Sibling references are terminal runtime authorities; they do not route to one another.

The calling skill owns its stage behavior and receipt wrapper. This contract owns shared concepts, GitHub representation, operations, invariants, and named shared-artifact schemas.

## Concepts And Representation

| Concept | Meaning | GitHub representation |
| --- | --- | --- |
| Work record | A durable record that may be raw, triaged, a Wayfinding map or investigation, packaged, a parent PRD, or a child slice. | GitHub issue. |
| Delivery unit | The public unit that can be picked, claimed, implemented, and completed: a single package or parent PRD package. | Single issue package, or parent PRD issue plus all native sub-issues. |
| Stage state | The active queue position of an open top-level work record. | One active queue label on an open top-level issue. |
| State Reason | The structured current reason a top-level work record is waiting in `needs-info`. | Latest issue comment headed `## State Reason`. |
| Package Contract | The implementation source of truth published by `and-pack`. | Body of the single issue package or parent PRD issue. |
| Deployment disposition | The reviewed-head-bound package classification `none`, `standard`, or `custom`. | `Deployment:` in the latest valid `## Implementation` receipt under the deployment-handoff selection rules. |
| Deployment Manifest | Package-specific operational guidance required only for `custom`. | `## Deployment Manifest` in that same valid Implementation receipt. |
| Cleanup handoff | The optional reviewed-head-bound declaration that supported typed cleanup items are handed to Finish. An omitted field is the valid no-handoff path. | `Cleanup: required` and its items, when present, in the latest valid `## Implementation` receipt under the local-cleanup selection rules. |
| Review attestation | Versioned evidence binding one paired AND review to exact code and Spec-authority inputs. | One `and-review-attestation/v1` JSON block embedded in the latest `## Implementation` receipt. |
| Containment relationship | Parent PRD and child-slice structure. | Native parent/sub-issue relationship under a parent carrying `parent-prd`. |
| Map relationship | Wayfinding map and investigation membership. | Native parent/sub-issue relationship under a parent carrying `wayfinder:map`. |
| Dependency relationship | Execution order between work records. | Native blocked-by/blocking relationship. |
| External blocker | Missing access, third-party state, human acceptance, or another wait outside the work-record graph. | Current State Reason while work is in `needs-info`, or an explicit blocking Package Contract note after packaging. |
| Ownership | Responsibility for the complete delivery unit. | Sole delivery-unit assignee plus the latest valid ownership receipt when assignment is available and allowed; otherwise the latest valid receipt. |
| Investigation ownership | Responsibility for one open investigation, never delivery ownership. | Exactly one assignee on an open investigation. |
| Receipt | Append-only evidence from a workflow stage. | Issue comment on the work record whose operation it evidences. |
| Lifecycle outcome | A terminal result such as completed, rejected, duplicate, or superseded. | GitHub closed state plus completion or close-reason evidence. |
| Implementation artifact | A branch, commit, PR, CI, or review result that evidences implementation. | Artifact linked from a receipt; never workflow state or ownership. |
| Wayfinding map | A shared planning index that holds destination, decisions, fog, and scope until packaging. It is not a delivery unit. | Top-level issue carrying `wayfinder:map`, with native sub-issues for investigations. |
| Investigation | One sharp question under a Wayfinding map, sized for one Agent session and carrying no public stage. | Native sub-issue carrying one Wayfinding method label. |
| Fog | In-scope uncertainty that cannot yet be phrased as a sharp investigation question. | Current map body under `## Not yet specified`. |
| Frontier | Open, unblocked, unclaimed investigations on a map. | Derived from current investigation lifecycle, dependency, and assignee state. |
| Investigation asset | Linked evidence produced to answer an investigation. Its lifecycle is method-specific: Research evidence may be cleaned or promoted by its disposition; a Prototype remains a primary source outside main and stays reachable through its context pointer. Neither form is workflow state or repository truth. | Method-specific evidence link in the investigation resolution. |

Repository files may describe the workflow but do not carry package state, ownership, relationships, or lifecycle outcomes.

## Relationship Vocabulary

| Relationship | Expresses | Does not express |
| --- | --- | --- |
| Containment | Parent PRD and child-slice structure. | Execution order. |
| Map | Wayfinding map and investigation membership. | Delivery packaging or ownership. |
| Dependency | Work-record execution order. | Parent/child structure. |
| External blocker | A wait outside the work-record graph. | A native dependency edge. |
| State Reason | Why top-level work currently waits in `needs-info`. | A permanent blocker log. |

The parent kind determines whether a parent/sub-issue edge is PRD containment or map membership. A parent is not a blocker for its children merely because it is the parent. Use blocked-by only for execution dependencies.

Native edges are the sole relationship representation; package bodies do not duplicate them as task lists. Cross-PRD dependencies connect the delivery units or child records that actually wait. Load `relationship-api.md` directly before reading capability-sensitive results or mutating a relationship.

## Read Discipline

Begin with the smallest current identity, lifecycle, stage, relationship, ownership, and authority-pointer projection that can choose the operation. Then load the direct operation reference and zoom into the complete selected authority only when that operation requires it.

Do not substitute low-resolution projections for the complete Package Contract, every acceptance-bearing PRD child, or the current authoritative receipt on a delivery path. Keep historical comments and raw API metadata retrievable rather than preloaded unless they can change authority, recovery, or the terminal result.

## Operation Index

| Operation | Direct authority to load |
| --- | --- |
| Read Setup Readiness | [setup-readiness.md](setup-readiness.md); add [wayfinding.md](wayfinding.md#representation) when the installed workflow includes Wayfinding and [relationship-api.md](relationship-api.md) when proving native relationship capability. |
| Locate Work | [work-records.md](work-records.md); add [delivery-units.md](delivery-units.md) when package, blocker, ownership, receipt, or implementation evidence can decide the route; add [wayfinding.md](wayfinding.md#read-a-map) or [sweep-checks.md](sweep-checks.md) only for those branches. |
| Read Work Record | [work-records.md](work-records.md). |
| Write Work Record | [work-records.md](work-records.md). |
| Resolve Canonical Identity | [work-records.md](work-records.md). |
| Read Delivery Unit | [work-records.md](work-records.md) and [delivery-units.md](delivery-units.md). |
| Read Wayfinding Map | [wayfinding.md](wayfinding.md#read-a-map). |
| Chart Wayfinding Map | [wayfinding.md](wayfinding.md#chart-a-map). |
| Resolve Investigation | [wayfinding.md](wayfinding.md#resolve-an-investigation). |
| Hand Off Wayfinding Map | [wayfinding.md](wayfinding.md#hand-off-a-clear-map). |
| Write Stage State | [work-records.md](work-records.md). |
| Write State Reason | [work-records.md](work-records.md). |
| Publish Package | [delivery-units.md](delivery-units.md). |
| Write Relationships | This kernel's relationship vocabulary and [relationship-api.md](relationship-api.md). |
| Record Ownership | [delivery-units.md](delivery-units.md). |
| Record Investigation Ownership | [wayfinding.md](wayfinding.md#investigation-ownership). |
| Record Receipt | This kernel for append-only representation and the caller for its receipt wrapper; add [delivery-units.md](delivery-units.md) when the receipt carries delivery ownership, implementation artifacts, deployment, an optional local-cleanup handoff, or Finish evidence. |
| Record Lifecycle Outcome | [work-records.md](work-records.md). |
| Reference Implementation Artifact | [delivery-units.md](delivery-units.md). |
| Read Deployment Handoff | [deployment-handoff.md](deployment-handoff.md). |
| Read Local Cleanup Handoff | [local-cleanup.md](local-cleanup.md). |
| Read Review Attestation | [review-attestation.md](review-attestation.md). |
| Finish Delivery | [work-records.md](work-records.md) and [delivery-units.md](delivery-units.md). |
| Audit Invariants | [sweep-checks.md](sweep-checks.md), plus only the direct operation authorities for the selected scope. |

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
- Every reviewed implementation handed to Finish has one authoritative Deployment disposition bound to its reviewed head.
- A `custom` disposition has exactly one authoritative Deployment Manifest in the same receipt; `none` and `standard` dispositions have none.
- A reviewed implementation may omit Cleanup when no worktree-owned local resource remains for Finish; an emitted Cleanup `required` handoff is bound to its reviewed head and contains only supported typed items.
- An omitted Cleanup field causes no resource-runtime access; a required handoff is consumed only through its typed rules.
- Lifecycle outcomes are terminal rather than active queue state.
- A completed delivery unit has implementation on its authorized target and completion evidence in GitHub.
- Typed local cleanup follows authoritative lifecycle completion and verifies before recovery-bearing source artifacts are removed.

## Boundaries

- This skill defines and locates shared workflow rules; it does not run a workflow stage.
- `setup-and` owns missing readiness prerequisites; workflow skills route incomplete repository readiness there.
- Calling skills own their decisions, confirmation gates, receipt wrappers, stage-specific fields, and user-facing reports; this contract owns named shared-artifact schemas.
- Keep every normative rule in one authority and load conditional mechanics only at the branch that needs them.
