---
name: and-claim
description: Claim an executable delivery unit without changing its scope.
disable-model-invocation: true
---

# AND Claim

Claim records ownership for one executable delivery unit. It does not change scope: the claim unit must be one single issue package, or one parent PRD package plus all children.

Treat invocation as authorization for an ordinary safe claim after validation.

## Backend Contract

Before claiming, read `.and/config.yml`, then use `and-backend-contract`.

Use the configured backend reference for reading ownership evidence, recording claims, and linking implementation artifacts. If setup is missing, unsupported, or the backend contract is unavailable, stop and route to `setup-and` or ask the user to install the missing skill.

Do not infer backend assignees, comments, receipts, ownership fields, labels, or artifact links inside this skill.

## Claim Unit

A claim unit is either:

- a single issue package; or
- a parent PRD package plus all children.

PRD children are internal execution slices, not public claim targets. If the user points at a child, resolve the parent PRD package and validate the whole package.

## Claimability

### Hard Gates

Do not claim unless the delivery unit is:

- open;
- `ready-for-agent`;
- a public delivery unit;
- free of contradictory waiting state;
- free of open external blockers;
- unclaimed;
- free of active implementation evidence that creates duplicate-work risk.

### Quality Gates

Route instead of claiming when:

- scope or Package Contract is weak;
- verification strategy is missing;
- PRD child structure is broken;
- ownership evidence is stale or contradictory;
- the requested claim would change scope.

Use `and-pack` for broken package shape or verification, `and-triage` for missing human or external input, `and-sweep` for stale or contradictory ownership and relationship drift, and `and-pick` when a different target is needed.

## Confirmation Gates

Apply an ordinary claim without confirmation when the target, claimant, delivery-unit boundary, and ownership state are clear.

Ask or route before applying ownership changes when:

- the target is ambiguous;
- the claimant is ambiguous;
- the delivery-unit boundary is unclear;
- existing ownership exists;
- stale ownership must be released or overridden;
- an active branch, draft PR, or PR creates duplicate-work risk;
- backend permission or access is unclear;
- applying the claim would overwrite unrelated maintainer text.

Hard blockers cannot be made safe by confirmation. Open external blockers, PRD child claims, unready work, and scope-changing claims must route back.

## Process

1. Resolve claim unit.
   - Identify whether the target is a single issue package or PRD package.
   - If following `and-pick`, compare the claim target to the pick report.
   - If the user points at a PRD child, resolve the parent PRD package.
   - Read parent and children for PRD packages.
   - Read stage, lifecycle, ownership, blockers, relationships, and linked artifacts.
   - Completion criterion: the complete delivery unit is named, and no child, parent, sibling, or related scope is hidden.

2. Validate claimability.
   - Apply hard gates.
   - Apply quality gates.
   - Inspect ownership evidence and active implementation artifacts.
   - Treat branches and PRs as implementation artifact evidence or duplicate-work risk, not as ownership source of truth.
   - Route broken state to the right skill.
   - Completion criterion: the claim is valid, or the report names the smallest route back to `and-pick`, `and-pack`, `and-sweep`, or `and-triage`.

3. Record claim.
   - Record ownership through the configured backend reference.
   - For a PRD package, the claim covers the parent and every child.
   - Record child coverage in the claim record.
   - Record internal delegation only as parent-owner delegation, not separate public ownership.
   - Link existing branch or draft PR only as implementation artifact evidence.
   - Do not invent backend fields or ownership labels outside the configured backend reference.
   - Completion criterion: the configured backend shows one clear owner for the whole delivery unit.

4. Report a receipt.
   - Include claim link or work ID, owner, claim unit, source of truth, material ownership or blocker risk when any, and next skill: `and-implement`.
   - Do not copy the full Package Contract, child record bodies, full claim record, implementation plan, or empty risk sections into chat.
   - Completion criterion: an implementation agent can start `and-implement` from the claim and backend source of truth.

## Claim Record

Use this claim record through the configured backend reference:

```markdown
## Claim

Claimed by: <actor>
Claim unit: <single issue package or PRD package>
Scope owner: <single issue package or parent PRD>
Children covered: <none or child record list>
External blockers checked: <none or list>
Existing ownership checked: <assignee, claim comment, claim receipt, or backend ownership record>
Implementation artifacts checked: <branch, draft PR, active PR, or none>
Internal delegation: <none or child slices delegated under this claim>
Expected next step: <and-implement>
```

Implementation artifacts are evidence, not owner records.

## Boundaries

- Do not change package scope during claim.
- Do not claim PRD children independently or partially claim a PRD package.
- Do not claim unready, blocked, already claimed, ambiguous, or scope-changing work.
- Do not release or override ownership without explicit approval.
- Do not treat branches or PRs as ownership source of truth; treat them as implementation artifact evidence or duplicate-work risk.
