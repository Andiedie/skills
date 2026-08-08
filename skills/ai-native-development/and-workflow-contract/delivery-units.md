# Delivery Units

Read this reference when an operation must validate, publish, own, implement, audit, or finish a delivery unit.

## Read At The Required Resolution

Begin with current identity and execution-safety pointers:

- issue number, open or closed lifecycle, active and structural labels, and assignees;
- parent and child identities and open or closed state;
- blocked-by identities and open or closed state;
- latest State Reason, Claim, Implementation, Completion, and ownership-repair headings and permalinks;
- linked branch, pull request, reviewed head, CI, and review identities when present.

Zoom in to the complete Package Contract and every acceptance-bearing PRD child before Pick, Claim, Implement, or Finish decides or mutates delivery. Load the complete current authoritative receipt selected by the operation, including its deployment and local-cleanup handoffs when reviewed implementation exists. Earlier receipts, historical comments, and raw API metadata stay retrievable and are loaded only when they can change authority, recovery, duplicate-work risk, or the terminal result.

## Package Shapes

### Single Issue Package

The issue body contains the complete Package Contract and carries `ready-for-agent`.

### PRD Package

The parent issue body contains the complete Package Contract and carries `parent-prd` plus `ready-for-agent`. Native sub-issues are internal execution slices and carry no active stage. The parent is the sole public pick, claim, and finish target.

## External Blockers

Record an external blocker in the current State Reason while work is in `needs-info`, or as an explicit Package Contract note when it blocks execution after packaging. Reading a delivery unit includes both locations and their related receipts. An unresolved external blocker makes the unit unpickable and must not be represented as a native dependency edge.

## Ownership

A claim sets one owner only when the delivery unit is unowned. Use the sole assignee plus the latest valid ownership receipt when the actor is assignable and no authoritative repository policy reserves assignees for another meaning. Use receipt-only ownership when either condition fails; the latest valid receipt determines the owner and the delivery unit has no assignee.

An explicitly approved release clears ownership; an explicitly approved override replaces it. Each transition appends the calling skill's durable receipt. For a PRD package, ownership covers the parent and every child without assigning children separately. Branches and pull requests are implementation evidence, not ownership.

An assignee on a receipt-only unit, an assignee/receipt mismatch, multiple delivery assignees, or conflicting latest receipts is ownership drift. Investigation ownership follows the Wayfinding authority and never grants delivery ownership.

## Receipts And Implementation Artifacts

Receipts are append-only comments on the record whose operation they evidence. Top-level stage receipts live on the original top-level issue or delivery unit; map publication and handoff receipts live on the map; investigation resolutions live on the investigation. The calling skill owns its receipt wrapper and stage-specific fields; this contract owns any named shared-artifact schema embedded in that receipt.

Use receipts for material turning points: State Reason changes, clarification decisions, Wayfinding publication and resolution, package publication, claim and approved ownership repair, implementation, review, verification, deployment or local-cleanup handoff, lifecycle outcome, and follow-up work.

Branches, commits, pull requests, CI, and reviews are implementation artifacts linked from receipts. Promoted Research evidence enters the Package Contract; other Research assets remain planning evidence under their disposition. Retained Prototype primary sources stay outside main and remain linked from the delivery unit. None of these artifacts replaces workflow state or ownership.

The latest `## Implementation` receipt is the sole candidate for its deployment and local-cleanup handoffs; an incomplete or mismatched latest receipt never falls back to an older one. A newer implementation head requires a new reviewed receipt with both dispositions, plus a Deployment Manifest only when Deployment is `custom`. Later deployment or cleanup evidence does not replace or mutate either handoff.

## Finish Delivery

Keep the delivery-unit issue open with its active stage until the reviewed pull request reaches the authorized target. Then:

1. for a PRD package, close each contained child after verifying it belongs to the claimed package;
2. append the `and-finish` Completion receipt;
3. remove the active queue label; and
4. close the single package or parent PRD issue.

Complete a parent only after every claimed child requirement is integrated and every contained child is closed. Leave merely related work unchanged. If merge succeeds before lifecycle mutation completes, resume from the missing GitHub operation without repeating merge. After completion evidence, label removal, and closed state verify, apply the authoritative local-cleanup handoff and retain recovery-bearing source artifacts until every required item verifies absent.
