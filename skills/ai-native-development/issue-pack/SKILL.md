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
- User stories must be a long enough numbered list to cover the package's meaningful actors and behaviors. Each story uses this format: `As an <actor>, I want <feature>, so that <benefit>.`
- Testing decisions must name a test seam or verification strategy. Prefer existing seams and the highest practical seam; fewer seams are better when they still prove the behavior.
- Prototype snippets may be included only when they express a decision more precisely than prose, such as a state machine, reducer shape, schema, type shape, or API payload shape. Keep only decision-rich parts, label them as prototype-derived, and do not paste a working demo.

## Blocked Route

If human judgment, reporter detail, permission, external access, acceptance input, or a decision interview blocks a correct package, stop and report:

- the exact blocker;
- recommended next state: `needs-info`;
- recommended next skill: `grill-with-docs` when a structured decision interview is needed, otherwise human or external input;
- where to resume in `issue-pack` after the blocker is resolved.

## Process

1. Load the work.
   - Read the issue body, comments, labels, parent/sub-issues, blockers, linked PRs, attachments, triage notes, and any existing PRD.
   - Read relevant code, tests, docs, glossary, architectural decision records, and tracker conventions when they materially affect the package.
   - Identify current behavior, desired outcome, constraints, domain terms, verification path, test seams or verification strategy, blockers, and unresolved decisions.
   - Prefer existing test seams and the highest practical seam that can verify the behavior. If a new seam or prefactoring is needed, make that explicit.
   - Completion criterion: every material fact, decision, blocker, and unknown from the issue thread is represented in the pack notes.

2. Check for decision blockers.
   - Prefer repository facts over asking the user.
   - When human product, domain, architecture, naming, or testing decisions block a correct package, stop and report the blocked route.
   - Do not replace `grill-with-docs` with an ad hoc interview.
   - Completion criterion: either no blocking decision remains, or the report names `needs-info`, the exact decision, `grill-with-docs` as the next skill, and the resume point.

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

5. Confirm the package before publishing.
   - Show the selected shape, scope, out of scope, verification path, test seams or verification strategy, and blockers.
   - Ask whether the Package Contract, test seam or verification strategy, acceptance criteria, and out of scope are correct.
   - For a PRD package, show child slices, child ordering blockers, user stories covered, parent completion rule, possible merges, and possible splits.
   - Ask whether child slice granularity and dependency relationships are correct.
   - Ask for confirmation before durable tracker edits unless the user already explicitly approved this exact package.
   - Completion criterion: the user approved the exact package or the blocked route is reported.

6. Publish.
   - Remove conflicting active queue labels.
   - For a single issue package, update the original issue and set `ready-for-agent`.
   - For a PRD package, mark the parent `parent-prd` and `ready-for-agent`, create child issues without `ready-for-agent`, set GitHub parent/sub-issue relationships, and add blocked-by relationships only for true execution dependencies.
   - Publish child issues in dependency order so child blockers can reference real issue identifiers.
   - Do not duplicate sub-issues with Markdown task lists.
   - Completion criterion: tracker state expresses one executable delivery unit without contradiction.

7. Report.
   - Include links, state and label changes, delivery unit shape, PRD package structure when present, blockers, verification path, and decisions used.
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

1. As an <actor>, I want <feature>, so that <benefit>.

Example:

1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending.

## Implementation Decisions

- <modules, interfaces, types, schemas, API contracts, commands, config shapes, interactions, architectural decisions, or domain concepts>

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

## Blocked by

None - can start immediately

## Out of scope
```

## Boundaries

- Do not claim or implement work.
- Do not replace `grill-with-docs` with an ad hoc interview.
- Do not publish a package while human decisions, a test seam or verification strategy, or verifiable acceptance criteria are missing.
- Do not publish while out of scope, package shape, child granularity, or dependency relationships are unclear.
- Do not treat file paths or line numbers as the specification.
- Do not create horizontal child issues.
- Do not duplicate GitHub sub-issues with Markdown task lists.
- Do not mark PRD children `ready-for-agent`.
- Do not turn PRD children into public pick or claim targets unless they are split into standalone delivery units.
- Do not create blocker links merely because issues share a parent.
