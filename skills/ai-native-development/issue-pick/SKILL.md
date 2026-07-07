---
name: issue-pick
description: Pick agent-ready delivery units and recommend one claimable unit.
disable-model-invocation: true
---

# Issue Pick

Pick chooses the next delivery unit from ready work. It is read-only: it gathers evidence, rejects unsafe candidates, and recommends one single issue package or one PRD package without claiming or editing workflow state.

## Backend Rule

Before listing or reading ready work, read `.and/config.yml`, then use `ai-native-backend-contract` for the backend contract and configured backend reference. Use the configured backend reference for locating ready delivery units, reading Package Contracts, relationships, external blockers, ownership, receipts, and implementation artifacts.

If `ai-native-backend-contract` is unavailable, stop and ask the user to install it; do not infer backend rules.

If setup is missing or the backend value is unsupported, route to `setup-ai-native-development`.

## Delivery units

A delivery unit is one of:

- **Single issue package**: an open `ready-for-agent` work record that is not a PRD child
- **PRD package**: an open parent PRD with `ready-for-agent`, plus all of its child records

PRD children can be independently-grabbable execution slices inside a claimed PRD package, but they are not independent pick targets. If the user points at a child record, read its parent and evaluate the parent PRD package.

## Pickable work

A delivery unit is pickable when it is:

- open
- `ready-for-agent`
- unclaimed
- free of open external blockers
- not carrying contradictory public stage state
- backed by a Package Contract
- carrying a verification strategy and out of scope
- carrying explicit documentation or domain update requirements when the Package Contract requires them
- specified enough to implement and verify completion

For a PRD package, child slices must be coherent, linked to the parent, not independently `ready-for-agent`, and not partially claimed.

Child-to-child blockers inside one PRD package express implementation order. They do not block picking the parent PRD package.

## Report Style

A compact pick report is not a shortcut through the evidence. Do the full slate, blocker, ownership, relationship, and package-contract checks, then report only what helps the user act.

Use the user's language for user-facing output. Keep issue numbers, labels, skill names, commands, and code identifiers literal.

## Process

1. Resolve the repository and focus.
   - Determine the repository and configured backend from the user's target, current directory, remotes, repository docs, or recent context.
   - If the user supplied a label, milestone, project view, component, issue number, or PRD parent, use it as the initial focus.
   - Ask one direct question only when multiple repositories remain plausible.
   - Completion criterion: the repository and slate boundary are explicit.

2. Build the delivery-unit slate.
   - List open `ready-for-agent` delivery units with ID, title, stage state, ownership, updated time, available discussion or receipt count, and URL or path.
   - For `markdown-file-based`, derive ownership from the latest valid claim receipt.
   - Use explicit limits or pagination.
   - Treat parent PRD work as PRD packages.
   - Exclude PRD children as standalone candidates; include them only under their parent PRD package.
   - Exclude PRs, closed issues, external blockers, claimed work, active PRs, contradictory states, duplicates, rejected work, and external-dependency waits unless the user asked to inspect them.
   - Completion criterion: the report can state the query, limit or pagination, delivery units considered, and exclusion categories used.

3. Select candidates.
   - Rank by execution readiness: boundedness, contract clarity, testability or verification path, current repository relevance, absence of external blockers, absence of owner, and PRD package coherence.
   - Prefer one delivery unit.
   - Do not invent business priority. Set aside work that appears to need product priority, account access, external service setup, risk acceptance, or business-rule decisions.
   - Completion criterion: selected candidates have reasons, and rejected categories have reasons.

4. Read full evidence.
   - For a single issue package, read title, Package Contract, stage state, lifecycle state, ownership, linked references, blockers, linked implementation artifacts, attachments, prior implementation attempts, close or reopen history when relevant, and every comment or receipt in chronological order.
   - For `markdown-file-based`, read ownership from claim receipts, not package frontmatter.
   - For a PRD package, read the parent Package Contract, all child slices, child ordering blockers, external blockers, linked implementation artifacts, completion rule, and comments or receipts on the parent and children.
   - Inspect material images, screenshots, recordings, logs, and attachments.
   - Check linked issues or PRs when they carry requirements, duplicate context, prior attempts, active implementation, or evidence that the work is already done.
   - Completion criterion: synthesized notes cover facts, assumptions, blockers, unresolved questions, verification evidence, body, comments, material attachments, children when present, and linked implementation evidence, or name the exact inaccessible evidence.

5. Validate claim readiness.
   - Verify that the Package Contract contains desired behavior, known current behavior, constraints, acceptance checks, verification expectations, and out of scope.
   - Verify that key interfaces and documentation or domain update requirements are present when the package depends on them.
   - For a PRD package, verify the parent goal, child slice list, internal order, children covered by the claim unit, and parent-level completion rule.
   - If evidence contradicts the pick, return to the slate instead of forcing the candidate.
   - Recommend `issue-pack` when the Package Contract, scope, PRD child structure, dependencies, acceptance criteria, verification strategy, or out of scope are wrong.
   - Recommend `issue-triage` to record a `needs-info` State Reason when missing human or external input blocks safe execution.
   - Recommend `issue-sweep` when stale claims, contradictory labels, or relationship drift block a clean pick.
   - Completion criterion: the delivery unit can be safely claimed, and the implementation source of truth remains the configured backend work record or parent PRD package.

6. Report the pick and stop.
   - Use the compact pick report template.
   - Include optional sections only when they contain real information or risk.
   - If no delivery unit is pickable, name the best candidate and its smallest blocker.
   - Completion criterion: the user knows the recommended delivery unit and can run `issue-claim` or route the best candidate elsewhere.

## Pick report

```markdown
Recommended pick: <single issue package or PRD package>
Why this is ready:
- <evidence-based reason>

Claim unit: <issue or parent PRD + all children>

PRD children: <child list; PRD packages only>
Internal order: <child blocker order; include only when non-trivial>

Source of truth:
- <issue link, work ID, or parent PRD link>

Next step: `issue-claim`
```

Only include these sections when they are useful:

```markdown
Why not the others:
- <brief exclusion summary or slate boundary>

Blockers checked:
- <external blocker evidence>

Owner risk:
- <claimed, stale, or contradictory ownership evidence>

Route back if:
- <condition -> skill or state>
```

If no delivery unit is pickable:

```markdown
No pickable delivery unit found.

Best candidate: <single issue package or PRD package>
Blocker: <smallest blocker>
Recommended route: <issue-pack, issue-triage, issue-sweep, or wait>
```

## Boundaries

- Do not implement, edit files, open a PR, assign issues, change labels, or change milestones.
- Do not pick PRD children independently.
- Do not pick blocked, claimed, or contradictory delivery units.
- Do not choose work only because it is first, recent, or short.
- Do not repack or rewrite scope; route broken packages to `issue-pack`.
- Do not treat child-level internal ordering as an external blocker on the parent PRD package.
- Do not ask the user to choose among delivery units until backend evidence leaves a real product, priority, permission, or scope decision.
