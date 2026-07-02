---
name: issue-sweeper
description: Audit AI-native issue workflow drift and stale work.
disable-model-invocation: true
---

# Issue Sweeper

Sweeper audits tracker drift. It finds contradictions and stale workflow state; it does not decide product priority or implement fixes.

## Drift checks

Check for:

- more than one active queue label
- open ordinary issue or parent PRD with no known queue state
- PRD child with an active queue label
- PRD child marked `ready-for-agent`
- PRD child claimed without its parent PRD
- parent PRD whose child issues are missing parent links
- Markdown task lists duplicating GitHub sub-issues
- parent PRD used as a blocker for its children
- `ready-for-agent` delivery unit with an open external blocker
- claimed delivery unit with no activity past the repository stale threshold
- parent PRD whose children are all closed
- `needs-info` with new reporter or maintainer activity

## Process

1. Resolve sweep scope.
   - Determine repository, tracker, and issue subset from the user request.
   - Default to open issues in the current repository.
   - Ask before sweeping a large or ambiguous tracker.
   - Completion criterion: scope, query, and limit or pagination strategy are explicit.

2. Collect issue data.
   - Fetch labels, state, assignees, comments, linked PRs, parent/sub-issues, blockers, updated time, and close status.
   - Use explicit pagination or limits.
   - Completion criterion: the audit set is complete for the declared scope, or gaps are named.

3. Check invariants.
   - Apply every drift check above.
   - Skip a check only when the tracker lacks that feature or the repository has no convention for it.
   - Completion criterion: every relevant invariant has been checked or explicitly skipped with a reason.

4. Report before editing.
   - Group findings by severity:
     - blocks execution
     - risks duplicate work
     - metadata cleanup
     - candidate closure
   - For each finding, include issue link, observed state, expected state, and recommended skill or fix.
   - Completion criterion: the user can approve fixes without rereading the entire tracker.

5. Apply low-risk fixes only after confirmation.
   - Low-risk fixes may include removing contradictory labels, removing active queue labels from PRD children, adding a missing state label that is unambiguous, or closing a parent PRD when all children are closed and repository convention allows it.
   - Do not close controversial issues, change scope, remove blockers, release claims, or override active owners without explicit approval.
   - Completion criterion: applied fixes match the approved list and remaining findings are reported.

## Report shape

```markdown
Scope: <query and count>

Blocks execution:
- <issue>: <observed> -> <expected>

Risks duplicate work:
- <issue>: <observed> -> <expected>

Metadata cleanup:
- <issue>: <observed> -> <expected>

Candidate closures:
- <issue>: <reason>

Recommended next skills:
- <issue>: <skill>
```

## Boundaries

- Do not implement work.
- Do not decide product priority.
- Do not override active owners without explicit approval.
- Do not turn audit findings into new process rules; update the workflow docs separately when rules change.
