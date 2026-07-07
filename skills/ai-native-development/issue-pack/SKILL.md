---
name: issue-pack
description: Pack worth-doing issue work into one executable delivery unit.
disable-model-invocation: true
---

# Issue Pack

Pack turns worth-doing work into one executable delivery unit: either a single issue package or a PRD package. It is the only AI-native workflow skill that creates `ready-for-agent` work.

## Backend Rule

Before packaging, read `.and/config.yml`, then use `ai-native-backend-contract` for the backend contract and configured backend reference. Use the configured backend reference for Package Contract publication, stage state, containment, dependencies, child records, receipts, and lifecycle representation.

If `ai-native-backend-contract` is unavailable, stop and ask the user to install it; do not infer backend rules.

If setup is missing or the backend value is unsupported, route to `setup-ai-native-development`. Do not copy backend mechanics into the package body; use the configured backend representation as the source of truth.

## Output Shapes

Choose one shape:

- **Single issue package**: the complete Package Contract lives in one delivery-unit record with `ready-for-agent`; no child records are created.
- **PRD package**: the complete Package Contract lives in one parent PRD with `ready-for-agent`; child records are internal execution slices for progress, ordering, delegation, and acceptance tracking.

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
- User-facing reports should be compact. Do the full packaging legwork, but show only the decision, material backend edits, blockers, and next step.
- Use the user's language for user-facing summaries. Keep issue numbers, labels, skill names, commands, and code identifiers literal.

## Blocked Route

If human judgment, reporter detail, permission, external access, acceptance input, or a decision interview blocks a correct package, stop and report:

- the exact blocker;
- recommended next state: `needs-info`;
- blocker owner: `reporter`, `maintainer`, `human`, `agent`, or `external-system`;
- resume with: `issue-triage`, `issue-grill`, or `issue-pack`;
- where `issue-pack` should resume after the blocker is resolved.

When backend edits are safe, also move the work back to `needs-info` and append a State Reason. Do not ask the blocker in chat from inside `issue-pack`.

Use `Owner: human` and `Resume with: issue-grill` for a structured decision interview. Use the accountable reporter, maintainer, agent, or external system as `Owner` for missing facts, access, external state, or acceptance input, and usually `Resume with: issue-triage` after that input arrives.

```markdown
## State Reason

State: needs-info
Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
Owner: <reporter, maintainer, human, agent, or external-system>
Question: <one specific question, decision, permission, external event, or acceptance gate>
Resume with: <issue-triage, issue-grill, or issue-pack>
Exit criteria: <what must be true before this delivery unit can leave needs-info>
```

## Process

1. Load the work.
   - Read the work body, comments or receipts, stage state, lifecycle state, State Reasons, containment, dependency relationships, linked implementation artifacts, attachments, triage notes, `issue-grill` notes, and any existing PRD.
   - Read relevant code, tests, docs, glossary, architectural decision records, and backend conventions when they materially affect the package.
   - Identify current behavior, desired outcome, constraints, domain terms, verification path, test seams or verification strategy, blockers, and unresolved decisions.
   - Prefer existing test seams and the highest practical seam that can verify the behavior. If a new seam or prefactoring is needed, make that explicit.
   - Completion criterion: every material fact, decision, blocker, and unknown from the workflow state is represented in the pack notes.

2. Check for decision blockers.
   - Prefer repository facts over asking the user.
   - When human product, domain, architecture, naming, or testing decisions block a correct package, stop and report the blocked route.
   - Do not replace `issue-grill` with an ad hoc interview.
   - Completion criterion: either no blocking decision remains, or the backend/report names `needs-info`, the exact decision, blocker owner, resume skill, and `issue-pack` resume point.

3. Choose the package shape.
   - Use a single issue package when one issue can carry the complete Package Contract.
   - Use a PRD package when the complete Package Contract needs child slices for progress, ordering, acceptance tracking, or internal subagent delegation.
   - Stop and report the blocked route when missing human or external input still blocks a correct package.
   - Completion criterion: exactly one output shape is selected, or the blocked route is reported with a specific question and resume point.

4. Draft the package.
   - For a single issue package, use the Package Contract template on the delivery-unit work record.
   - For a PRD package, use the Package Contract template on the parent PRD and the PRD child slice template for children.
   - Child records should be tracer-bullet vertical slices: narrow, complete paths through the system that are useful for progress, internal delegation, and acceptance tracking.
   - Do not create horizontal child records that only touch one layer. Each child slice should cross every relevant integration layer and be demoable or verifiable on its own.
   - If prefactoring is needed to make the change easy, make it an explicit decision or the first child slice.
   - A child record should be independently grabbable by a subagent working under the parent PRD claim, but `issue-pick` and `issue-claim` still treat the parent PRD as the public delivery unit.
   - Completion criterion: an implementation agent can start from the package without replaying the whole discussion.

5. Check publishability.
   - Do not reopen product, domain, architecture, naming, testing, access, acceptance, or scope decisions already resolved in workflow state or `issue-grill`.
   - If the draft exposes a new blocking decision, stop and report the blocked route instead of asking inside `issue-pack`.
   - Treat invocation as authorization to publish a package from confirmed workflow state.
   - Do not ask for confirmation before normal package backend edits: package body updates, stage-state changes, containment links, new child records, dependency links, or ownership-neutral metadata.
   - Ask before publishing only when the target work is ambiguous, publishing would overwrite unrelated maintainer text, backend permissions/access are unclear, or the package requires an unconfirmed human judgment.
   - Completion criterion: the package is publishable from existing confirmed state, or the blocked route is recorded in the backend when safe and reported.

6. Publish.
   - Remove conflicting active queue state.
   - For `github-native`, update the original issue for a single issue package and set `ready-for-agent`.
   - For `github-native`, mark a PRD parent `parent-prd` and `ready-for-agent`, create child issues without `ready-for-agent`, set GitHub parent/sub-issue relationships, and add blocked-by relationships only for true execution dependencies.
   - For `markdown-file-based`, update the work record into a single package or PRD package, create child files under `children/` when needed, set `stage: ready-for-agent` only on the public delivery unit, and write containment plus dependency frontmatter.
   - Publish child work in dependency order so blockers can reference real identifiers.
   - Do not duplicate containment relationships with task lists in the body.
   - Completion criterion: backend state expresses one executable delivery unit without contradiction.

7. Report.
   - Use a compact user-facing report.
   - Include links or work IDs, state changes, delivery unit shape, PRD package structure when present, blockers, verification path, and next skill.
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

### PRD Child Slice

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
- Do not re-ask decisions that `issue-grill` or workflow state already resolved.
- Do not publish a package while human decisions, a test seam or verification strategy, or verifiable acceptance criteria are missing.
- Do not publish while out of scope, package shape, child granularity, or dependency relationships are unclear.
- Do not treat file paths or line numbers as the specification.
- Do not create horizontal child records.
- Do not duplicate backend containment relationships with Markdown task lists.
- Do not mark PRD children `ready-for-agent`.
- Do not turn PRD children into public pick or claim targets unless they are split into standalone delivery units.
- Do not create blocker links merely because issues share a parent.
