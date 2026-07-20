---
name: and-pack
description: Pack worth-doing work into one executable delivery unit.
disable-model-invocation: true
---

# AND Pack

Pack synthesizes confirmed work into one executable delivery unit and publishes its Package Contract. It is the only AND workflow skill that creates `ready-for-agent` work.

Ordinary source work becomes its package. A clear Wayfinding map hands off to one separate package; the map and its investigations remain planning evidence.

## Workflow Authority

Use `and-workflow-contract` for `Publish Package`, `Write Relationships`, `Write Stage State`, `Write State Reason`, and `Hand Off Wayfinding Map`. Read [wayfinding.md](../and-workflow-contract/wayfinding.md) for map handoff and [relationship-api.md](../and-workflow-contract/relationship-api.md) before native relationship mutation. Pack owns Package Contract and Map Handoff receipt content; the workflow contract owns representation, identity, relationships, lifecycle mechanics, and operation recovery.

If GitHub workflow state or the contract is unavailable, stop and route to `setup-and` or ask the user to install the missing skill.

## Contract Standard

A package is either:

- a **single issue package**, where one work record carries the complete Package Contract; or
- a **PRD package**, where the parent carries the same complete Package Contract and child slices provide internal progress, ordering, delegation, and acceptance boundaries.

Both shapes have equal contract strength. For either shape:

- Treat the published Package Contract as the implementation source of truth; source text and discussion remain context.
- Synthesize confirmed facts and decisions. Pack does not run a product interview.
- Describe current and desired behavior, not an implementation procedure.
   - Write a comprehensive, numbered user-story list whose coverage determines its length: include every distinct actor, mode, edge case, failure, and acceptance path. Use `As an <actor>, I want <feature>, so that <benefit>.`
- Name key interfaces, types, commands, config shapes, API payloads, domain terms, and architectural decisions when they constrain delivery.
- Record confirmed implementation, documentation, testing, and deployment decisions, including the highest practical verification seam and relevant prior art.
- Record confirmed target-environment, DDL or DML, rollout-order, mixed-version, recovery, and stable-runbook constraints when they affect safe implementation. Pack records `none known` when no constraint is confirmed; it does not predict the final Deployment disposition.
- Make acceptance criteria behavioral, concrete, and independently verifiable. Include out of scope.
- Use file paths only as evidence or location hints. Include a decision-rich snippet only when it expresses a confirmed state machine, reducer, schema, type, or payload decision more precisely than prose.

The contract is complete only when an implementation agent can begin without replaying the discussion, every story is covered by behavioral acceptance and a verification path, and every deployment-constraint category records a confirmed constraint or `none known`.

## Process

1. **Gather the complete source.**
   - Read the work body, comments and receipts, latest State Reason, triage and clarification decisions, existing package text, relationships, blockers, implementation artifacts, and attachments.
   - Inspect code, tests, docs, runbooks, the domain glossary, ADRs, and GitHub workflow conventions only where they change the contract.
   - For a Wayfinding source, use `Read Wayfinding Map` and `Hand Off Wayfinding Map` to recover its destination, decisions, resolved investigations, fog, scope boundary, linked assets, and any interrupted handoff. A replacement carrying a handoff key resumes that source map.
   - Completion criterion: every desired behavior is grounded in a source fact or confirmed decision, every remaining unknown is explicit, and current behavior, constraints, verification clues, blockers, and handoff state are known.

2. **Resolve blockers, verification, and shape.**
   - Verify discoverable facts locally. Missing human judgment, reporter facts, permission, access, external state, acceptance input, or a testing or deployment decision required for safe implementation blocks packaging.
   - Route product, domain, architecture, naming, testing, rollout, or deployment-risk judgment through `and-triage`. Route other missing input to its accountable owner. Use `Write Stage State` to route the work to `needs-info`, record the wait with `Write State Reason`, then stop.
   - A Wayfinding source returns to `and-wayfind` while any investigation or in-scope fog remains. Proceed only when it carries `needs-pack`, every completed investigation has a durable resolution, and every linked asset has a cleanup or Package-promotion disposition. Use the handoff operation to detect an incomplete or competing replacement before allocating work.
   - Choose the highest practical verification seam. Use a single issue when one record is a sufficient delivery and verification boundary; use a PRD when internal slices are needed for progress, ordering, delegation, or acceptance.
   - Completion criterion: either one durable blocker names its owner, resume authority, and exit criteria with no ready publication, or no unresolved input remains and exactly one verification seam and package shape are justified. A map also meets every eligibility condition above and is free of competing handoffs.

