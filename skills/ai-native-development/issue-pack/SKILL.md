---
name: issue-pack
description: Pack worth-doing issue work into one executable delivery unit.
disable-model-invocation: true
---

# Issue Pack

Pack turns worth-doing work into one executable delivery unit: either a single issue package or a PRD package. It is the only AI-native workflow skill that creates `ready-for-agent` work.

## Output Shapes

Choose one shape:

- **Single issue package**: the complete Package Contract lives in one issue with `ready-for-agent`; no child issues are created.
- **PRD package**: the complete Package Contract lives in one parent PRD with `parent-prd` and `ready-for-agent`; child issues are internal execution slices for progress, ordering, delegation, and acceptance tracking.

Both shapes require the same contract strength. A single issue package is not a lighter specification; it simply does not need child slices.

## Package Writing Rules

- Treat the published package as the implementation contract. The original issue and discussion are context.
- Synthesize known facts and decisions; do not run a new product interview inside `issue-pack`.
- Write behavioral contracts, not implementation procedures.
- Name key interfaces, types, commands, config shapes, and domain concepts when they define the contract.
- Avoid file paths and line numbers unless they are evidence.
- Acceptance criteria must be concrete and independently verifiable.
- Out of scope is required.
- User stories must be a numbered list that covers the package's meaningful actors, behaviors, edge cases, and acceptance-relevant scenarios. Use the shortest list that covers distinct behavior paths. Recommended story count: simple single issue package 1-3, normal single issue package 3-6, PRD package 6-12, larger PRD package more than 12 only when distinct actors, modes, edge cases, or acceptance paths require it. Each story uses this format: `As an <actor>, I want <feature>, so that <benefit>.`
- Testing decisions must name a test seam or verification strategy. Prefer existing seams and the highest practical seam; fewer seams are better when they still prove the behavior.
- Documentation proposals from `issue-grill` must become package requirements, acceptance criteria, or child slices. Do not apply them locally during pack.
- Prototype snippets may be included only when they express a decision more precisely than prose, such as a state machine, reducer shape, schema, type shape, or API payload shape. Keep only decision-rich parts, label them as prototype-derived, and do not paste a working demo.
- User-facing reports should be compact. Do the full packaging legwork, but show only the decision, material tracker edits, blockers, and next step.
- Use the user's language for user-facing summaries. Keep issue numbers, labels, skill names, commands, and code identifiers literal.

## Blocked Route

If human judgment, reporter detail, permission, external access, acceptance input, or a decision interview blocks a correct package, stop and report:

- the exact blocker;
- recommended next state: `needs-info`;
- blocker owner: `reporter`, `maintainer`, `human`, `agent`, or `external-system`;
- resume with: `issue-triage`, `issue-grill`, or `issue-pack`;
- where `issue-pack` should resume after the blocker is resolved.

When tracker edits are safe, also move the issue back to `needs-info` and append a Blocker block. Do not ask the blocker in chat from inside `issue-pack`.

Use `Owner: human` and `Resume with: issue-grill` for a structured decision interview. Use the accountable reporter, maintainer, agent, or external system as `Owner` for missing facts, access, external state, or acceptance input, and usually `Resume with: issue-triage` after that input arrives.

```markdown
## Blocker

Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
Owner: <reporter, maintainer, human, agent, or external-system>
Question: <one specific question, decision, permission, external event, or acceptance gate>
Resume with: <issue-triage, issue-grill, or issue-pack>
Exit criteria: <what must be true before this issue can leave needs-info>
```

## Process

1. Load the work.
   - Read the issue body, comments, labels, parent/sub-issues, blockers, linked PRs, attachments, triage notes, `issue-grill` notes, and any existing PRD.
   - Read relevant code, tests, docs, glossary, architectural decision records, and tracker conventions when they materially affect the package.
   - Identify current behavior, desired outcome, constraints, domain terms, verification path, test seams or verification strategy, blockers, and unresolved decisions.
   - Prefer existing test seams and the highest practical seam that can verify the behavior. If a new seam or prefactoring is needed, make that explicit.
   - Completion criterion: every material fact, decision, blocker, and unknown from the issue thread is represented in the pack notes.

2. Check for decision blockers.
   - Prefer repository facts over asking the user.
   - When human product, domain, architecture, naming, or testing decisions block a correct package, stop and report the blocked route.
   - Do not replace `issue-grill` with an ad hoc interview.
   - Completion criterion: either no blocking decision remains, or the tracker/report names `needs-info`, the exact decision, blocker owner, resume skill, and `issue-pack` resume point.

3. Choose the package shape.
   - Use a single issue package when one issue can carry the complete Package Contract.
   - Use a PRD package when the complete Package Contract needs child slices for progress, ordering, acceptance tracking, or internal subagent delegation.
   - Stop and report the blocked route when missing human or external input still blocks a correct package.
   - Completion criterion: exactly one output shape is selected, or the blocked route is reported with a specific question and resume point.

