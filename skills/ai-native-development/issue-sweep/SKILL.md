---
name: issue-sweep
description: Audit AI-native issue workflow drift and stale work.
disable-model-invocation: true
---

# Issue Sweep

Sweep audits the configured workflow backend for drift that would make pick, claim, or implementation unsafe. It reports actionable findings and applies only approved low-risk cleanup.

Sweep is not triage, pick, pack, claim, or implementation.

## Backend Contract

Before auditing, read `.and/config.yml`, then use `ai-native-backend-contract`.

Use the configured backend reference for locating work, reading workflow state, applying backend-specific sweep checks, and applying approved cleanup. If setup is missing, unsupported, or the backend contract is unavailable, stop and route to `setup-ai-native-development` or ask the user to install the missing skill.

Do not infer backend labels, frontmatter, relationships, ownership records, receipts, or lifecycle representation inside this skill.

## Sweep Scope

Default to open work in the current repository.

Ask before sweeping a large, destructive, cross-repository, or ambiguous scope. Use explicit limits or pagination.

Supported scopes include current repo, specific issue or work ID, ready slate, `needs-info`, claimed work, PRD packages, stale claims, and all open work.

Completion criterion: scope, backend, query, and limit or pagination strategy are explicit.

## Audit Domains

### Stage And Lifecycle Drift

- more than one public stage state;
- open top-level work or parent PRD with no known queue state;
- `ready-for-agent` combined with waiting states;
- closed or terminal lifecycle with active stage state;
- `needs-info` without a current State Reason;
- malformed State Reason fields;
- `needs-info` with newer activity that may satisfy or obsolete the State Reason.

### Package And Relationship Drift

- PRD child parent link missing or inconsistent;
- parent PRD child list incomplete or inconsistent;
- child slice with public stage state;
- PRD child marked `ready-for-agent`;
- containment duplicated in body text when the backend has native containment;
- dependency used to express parent/child containment;
- parent PRD used as blocker for children merely because it is parent;
- ready PRD parent with incomplete child structure.

### Ownership And Implementation Drift

- PRD child claimed without parent;
- PRD package partially claimed;
- conflicting ownership signals;
- stale claim;
- active branch, draft PR, or PR exists while work appears unclaimed;
- claimed delivery unit has no implementation activity past the stale threshold;
- implementation artifact is recorded as source of truth instead of evidence.

### Blocker And Resume Drift

- ready delivery unit has an open external blocker;
- external blocker exit criteria appears satisfied;
- blocker owner is no longer current;
- State Reason resume skill no longer matches activity;
- missing reporter or maintainer input has arrived but work remains waiting;
- blocker is represented as dependency when it is actually external state, or vice versa.

### Backend-Specific Drift

Apply the configured backend reference's sweep checks, such as GitHub-native label, relationship, and comment invariants or markdown-file-based frontmatter, ID, and receipt invariants.

## Repair Policy

Report before editing. Apply only low-risk fixes approved in this run, or fixes the user explicitly requested with clear target and risk.

Low-risk fixes may include:

- removing public stage state from PRD children;
- removing clearly contradictory duplicate active stage state;
- adding raw entry state to obviously unstaged open work when repository convention requires it;
- adding a setup-required child coverage note when containment is already clear.

High-risk actions require explicit approval or route to the correct skill:

- close work;
- release stale claim;
- override owner;
- remove blocker;
- mark ready;
- change scope;
- convert package shape;
- create children;
- rewrite dependency graph;
- decide product priority.

## Process

1. Resolve scope.
   - Determine repository and configured backend.
   - Determine the sweep subset from the user request.
   - Default to open work in the current repo.
   - Ask before large or ambiguous scope.
   - Choose explicit limits or pagination.
   - Completion criterion: scope, query, backend, and pagination strategy are explicit.

2. Collect workflow state.
   - Read work records in scope.
   - Read stage state, lifecycle, current State Reason, comments or receipts, containment, dependencies, external blockers, ownership, linked implementation artifacts, updated time, activity, close status, and completion evidence.
   - For markdown-file-based, derive ownership from claim receipts and treat ownership frontmatter as drift.
   - Completion criterion: the audit set is complete for the declared scope, or inaccessible data is named.

3. Check invariants.
   - Apply every relevant audit domain.
   - Apply the configured backend reference's sweep checks.
   - Skip only when the backend lacks that feature or the repository has no convention.
   - Record skipped checks only when the skip affects confidence.
   - Completion criterion: every relevant invariant has been checked, or skipped with a reason that affects the report.

4. Report findings.
   - Group findings by severity.
   - Omit empty groups.
   - For each finding, include work link or ID, observed state, expected state, evidence, impact, and route or safe fix.
   - Completion criterion: the user can approve safe fixes or route each finding without rereading the whole backend state.

5. Apply approved low-risk fixes.
   - Apply only fixes explicitly approved in this run or requested with clear target and risk.
   - Use the configured backend reference.
   - Do not expand from the approved list.
   - Report applied fixes and remaining findings.
   - Completion criterion: applied fixes match the approved list, and remaining findings have routes or explicit no-action status.

## Report Shape

When there are no findings:

```markdown
No workflow drift found.

Scope checked: <query and count>
Backend: <github-native or markdown-file-based>
```

When there are findings, include only groups that have findings:

```markdown
Scope checked: <query and count>
Backend: <github-native or markdown-file-based>

Blocks execution:
- <work>: <observed> -> <expected>
  Evidence: <fact>
  Impact: <why it blocks pick/claim/implement>
  Route: <skill or approval needed>

Risks duplicate work:
- <work>: <observed> -> <expected>
  Evidence: <fact>
  Impact: <duplicate or ownership risk>
  Route: <skill or approval needed>

Metadata cleanup:
- <work>: <observed> -> <expected>
  Safe fix: <yes/no and why>

Candidate follow-up:
- <work>: <reason>
  Route: <issue-triage, issue-grill, issue-pack, issue-claim, human approval, wait, or no action>
```

When fixes are applied, append:

```markdown
Applied fixes:
- <work>: <fix>

Remaining:
- <work>: <route or risk>
```

Do not output empty groups, all passed checks, full issue bodies, long raw backend dumps, or unapproved fix plans as if they happened.

## Boundaries

- Do not triage, pack, pick, claim, implement, close, merge, or decide product priority inside sweep.
- Do not change scope, package shape, dependency intent, blocker status, lifecycle outcome, or ownership without explicit approval.
- Do not release or override claims unless explicitly approved.
- Do not apply fixes that were not reported and approved for this run.
- Do not create new workflow rules inside sweep findings; route changes to the owning workflow skill, backend contract, or backend reference.
