---
name: issue-pick
description: Pick agent-ready delivery units and recommend one claimable unit.
disable-model-invocation: true
---

# Issue Pick

Pick is a read-only recommendation step. It chooses one unblocked, unclaimed delivery unit from ready work and stops before claim.

Do the full evidence check, but keep the user-facing output to a compact recommendation.

## Backend Contract

Before listing or reading ready work, read `.and/config.yml`, then use `ai-native-backend-contract`.

Use the configured backend reference for locating ready delivery units and reading source-of-truth state. If setup is missing, unsupported, or the backend contract is unavailable, stop and route to `setup-ai-native-development` or ask the user to install the missing skill.

Do not infer backend labels, ownership receipts, assignees, comments, child relationships, blockers, or implementation artifacts inside this skill.

## Delivery Units

A delivery unit is either:

- a single issue package; or
- a parent PRD package plus all children.

PRD children are internal execution slices under the parent claim, not independent public pick targets. If the user points at a child, evaluate the parent PRD package.

Child-to-child blockers inside one PRD package express implementation order. They do not block picking the parent PRD package.

## Pickability

### Hard Gates

A delivery unit is not pickable unless it is:

- open;
- `ready-for-agent`;
- a public delivery unit;
- unclaimed;
- free of open external blockers;
- free of contradictory public stage state;
- free of active implementation evidence that would create duplicate-work risk.

### Quality Gates

A pickable delivery unit must also have:

- a Package Contract;
- current and desired behavior;
- enough scope boundaries to implement without guessing;
- acceptance criteria;
- verification strategy;
- out of scope;
- coherent parent/child structure when it is a PRD package.

If a hard gate fails, do not recommend the candidate. If a quality gate fails, route to `issue-pack`. If missing human or external input blocks readiness, route to `issue-triage`. If state, ownership, or relationship drift blocks readiness, route to `issue-sweep`.

## Ranking

Rank by execution readiness, not business priority.

Prefer candidates with stronger boundedness, clearer Package Contract, better testability or verification path, fewer blockers, lower ownership risk, coherent PRD structure, stronger repository relevance, and smaller integration uncertainty.

Do not rank by recentness alone, issue number, perceived shortness, unrecorded business value, or personal preference. If the remaining choice is truly product priority, risk acceptance, or business judgment, say so instead of pretending.

## Process

1. Resolve repository and focus.
   - Determine the repository and configured backend from the user's target, current directory, remotes, repository docs, or recent context.
   - If the user supplied a label, milestone, project view, component, issue number, or PRD parent, use it as the initial focus.
   - Ask one direct question only when multiple repositories remain plausible.
   - Completion criterion: the repository, backend, and slate boundary are explicit.

2. Build the ready slate.
   - Locate ready delivery units through the backend reference.
   - Include single issue packages.
   - Include parent PRD packages and group child records under their parent.
   - Use explicit limits or pagination.
   - Record query boundary internally.
   - Completion criterion: the slate contains public ready delivery units, with excluded categories summarized by semantic reason.

3. Filter hard blockers.
   - Remove work that is not open, not ready, not a public delivery unit, claimed, externally blocked, contradictory, terminal, rejected, or carrying active implementation duplicate-work risk.
   - Remove PRD children as standalone candidates.
   - Completion criterion: remaining candidates satisfy the hard gates, or the report can name why no candidate is pickable.

4. Read full evidence for candidates.
   - Start with the strongest candidate by ranking.
   - For a single issue package, read the Package Contract, stage/lifecycle, ownership evidence, blockers, linked references, attachments, material comments or receipts, prior implementation attempts, and linked implementation artifacts.
   - For a PRD package, read the parent Package Contract, all child slices, child ordering blockers, external blockers, linked implementation artifacts, completion rule, and material parent/child comments or receipts.
   - Inspect material images, screenshots, recordings, logs, and attachments.
   - Check linked issues or PRs when they carry requirements, duplicate context, prior attempts, active implementation, or evidence that the work is already done.
   - If evidence invalidates the candidate, return to the slate and try the next plausible candidate.
   - Completion criterion: the recommended candidate has been checked against source-of-truth body, comments or receipts, Package Contract, blockers, ownership, relationships, attachments, and linked implementation evidence.

5. Validate claim readiness.
   - Verify Package Contract completeness, verification strategy, out of scope, PRD parent/child coherence, absence of partial claim, absence of external blocker, and absence of linked active implementation conflict.
   - Route broken candidates instead of fixing them.
   - Completion criterion: the delivery unit can be safely handed to `issue-claim`, or the smallest route-back blocker is named.

6. Report a recommendation.
   - Output one recommended pick.
   - Include only action-relevant evidence.
   - If no pickable unit exists, name the best candidate and smallest blocker.
   - Stop before claim.
   - Completion criterion: the user knows the recommended delivery unit and can run `issue-claim`, or knows which skill should repair the best candidate.

## Report Shape

For a successful recommendation:

```markdown
Recommended pick: <single issue package or PRD package>
Why:
- <1-3 readiness reasons>

Claim unit: <issue, or parent PRD + all children>
Source of truth: <link or work ID>
Next: `issue-claim`
```

For PRD packages, add only when useful:

```markdown
PRD children: <count and short list>
Internal order: <only if non-trivial>
```

For real risks, add only one concise line:

```markdown
Watch-out: <owner risk, blocker edge, relationship concern, or evidence gap>
```

If no delivery unit is pickable:

```markdown
No pickable delivery unit found.

Best candidate: <work>
Blocker: <smallest blocker>
Recommended route: <issue-pack, issue-triage, issue-sweep, wait, or human decision>
```

Do not output implementation summaries, full Package Contract summaries, every rejected candidate, or empty optional sections. Only compare candidates when the user asks for a slate review.

## Boundaries

- Do not mutate workflow state: no claims, assignments, labels, comments, edits, branches, PRs, closure, or repairs.
- Do not pick PRD children independently.
- Do not pick blocked, claimed, drifted, or under-specified delivery units.
- Do not rewrite scope or synthesize implementation requirements; route broken packages to `issue-pack`.
- Do not invent business priority when backend evidence only supports execution readiness.
