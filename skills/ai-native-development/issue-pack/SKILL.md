---
name: issue-pack
description: Pack worth-doing issue work into one executable delivery unit.
disable-model-invocation: true
---

# Issue Pack

Pack turns worth-doing work into one executable delivery unit: either an ordinary ready issue or a PRD package. It is the only AI-native workflow skill that creates `ready-for-agent` work.

## Output Shapes

Choose one shape:

- **Ordinary issue**: one issue with an Agent Brief and `ready-for-agent`.
- **PRD package**: one parent PRD with `parent-prd` and `ready-for-agent`, plus child issues for progress, ordering, and acceptance tracking.

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
   - Identify current behavior, desired outcome, constraints, domain terms, verification path, blockers, and unresolved decisions.
   - Completion criterion: every material fact, decision, blocker, and unknown from the issue thread is represented in the pack notes.

2. Check for decision blockers.
   - Prefer repository facts over asking the user.
   - When human product, domain, architecture, naming, or testing decisions block a correct package, stop and report the blocked route.
   - Do not replace `grill-with-docs` with an ad hoc interview.
   - Completion criterion: either no blocking decision remains, or the report names `needs-info`, the exact decision, `grill-with-docs` as the next skill, and the resume point.

3. Choose the package shape.
   - Use an ordinary issue when one delivery unit can express the work.
   - Use a PRD package when the work needs a durable product description plus child slices for progress, ordering, or acceptance.
   - Stop and report the blocked route when missing human or external input still blocks a correct package.
   - Completion criterion: exactly one output shape is selected, or the blocked route is reported with a specific question and resume point.

4. Draft the package.
   - For an ordinary issue, use the Agent Brief template.
   - For a PRD package, use the PRD template for the parent and PRD child issue template for children.
   - Child issues should be tracer-bullet vertical slices: narrow, complete paths through the system that are useful for progress and acceptance tracking.
   - Avoid file paths and line numbers unless they are evidence. Behavior, interfaces, constraints, and acceptance criteria are the durable package.
   - Completion criterion: an implementation agent can start from the package without replaying the whole discussion.

5. Confirm the package before publishing.
   - Show the selected shape, scope, out of scope, verification path, and blockers.
   - For a PRD package, show child slices, child ordering blockers, merges, and splits.
   - Ask for confirmation before durable tracker edits unless the user already explicitly approved this exact package.
   - Completion criterion: the user approved the exact package or the blocked route is reported.

6. Publish.
   - Remove conflicting active queue labels.
   - For an ordinary issue, update the original issue and set `ready-for-agent`.
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

### Agent Brief

```markdown
## Agent Brief

Current behavior:

Desired behavior:

Scope:

Out of scope:

Acceptance criteria:

- [ ] <criterion>

Verification:
```

### PRD

```markdown
## Problem Statement

## Solution

## User Stories

1. As a <actor>, I want <capability>, so that <benefit>.

## Implementation Decisions

## Testing Decisions

## Out of Scope

## Further Notes
```

### PRD Child Issue

```markdown
## Parent

## What to build

## Acceptance criteria

- [ ] <criterion>

## Blocked by

None, or <issue link>
```

## Boundaries

- Do not claim or implement work.
- Do not replace `grill-with-docs` with an ad hoc interview.
- Do not mark PRD children `ready-for-agent`.
- Do not create blocker links merely because issues share a parent.