4. Draft the package.
   - For a single issue package, use the Package Contract template on the issue.
   - For a PRD package, use the Package Contract template on the parent PRD and the PRD child issue template for children.
   - Child issues should be tracer-bullet vertical slices: narrow, complete paths through the system that are useful for progress, internal delegation, and acceptance tracking.
   - Do not create horizontal child issues that only touch one layer. Each child slice should cross every relevant integration layer and be demoable or verifiable on its own.
   - If prefactoring is needed to make the change easy, make it an explicit decision or the first child slice.
   - A child issue should be independently grabbable by a subagent working under the parent PRD claim, but `issue-pick` and `issue-claim` still treat the parent PRD as the public delivery unit.
   - Completion criterion: an implementation agent can start from the package without replaying the whole discussion.

5. Check publishability.
   - Do not reopen product, domain, architecture, naming, testing, access, acceptance, or scope decisions already resolved in the issue thread or `issue-grill`.
   - If the draft exposes a new blocking decision, stop and report the blocked route instead of asking inside `issue-pack`.
   - Treat invocation as authorization to publish a package from confirmed issue state.
   - Do not ask for confirmation before normal package tracker edits: issue body updates, active queue label changes, parent/sub-issue links, new child issues, blocked-by/blocking links, or ownership-neutral metadata.
   - Ask before publishing only when the target issue is ambiguous, publishing would overwrite unrelated maintainer text, tracker permissions/access are unclear, or the package requires an unconfirmed human judgment.
   - Completion criterion: the package is publishable from existing confirmed state, or the blocked route is recorded in the tracker when safe and reported.

6. Publish.
   - Remove conflicting active queue labels.
   - For a single issue package, update the original issue and set `ready-for-agent`.
   - For a PRD package, mark the parent `parent-prd` and `ready-for-agent`, create child issues without `ready-for-agent`, set GitHub parent/sub-issue relationships, and add blocked-by relationships only for true execution dependencies.
   - Publish child issues in dependency order so child blockers can reference real issue identifiers.
   - Do not duplicate sub-issues with Markdown task lists.
   - Completion criterion: tracker state expresses one executable delivery unit without contradiction.

7. Report.
   - Use a compact user-facing report.
   - Include links, state and label changes, delivery unit shape, PRD package structure when present, blockers, verification path, and next skill.
   - Include decisions used only when they were newly material, surprising, or needed to explain the package.
   - Name `issue-pick` as the next skill when the package is ready.
   - For a blocked route, name the unresolved input and stop without naming `issue-pick`.
   - Completion criterion: the next actor can pick the ready delivery unit or resolve the named blocker without rereading the pack session.

## Templates

### Package Contract

```markdown
Category: <bug or enhancement>

Summary: <one-line behavior change>

## Problem / Current Behavior

Describe the current behavior or status quo from the user or system perspective.

## Solution / Desired Behavior

Describe the completed behavior from the user or system perspective, including important edge cases, error conditions, and boundaries.

## User Stories

A numbered list of user stories that covers distinct behavior paths, not a target word count.

Recommended story count:

- Simple single issue package: 1-3.
- Normal single issue package: 3-6.
- PRD package: 6-12.
- Larger PRD package: more than 12 only when distinct actors, modes, edge cases, or acceptance paths require it.

Each user story should use this format:

1. As an <actor>, I want <feature>, so that <benefit>.

Example:

1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending.

## Implementation Decisions

- <modules, interfaces, types, schemas, API contracts, commands, config shapes, interactions, architectural decisions, or domain concepts>

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

### PRD Parent

Use the Package Contract template on the parent PRD.

### PRD Child Issue

```markdown
## Parent

<parent PRD link>

## What to build

Describe the end-to-end behavior, not layer-by-layer work.

## User stories covered

- <numbered parent story references>

## Key interfaces

- <interfaces, types, commands, config shapes, or domain concepts>

## Acceptance criteria

- [ ] <criterion>

## Verification

Test seam or verification strategy:

## Documentation / domain updates

- <glossary, ADR, context, README, runbook, or none>

## Blocked by

None - can start immediately

## Out of scope
```

## Boundaries

- Do not claim or implement work.
- Do not replace `issue-grill` with an ad hoc interview.
- Do not re-ask decisions that `issue-grill` or the issue thread already resolved.
- Do not publish a package while human decisions, a test seam or verification strategy, or verifiable acceptance criteria are missing.
- Do not publish while out of scope, package shape, child granularity, or dependency relationships are unclear.
- Do not treat file paths or line numbers as the specification.
- Do not create horizontal child issues.
- Do not duplicate GitHub sub-issues with Markdown task lists.
- Do not mark PRD children `ready-for-agent`.
- Do not turn PRD children into public pick or claim targets unless they are split into standalone delivery units.
- Do not create blocker links merely because issues share a parent.
