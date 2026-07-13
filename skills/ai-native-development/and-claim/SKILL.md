---
name: and-claim
description: Claim an executable delivery unit without changing its scope.
disable-model-invocation: true
---

# AND Claim

Claim records one owner for one whole executable delivery unit without changing scope. Invocation authorizes an ordinary safe claim after current evidence is validated.

## Backend Contract

Before claiming, read `.and/config.yml`, then use `and-backend-contract`.

Use `Read Delivery Unit` for the current source of truth, then `Record Ownership` for one logical claim and `Reference Implementation Artifact` when existing evidence must be linked. Record Ownership and the durable Claim receipt are one logical mutation; do not emit duplicate ownership evidence. The backend contract and configured reference own how current ownership, receipts, and implementation artifacts are represented and derived. If setup is missing, unsupported, or unavailable, stop and route to `setup-and` or ask the user to install the missing skill.

## Atomic Claim Unit

A claim unit is either:

- one single issue package; or
- one parent PRD package plus all child slices.

If the user points at a PRD child, resolve and validate the parent delivery unit. Record ownership on the public delivery unit; for a PRD, one parent ownership record covers every child. Internal delegation may allocate child work, but it does not create child ownership or reduce the parent owner's responsibility.

## Claimability

The fresh `Read Delivery Unit` must show an open `ready-for-agent` public delivery unit with an executable Package Contract, coherent PRD structure, and no contradictory waiting state, open external blocker, current owner, or active implementation evidence that creates duplicate-work risk. The requested claim must preserve the published scope.

Route package or verification defects to `and-pack`, missing human or external input to `and-triage`, ownership, relationship, or artifact drift to `and-sweep`, and a target-selection problem to `and-pick`.

Implementation artifacts are evidence, not owner records. Existing non-conflicting evidence can be linked in the claim; evidence with unclear or competing ownership or intent must be reconciled before mutation.

## Confirmation

Apply the claim without another confirmation when the target, claimant, whole-unit boundary, permission, and current ownership state are unambiguous.

Pause only when judgment or authority is missing: the target, claimant, or unit is ambiguous; ownership is existing, stale, partial, or contradictory; implementation evidence creates unresolved duplicate-work risk; backend access is unclear; or the write would overwrite unrelated maintainer text. Releasing or overriding ownership is a high-risk Sweep repair and requires explicit approval there.

Confirmation cannot make unready, externally blocked, partial-PRD, or scope-changing work claimable. Route those defects to their owning stage.

## Process

1. **Resolve and validate.** Resolve the actor and complete claim unit, following a child to its parent when needed. If a Pick report exists, confirm the target matches it, but rely on a fresh `Read Delivery Unit`. Inspect material linked implementation evidence and apply Claimability.
   - Completion criterion: one unchanged whole delivery unit and one claimant are known, and the unit is currently safe to claim.

2. **Record atomic ownership.** Immediately re-read ownership and active implementation evidence, then record ownership once on the public delivery unit through the configured backend. The durable Claim receipt names every covered child for a PRD; do not write separate child claims. Link existing non-conflicting artifacts as evidence only.
   - Completion criterion: the configured backend shows one owner for the whole delivery unit, with no separate child owner. If a backend mutation is partial, stop, report the exact state, and route the drift to `and-sweep`.

3. **Report the receipt.** Return the claim link or work ID, owner, whole unit, and `and-implement`. Mention existing implementation evidence only when it affects the handoff.
   - Completion criterion: an implementation agent can start from the durable claim and backend source of truth without a second ownership interpretation.

## Claim Receipt

Record this content using the configured backend's receipt placement and append rules:

```markdown
## Claim

Claimed by: <actor>
Claim unit: <single package, or parent PRD plus every child ID>
Previous ownership: <unclaimed on the immediate pre-write read>
Implementation evidence: <none or non-conflicting artifact references>
Internal delegation: <include only when present; parent owner remains authoritative>
Next: `and-implement`
```

The user-facing receipt is shorter:

```markdown
Claimed: <whole delivery unit>
Owner: <actor>
Source: <claim link or work ID>
Next: `and-implement`
```
