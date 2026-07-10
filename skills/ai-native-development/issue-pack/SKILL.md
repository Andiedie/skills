---
name: issue-pack
description: Pack worth-doing issue work into one executable delivery unit.
disable-model-invocation: true
---

# Issue Pack

Pack turns `needs-pack` work into one executable delivery unit: either a single issue package or a PRD package. It publishes the Package Contract and is the only AI-native workflow skill that creates `ready-for-agent` work.

## Backend Contract

Before packaging, read `.and/config.yml`, then use `ai-native-backend-contract`.

Use the configured backend reference for all reads and writes. If setup is missing, unsupported, or the backend contract is unavailable, stop and route to `setup-ai-native-development` or ask the user to install the missing skill.

Do not infer backend labels, frontmatter, child identifiers, containment, dependency, receipt, lifecycle, or stage-state mechanics inside this skill.

## Package Shapes

- **Single issue package**: one delivery-unit record carries the complete Package Contract and `ready-for-agent`; no child records are created.
- **PRD package**: the parent PRD carries the complete Package Contract and `ready-for-agent`; child records are internal execution slices for progress, ordering, delegation, and acceptance tracking.

Both shapes require the same contract strength. A single issue package is not a lighter specification; it simply does not need child slices.

## Package Contract Quality Bar

- The published package is the implementation contract; original issue text and chat are context.
- Synthesize confirmed facts and decisions. Do not run a product interview inside `issue-pack`.
- Write behavioral contracts, not implementation procedures.
- Name key interfaces, types, commands, config shapes, API payloads, domain terms, and architectural decisions when they define the contract.
- Avoid file paths and line numbers unless they are evidence or location hints.
- Acceptance criteria, verification strategy, and out of scope are required.
- User stories must be numbered and use `As an <actor>, I want <feature>, so that <benefit>.`
- Use story counts as coverage guidance, not a word-count target: simple single issue package 1-3, normal single issue package 3-6, PRD package 6-12, larger PRD package more than 12 only when distinct actors, modes, edge cases, or acceptance paths require it.
- Documentation proposals from `issue-grill` must become package requirements, acceptance criteria, or child slices. Do not apply them locally during pack.
- Decision-rich snippets may be included only when they express a confirmed decision more precisely than prose, such as a state machine, reducer shape, schema, type shape, or API payload shape. Keep only the contract-bearing excerpt.

## Stop Routes

Stop when a correct package needs missing human judgment, reporter facts, permission, external access, acceptance input, or a structured decision interview.

When backend edits are safe, route the work to `needs-info` through the configured backend and record a State Reason with `Cause`, `Owner`, `Question`, `Resume with`, and `Exit criteria`.

Use `issue-grill` for unresolved product, domain, architecture, naming, or testing decisions. Use the accountable owner for reporter facts, access, external state, or acceptance input.

Do not ask the blocker in chat from inside `issue-pack`; record the blocker and stop.

## Process

1. Load source of truth.
   - Read the work body, comments or receipts, latest State Reason, triage notes, `issue-grill` notes, existing PRD or package, containment and dependency relationships, blockers, linked implementation artifacts, and attachments.
   - Read relevant code, tests, docs, domain glossary, architectural decision records, and backend conventions only when they materially affect the package.
   - Completion criterion: the pack notes can name current behavior, desired behavior, constraints, confirmed decisions, unknowns, blockers, and verification path.

2. Check package blockers.
   - Verify facts locally before asking.
   - Distinguish unknown facts from human judgment.
   - Route missing decisions to `issue-grill`.
   - Route missing facts, access, external state, or acceptance input to the accountable owner.
   - Do not continue with guessed decisions.
   - Completion criterion: either no blocker remains, or the backend/report names the blocker, owner, resume skill, exit criteria, and where `issue-pack` should resume.

3. Choose package shape.
   - Use a single issue package when one work record can carry the complete Package Contract.
   - Use a PRD package when child slices are needed for progress, ordering, delegation, or acceptance tracking.
   - Choose by delivery boundary and verification needs, not by rough size alone.
   - Completion criterion: exactly one package shape is chosen for a reason tied to delivery boundary and verification, or the work is routed back with the missing decision.

4. Draft the Package Contract.
   - Use the Package Contract template for both single issue packages and PRD parents.
   - For PRD packages, create child slices with the PRD Child Slice template.
   - By default, child slices must be tracer-bullet vertical slices: narrow, complete paths through the system that are demoable or verifiable on their own.
   - A wide refactor is possible only when one mechanical change has a blast radius that prevents ordinary vertical slices from landing green. When and only when that trigger is present, read [wide-refactors.md](wide-refactors.md) and use its package shape.
   - Do not use wide-refactor guidance merely because work is large, cross-cutting, or touches many files.
   - If prefactoring is needed, make it an explicit implementation decision or the first child slice.
   - Child slices may be independently grabbable by subagents working under the parent PRD claim, but the parent PRD remains the public pick and claim target.
   - Completion criterion: an implementation agent can start from the package without replaying the discussion, and every child slice maps to parent stories, acceptance, and verification.

5. Publish through the configured backend.
   - Treat invocation as authorization to publish a package from confirmed workflow state.
   - Ask before publishing only when the target work is ambiguous, publishing would overwrite unrelated maintainer text, backend permissions or access are unclear, or the package requires an unconfirmed human judgment.
   - Publish the selected package through the configured backend reference.
   - Set public ready state only on the delivery unit.
   - Write containment and dependency relationships through the backend reference.
   - Publish child work in dependency order when backend identifiers are needed.
   - Do not duplicate backend containment relationships in package body text.
   - Completion criterion: the configured backend expresses one executable delivery unit with no contradictory stage, containment, dependency, blocker, or ownership-neutral metadata.

6. Report a receipt.
   - Include package link or work ID, package shape, state change, PRD child count and order summary when present, blocker when blocked, verification path, and next skill.
   - Name `issue-pick` when the package is ready.
   - For a blocked route, name the unresolved input and stop without naming `issue-pick`.
   - Do not copy the full Package Contract, full child bodies, full acceptance checklist, pack working notes, or tracker body back into chat.
   - Completion criterion: the user knows what was published, where it lives, and whether the next step is `issue-pick` or a blocker route.

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

## Acceptance Criteria

- [ ] <criterion>

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

## Acceptance criteria

- [ ] <criterion>

## Verification

<test seam or verification strategy>

## Documentation / domain updates

- <glossary, ADR, context, README, runbook, or none>

## Out of scope
```

## Boundaries

- Do not claim or implement work.
- Do not publish ready work while required decisions, acceptance criteria, verification strategy, or delivery boundary are missing.
- Do not silently change confirmed scope.
- Do not make PRD children public pick or claim targets.
- Do not duplicate backend relationship representation in package bodies.
