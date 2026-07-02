---
name: issue-pick
description: Pick agent-ready GitHub issues or PRD packages and synthesize their full context into the next requirement.
disable-model-invocation: true
---

# Issue Pick

Pick chooses the next delivery unit from ready work. It is read-only: it gathers evidence, rejects unsafe candidates, and recommends one ordinary issue or one PRD package without claiming or editing tracker state.

## Delivery units

A delivery unit is one of:

- **Ordinary issue**: an open `ready-for-agent` issue that is not a PRD child
- **PRD package**: an open issue marked both `parent-prd` and `ready-for-agent`, plus all of its child issues

PRD children are not independent pick targets. If the user points at a child issue, read its parent and evaluate the parent PRD package.

## Pickable work

A delivery unit is pickable when it is:

- open
- `ready-for-agent`
- unclaimed
- free of open external blockers
- not carrying contradictory active queue labels
- specified enough to verify completion

Child-to-child blockers inside one PRD package express implementation order. They do not block picking the parent PRD package.

## Process

1. Resolve the repository and focus.
   - Determine the GitHub repository from the user's target, current directory, remotes, repository docs, or recent context.
   - If the user supplied a label, milestone, project view, component, issue number, or PRD parent, use it as the initial focus.
   - Ask one direct question only when multiple repositories remain plausible.
   - Completion criterion: the repository and slate boundary are explicit.

2. Build the delivery-unit slate.
   - List open `ready-for-agent` issues with number, title, labels, assignees, milestone, created time, updated time, comment count, and URL.
   - Use explicit limits or pagination; never rely on the `gh issue list` default.
   - Treat `parent-prd` issues as PRD packages.
   - Exclude PRD children as standalone candidates; include them only under their parent PRD package.
   - Exclude PRs, closed issues, external blockers, claimed work, active PRs, contradictory states, duplicates, rejected work, and external-dependency waits unless the user asked to inspect them.
   - Completion criterion: the report can state the query, limit or pagination, delivery units considered, and exclusion categories used.

3. Select candidates.
   - Rank by boundedness, testability, current repository relevance, absence of external blockers, and relation to nearby work.
   - Prefer one delivery unit.
   - Set aside work that appears to need product priority, account access, external service setup, risk acceptance, or business-rule decisions.
   - Completion criterion: selected candidates have reasons, and rejected categories have reasons.

4. Read full evidence.
   - For an ordinary issue, read title, body, labels, assignees, milestone, linked references, blockers, linked PRs, and every comment in chronological order.
   - For a PRD package, read the parent PRD, all children, child ordering blockers, external blockers, linked PRs, and comments on the parent and children.
   - Inspect material images, screenshots, recordings, logs, and attachments.
   - Check linked issues or PRs when they carry requirements, duplicate context, prior attempts, active implementation, or evidence that the work is already done.
   - Completion criterion: synthesized notes cover the delivery unit's body, comments, material attachments, blockers, children when present, and linked implementation evidence, or name the exact inaccessible evidence.

5. Synthesize the next requirement.
   - State desired behavior, known current behavior, constraints, acceptance checks, verification expectations, and out of scope.
   - For a PRD package, summarize the parent goal, child slice list, internal order, and parent-level completion rule.
   - If evidence contradicts the pick, return to the slate instead of forcing the candidate.
   - Recommend `issue-pack` when scope, PRD child structure, dependencies, or acceptance criteria are wrong.
   - Recommend `needs-info` when missing human or external input blocks safe execution.
   - Completion criterion: the requirement can guide claim and implementation without rereading the issue thread.

6. Report the pick and stop.
   - Use the pick report template.
   - If no delivery unit is pickable, name the best candidate and its smallest blocker.
   - Completion criterion: the user knows the recommended delivery unit and can run `issue-claim` or route the best candidate elsewhere.

## Pick report

```markdown
Recommended pick: <ordinary issue or PRD package>
Why now: <reason>
Claim unit: <single issue or parent PRD + children>
PRD context: <none or parent and child list>
Blockers checked: <none, internal order, or external blocker list>
Already claimed: <no or evidence>
Build or fix: <requirement summary>
Verification: <checks expected>
Out of scope: <boundaries>
Route back if: <condition needing issue-pack or needs-info>
```

## Boundaries

- Do not implement, edit files, open a PR, assign issues, change labels, or change milestones.
- Do not pick PRD children independently.
- Do not pick blocked, claimed, or contradictory delivery units.
- Do not choose work only because it is first, recent, or short.
- Do not ask the user to choose among delivery units until tracker evidence leaves a real product, priority, permission, or scope decision.
