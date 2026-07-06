---
name: issue-sweep
description: Audit AI-native issue workflow drift and stale work.
disable-model-invocation: true
---

# Issue Sweep

Sweep audits tracker invariants. It finds contradictions, stale workflow state, and relationship drift that would make pick, claim, or implementation unsafe.

Sweep is not triage and not pick. When a finding needs value judgment, scope repair, packaging, ownership repair, or closure, route it to the right skill or to human approval.

## Drift checks

### Queue state drift

- more than one active queue label
- open top-level issue or parent PRD with no known queue state
- `ready-for-agent` combined with `needs-info` or `needs-pack`
- PRD child with an active queue label
- PRD child marked `ready-for-agent`

### Package structure drift

- PRD child whose parent link is missing or inconsistent
- parent PRD whose child links are incomplete or inconsistent
- Markdown task lists duplicating GitHub sub-issues
- parent PRD used as a blocker for its children
- parent PRD marked `ready-for-agent` while child structure is incomplete

### Ownership drift

- PRD child claimed without its parent PRD
- PRD package partially claimed through one or more children
- claimed delivery unit with no activity past the repository stale threshold
- claim comment, assignee, branch, or PR evidence that contradicts another ownership signal
- active PR exists while the linked delivery unit appears unclaimed

### Execution drift

- `ready-for-agent` delivery unit with an open external blocker
- `needs-info` with new reporter or maintainer activity
- parent PRD whose children are all closed while the parent remains open
- issue appears implemented or closed by PR while active queue labels remain

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
   - Keep the user-facing report focused on findings, not empty headings.
   - Group findings by severity:
     - blocks execution
     - risks duplicate work
     - metadata cleanup
     - candidate follow-up
   - For each finding, include issue link, observed state, expected state, evidence, impact, and recommended route or safe fix.
   - If a severity group has no findings, omit it.
   - Completion criterion: the user can approve fixes without rereading the entire tracker.

5. Apply low-risk fixes only after confirmation.
   - Low-risk fixes may include removing active queue labels from PRD children, removing clearly contradictory duplicate active queue labels, adding `needs-triage` to an obviously unlabeled open issue when the repository uses that entry label, or adding a parent child-coverage note when the relationship is already clear and repository setup requires it.
   - Do not close issues, change scope, remove blockers, release claims, override active owners, mark work `ready-for-agent`, convert issues into PRD packages, or create child issues without explicit approval.
   - Completion criterion: applied fixes match the approved list and remaining findings are reported.

## Report shape

Include only groups that have findings. If there are no findings, say so directly with the scope checked.

```markdown
Scope: <query and count>

Blocks execution:
- <issue>: <observed> -> <expected>
  Evidence: <fact>
  Route: <skill or approval needed>

Risks duplicate work:
- <issue>: <observed> -> <expected>
  Evidence: <fact>
  Route: <skill or approval needed>

Metadata cleanup:
- <issue>: <observed> -> <expected>
  Safe fix: <yes/no and why>

Candidate follow-up:
- <issue>: <reason>
  Route: <issue-triage, issue-grill, issue-pack, issue-claim, human approval, or no action>
```

## Boundaries

- Do not implement work.
- Do not decide product priority.
- Do not triage, pack, pick, claim, or close work inside the audit.
- Do not release stale claims without explicit approval.
- Do not override active owners without explicit approval.
- Do not turn audit findings into new process rules; update the workflow docs separately when rules change.