3. **Write the contract and slices.**
   - Use the Package Contract template for both shapes. For a PRD, write child slices with the PRD Child Slice template and a separate dependency graph.
   - Default to tracer-bullet children: each is a narrow, complete path through the affected system that is demoable or verifiable on its own. Containment expresses package structure; dependency expresses actual execution order.
   - If prefactoring is needed, make it an explicit implementation decision or the first child.
   - A wide refactor is available only when one mechanical form fans out so broadly that no ordinary vertical slice can land green. When all parts of that trigger hold, read [wide-refactors.md](wide-refactors.md).
   - Child slices may be delegated under the parent claim, while the parent remains the public pick and claim target.
   - For a Wayfinding source, link the source map in `Further Notes` and translate every promoted investigation asset into a requirement, decision, acceptance criterion, documentation update, or child slice.
   - Completion criterion: the Package Contract meets the Contract Standard, and every child maps to parent stories, key interfaces, behavioral acceptance, dependency intent, deployment contribution, and a declared verification path.

4. **Publish safely.**
   - Invocation authorizes publication from confirmed workflow state. Confirm only an ambiguous mutation target, overwrite of unrelated maintainer text, unclear GitHub authority or access, or unconfirmed human judgment.
   - Publish ordinary work in its existing record with `Publish Package`. Supply the full contract, ordered child bodies, semantic containment and dependency graph, and verification expectations; use the workflow contract's GitHub representation. If publication is partial or ambiguous, stop with the exact observed state and route it to `and-sweep` before retrying Pack.
   - For a clear map, run `Hand Off Wayfinding Map` with the Map Handoff receipt. Publish one separate replacement package and keep investigations as planning evidence.
   - Completion criterion: GitHub expresses exactly one executable delivery unit with the correct ready state, containment, dependencies, and no unresolved blocker or contradictory workflow state. A map handoff also has one verified replacement, complete Package promotion and asset disposition, and a completed source map; an interrupted map handoff remains recoverable and a competing handoff remains non-executable.

5. **Return a short receipt.**
   - Report the package link or ID, shape, state change, verification path, and next skill. For a PRD, include child count and dependency-order summary. For a map, include the source and handoff result.
   - Name `and-pick` only for ready work. For a blocked route, name the missing input and its resume authority.
   - Completion criterion: the user knows what changed, where the authoritative package lives, and the exact next route without receiving a duplicate Package Contract or child bodies in chat.

## Templates

### Package Contract

```markdown
Category: <bug, enhancement, or repository category>

Summary: <one-line behavior change>

## Problem / Current Behavior

## Solution / Desired Behavior

## User Stories

1. As an <actor>, I want <feature>, so that <benefit>.

## Key Interfaces / Domain Concepts

- <interfaces, types, commands, config shapes, API contracts, architectural decisions, or domain terms>

## Implementation Decisions

- <confirmed decisions that constrain implementation>

## Documentation / Domain Updates

- <glossary, ADR, context, README, runbook, or none>

## Testing / Verification Decisions

- Test seam or verification strategy:
- Highest practical seam:
- Prior art:
- Manual, visual, or operational acceptance:

## Deployment Constraints

- Target environments: <confirmed constraints or none known>
- DDL / DML / backfills: <confirmed constraints and identifiers, or none known>
- Configuration / secrets / infrastructure / external systems: <confirmed constraints or none known>
- Rollout order / compatibility: <confirmed constraints or none known>
- Rollback / forward-fix: <confirmed constraints or none known>
- Stable runbook: <link or none known>

## Acceptance Criteria

- [ ] <behavioral, independently verifiable criterion>

## Out of Scope

## Further Notes
```

### PRD Child Slice

```markdown
## What to build

<end-to-end behavior>

## User stories covered

- <parent story numbers>

## Key interfaces / domain concepts

- <interfaces, types, commands, config shapes, or domain terms>

## Dependency intent

<why execution must wait, or none; publish native relationship edges>

## Acceptance criteria

- [ ] <behavioral, independently verifiable criterion>

## Verification

<highest practical test seam or verification strategy>

## Documentation / domain updates

- <glossary, ADR, context, README, runbook, or none>

## Deployment Contribution

<confirmed data, configuration, infrastructure, external-system, or ordering contribution to the parent deployment handoff, or none known>

## Out of scope
```

### Map Handoff Receipt

Use only with `Hand Off Wayfinding Map` for a clear map:

Use operation namespace `and-pack-map-handoff:v1` with the workflow contract's durable-workflow identity algorithm. The handoff operation owns pending/completed evidence, exact-key recovery, and retry behavior.

```markdown
## Map Handoff

Source map: <link or work ID>
Handoff key: <workflow-contract key>
Handoff: <pending or completed>
Replacement package: <pending or link/work ID>
Package shape: <single issue or PRD package>
Ready state verified: <yes or pending reason>
Asset disposition: <none, promoted/cleaned list, or pending reason>
Map result: <completed or exact remaining operation>
```

## Boundary

Pack ends at one published or durably blocked delivery unit. Scope comes from confirmed inputs; `and-pick` and downstream skills own claim and implementation. Public readiness and ownership stay on the single package or PRD parent, while child slices remain internal. Native GitHub edges are the sole relationship representation. A Wayfinding map stays a planning record and hands off to a separate package; its investigations never become delivery slices.
