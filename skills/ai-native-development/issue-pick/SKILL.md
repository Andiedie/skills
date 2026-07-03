---
name: issue-pick
description: Pick agent-ready GitHub issues or PRD packages and synthesize their full context into the next requirement.
disable-model-invocation: true
---

# Issue Pick

Pick chooses the next delivery unit from ready work. It is read-only: it gathers evidence, rejects unsafe candidates, and recommends one single issue package or one PRD package without claiming or editing tracker state.

## Delivery units

A delivery unit is one of:

- **Single issue package**: an open `ready-for-agent` issue that is not a PRD child
- **PRD package**: an open issue marked both `parent-prd` and `ready-for-agent`, plus all of its child issues

PRD children can be independently-grabbable execution slices inside a claimed PRD package, but they are not independent pick targets. If the user points at a child issue, read its parent and evaluate the parent PRD package.

## Pickable work

A delivery unit is pickable when it is:

- open
- `ready-for-agent`
- unclaimed
- free of open external blockers
- not carrying contradictory active queue labels
- backed by a Package Contract
- carrying a verification strategy and out of scope
- specified enough to implement and verify completion

For a PRD package, child slices must be coherent, linked to the parent, not independently `ready-for-agent`, and not partially claimed.

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
   - Rank by execution readiness: boundedness, contract clarity, testability or verification path, current repository relevance, absence of external blockers, absence of owner, and PRD package coherence.
   - Prefer one delivery unit.
   - Do not invent business priority. Set aside work that appears to need product priority, account access, external service setup, risk acceptance, or business-rule decisions.
   - Completion criterion: selected candidates have reasons, and rejected categories have reasons.

4. Read full evidence.
   - For a single issue package, read title, Package Contract, labels, assignees, milestone, linked references, blockers, linked PRs, attachments, prior implementation attempts, close or reopen history when relevant, and every comment in chronological order.
   - For a PRD package, read the parent Package Contract, all child slices, child ordering blockers, external blockers, linked PRs, completion rule, and comments on the parent and children.
   - Inspect material images, screenshots, recordings, logs, and attachments.
   - Check linked issues or PRs when they carry requirements, duplicate context, prior attempts, active implementation, or evidence that the work is already done.
   - Completion criterion: synthesized notes cover facts, assumptions, blockers, unresolved questions, verification evidence, body, comments, material attachments, children when present, and linked implementation evidence, or name the exact inaccessible evidence.

5. Synthesize the next requirement.
   - State desired behavior, known current behavior, constraints, acceptance checks, verification expectations, and out of scope.
   - State key interfaces and where implementation should start when the Package Contract already says so.
   - For a PRD package, summarize the parent goal, child slice list, internal order, children covered by the claim unit, and parent-level completion rule.
   - If evidence contradicts the pick, return to the slate instead of forcing the candidate.
   - Recommend `issue-pack` when the Package Contract, scope, PRD child structure, dependencies, acceptance criteria, verification strategy, or out of scope are wrong.
   - Recommend `needs-info` when missing human or external input blocks safe execution.
   - Recommend `issue-sweeper` when stale claims, contradictory labels, or relationship drift block a clean pick.
   - Completion criterion: the requirement can guide claim and implementation without rereading the issue thread.

6. Report the pick and stop.
   - Use the pick report template.
   - If no delivery unit is pickable, name the best candidate and its smallest blocker.
   - Completion criterion: the user knows the recommended delivery unit and can run `issue-claim` or route the best candidate elsewhere.

## Pick report

```markdown
Recommended pick: <single issue package or PRD package>
Why this is ready: <evidence-based reason>
Why not the others: <brief exclusion summary or slate boundary>
Claim unit: <issue or parent PRD + all children>
Children covered: <none or child list>
Internal order: <none or child blocker order>
External blockers checked: <none or list>
Owner status: <unclaimed, claimed by ..., or possibly stale>
Package contract summary:
- Problem / current behavior:
- Desired behavior:
- Key interfaces:
- Acceptance criteria:
- Verification strategy:
- Out of scope:
Implementation handoff:
- Start with:
- Watch for:
Route back if:
- <condition -> skill or state>
```

If no delivery unit is pickable:

```markdown
No pickable delivery unit found.

Best candidate: <single issue package or PRD package>
Blocker: <smallest blocker>
Recommended route: <issue-pack, needs-info, issue-sweeper, issue-triage, or wait>
```

## Boundaries

- Do not implement, edit files, open a PR, assign issues, change labels, or change milestones.
- Do not pick PRD children independently.
- Do not pick blocked, claimed, or contradictory delivery units.
- Do not choose work only because it is first, recent, or short.
- Do not repack or rewrite scope; route broken packages to `issue-pack`.
- Do not treat child-level internal ordering as an external blocker on the parent PRD package.
- Do not ask the user to choose among delivery units until tracker evidence leaves a real product, priority, permission, or scope decision.
