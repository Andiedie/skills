# Acceptance Gate

Load this authority when a Package Contract contains `## Acceptance Gate`, or when
Finish decides a declared source-delivery boundary. This file is the single
authority for the declaration, receipt, selection, freshness, owner proof, and
recovery rules. A delivery unit has at most one gate.

## Omission and declaration

The gate is optional. A Package Contract that needs no source-delivery acceptance
omits `## Acceptance Gate`; that omission is the complete no-gate path. It creates
no acceptance handoff, receipt requirement, runtime access, or Finish work.

When acceptance is required, Pack publishes exactly one declaration:

```markdown
## Acceptance Gate

Timing: <pre-merge|post-merge>
Owner: <exact GitHub actor or durably verifiable authority>
Binding kind: <source-head|artifact>
Evidence expectation: <observable success condition and durable evidence>
```

`Timing` is the sole boundary selector. Its complete decision belongs in one table:

| Timing | Blocks | Allowed binding | Boundary evidence | Source-defect route |
| --- | --- | --- | --- | --- |
| pre-merge | merge | source-head or artifact | current reviewed PR/head | `and-implement` |
| post-merge | source completion | artifact | merged PR plus exact merge commit; receipt `created_at >= merged_at` | `and-intake` creates a new repair Issue; keep the original open; no second PR or merge; repair orchestration remains out of scope |

The declaration has no redundant boundary field. Pack validates the timing and
binding combination before readiness publication; an invalid or duplicate gate is
a Package or Clarify defect.

`Owner` is either the exact GitHub actor who will write the receipt or an authority
whose identity can be durably verified through its evidence. `Evidence expectation`
states the observable success condition and durable evidence the owner must leave.
The declaration names the decision; it does not record its result.

## Public Acceptance receipt

The declared owner appends one typed result as a comment on the public
delivery-unit Issue. A PRD child receives no separate Acceptance comment. The
receipt uses this shape:

```markdown
## Acceptance

Owner: <declared authority>
Timing: <declared timing>
Binding: source-head <full commit SHA> | artifact <immutable identity>
Boundary evidence: <current reviewed PR/head for pre-merge, or merged PR plus exact merge commit for post-merge>
Result: <accepted|rejected>
Evidence: <durable link or reference satisfying the Package expectation>
Side effects: <none, or exact evidence and the existing Cleanup/Deployment handoff that must be refreshed or resumed>
```

The receipt is append-only and contains one of each required field. Its `Owner`
and `Timing` match the declaration exactly. `Result` is `accepted` or `rejected`.
`Evidence` satisfies the declared expectation and is durable. Tests, review,
review attestation, Deployment, Cleanup, and rollout remain separate authorities
and cannot substitute for this result.

The receipt author proves the declared owner. A GitHub-actor owner must match the
comment author. Another authority must be durably identifiable through `Evidence`;
copying a name into `Owner` is not authority proof.

`Boundary evidence` proves the selected declaration row. It must satisfy that row's
evidence rule exactly; evidence from one timing row cannot satisfy the other.

`Side effects: none` means acceptance activity changed no operational fact and an
accepted receipt is directly consumable at its declared boundary. Otherwise the
field records exact evidence and names the existing Cleanup or Deployment
handoff that must be refreshed or resumed. Even an `accepted` result cannot
authorize that boundary until the named authority supplies current durable evidence
produced after the Acceptance comment, explicitly references that
comment, and proves the refresh or resume is complete and current. Finish applies
this barrier at either boundary; an unmet barrier routes `and-implement` to
refresh the handoff or waits for that handoff owner. No new receipt field,
inventory, deployment execution, or external write is introduced.

## Binding and freshness

The receipt's `Binding` is one exact value selected by the declaration:

- `source-head` is a full 40-character hexadecimal SHA. The current selected source
  head must equal it. Any selected-head change makes the receipt stale.
- `artifact` is one immutable identity retained with durable evidence. The current
  identity must equal it. Unrelated repository or environment activity does not
  stale an artifact receipt; only a selected-identity change does.

The caller proves the current binding from delivery-unit, source, pull-request, or
artifact evidence available at its boundary. A symbolic ref, abbreviated SHA,
mutable URL, or changing environment description is not an exact binding.

## Latest-only selection

Selection is deterministic and latest-only:

1. If the Package Contract omits the declaration, finish the delivery without an
   Acceptance operation.
2. Otherwise inspect comments on the public delivery-unit Issue and select the
   newest comment whose heading is exactly `## Acceptance`. A comment without that
   heading is history, not a candidate.
3. Parse the selected comment as one complete receipt, compare its declaration
   timing and binding, prove owner attribution and boundary evidence, and verify
   durable evidence and side-effect disposition. A duplicate heading or required
   field is malformed.
4. Use that candidate only when complete, matching, and current. A malformed,
   contradictory, stale, or `rejected` latest candidate blocks its declared
   boundary; no older accepted comment is eligible as fallback.

When no valid accepted or rejected latest receipt is available, pending is a
derived observation, not a stored result or state machine. A caller may retain the
precise reason—pending, malformed, contradictory, stale, or rejected—but never
persists a `pending` enum. Legacy free-text Acceptance history is not a typed
receipt and is never backfilled.

Pending waits for the declared `Owner` without mutating the selected boundary.

A stale Acceptance receipt alone blocks boundary and asks its declared owner for
a receipt on the current binding. Route to `and-implement` only when underlying
Implementation, review, Deployment, or Cleanup evidence is stale or defective;
do not turn Acceptance freshness into a second implementation route.

## Boundary consumption and recovery

`Validate Acceptance Gate` gives the gate no effect before the boundary selected by
the declaration table. At that boundary it validates the latest receipt, current
binding, owner proof, boundary evidence, durable evidence, and side-effect barrier.
A current accepted result releases the boundary; any unsatisfied result keeps it
closed without fallback. Pending and stale Acceptance use the owner actions above;
a source defect uses the declaration table; other defects use the recovery routes
below.

A completed boundary action is recovered from its durable evidence rather than
repeated. After any independent change to the selected binding, the owner may append
a new current receipt; this authority does not manage the independent work that
produced that change.

A Package or decision defect routes to `and-pack` or `and-clarify`. External
unavailability uses the existing `acceptance-needed` State Reason and its recorded
owner/resume route. After acceptance activity, refresh or resume [local-cleanup.md](local-cleanup.md)
for worktree-owned resources and [deployment-handoff.md](deployment-handoff.md) for
operational prerequisites. The Acceptance receipt does not repeat either inventory
or lifecycle.

## Caller boundaries

Pack owns whether one gate is needed and publishes its declaration. Implement hands
only a declared pre-merge gate to its owner and refreshes existing Cleanup or
Deployment evidence after acceptance activity. Finish calls this authority at the
current Finish boundary and performs only the returned stage action. Callers do not
copy this schema, selection, freshness, owner, or recovery rules.
