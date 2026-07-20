---
name: and-pick
description: Pick agent-ready delivery units and recommend one claimable unit.
disable-model-invocation: true
---

# AND Pick

Pick recommends one claimable delivery unit from ready work. It is read-only: finish with one recommendation or the smallest route-back blocker, never a claim or repair.

## Workflow Contract

Use `and-workflow-contract` before reading ready work.

Use `Locate Work` to build the slate and `Read Delivery Unit` before recommending a candidate. The workflow contract owns stage, lifecycle, relationship, ownership, receipt, and implementation-artifact representation. If repository setup or the contract is unavailable, stop and route to `setup-and` or ask the user to install the missing skill.

## Delivery Unit

A delivery unit is either:

- one single issue package; or
- one parent PRD package plus all child slices.

If the user points at a PRD child, evaluate its parent delivery unit. Child-to-child blockers express internal implementation order and do not block picking the parent.

## Pickability

After `Read Delivery Unit`, a candidate must pass both gates:

- **State gate:** it is an open `ready-for-agent` public delivery unit with no current owner, open external blocker, contradictory public state, or active implementation evidence that creates duplicate-work risk.
- **Package gate:** its Package Contract supports implementation without guessing, including current and desired behavior, bounded scope, acceptance criteria, verification strategy, deployment constraints, out of scope, and coherent parent/child structure for a PRD package.

Route a failed package gate to `and-pack`, missing human or external input to `and-triage`, and state, relationship, ownership, or artifact drift to `and-sweep`. Pick does not repair a candidate.

## Ranking

Use authoritative slate evidence to choose which plausible candidate to inspect first, in this order:

1. **Execution certainty:** stronger boundedness, clearer acceptance, and a more observable verification path.
2. **Coordination safety:** less ownership, artifact, relationship, or internal-order uncertainty.
3. **Integration fit:** stronger repository relevance and lower integration uncertainty.

The final recommendation must pass both gates after a complete read. User-supplied labels, milestones, components, or parent IDs narrow the slate before ranking. Recentness, issue number, perceived shortness, unrecorded business value, and personal preference do not establish execution readiness. When a remaining tie requires product priority, risk acceptance, or business judgment, report the tie for human choice.

## Process

1. **Resolve the slate.** Identify the GitHub repository and any user-supplied focus. Ask one direct question only when multiple repositories remain plausible. Locate ready work with an explicit limit or pagination, group PRD children under their parent, and retain the query boundary internally.
   - Completion criterion: one bounded slate of public delivery units is available for gating.

2. **Rank, read, and gate.** Exclude candidates that fail on slate evidence, order the plausible remainder, then fully read the strongest candidate through `Read Delivery Unit` and apply both gates. Inspect linked evidence or attachments when they can change requirements, ownership, blockers, duplicate-work risk, or whether the work is already done. If evidence invalidates that candidate, continue to the next ranked candidate.
   - Completion criterion: one complete delivery unit is safe to hand to `and-claim`, or the best candidate's smallest blocker and owning route are known.

3. **Report.** Return only the action-relevant evidence and stop before claim.
   - Completion criterion: the user can run `and-claim` for the whole recommended unit, or can route the best candidate to its smallest repair step.

## Report Shape

For a recommendation:

```markdown
Recommended pick: <single issue package or parent PRD package>
Why: <1-3 execution-readiness reasons>
Claim unit: <single package, or parent PRD plus all children>
Source: <link or work ID>
Next: `and-claim`
```

Add `Watch-out: <material risk>` only when it can affect claim or implementation.

When nothing is pickable:

```markdown
No pickable delivery unit found.
Best candidate: <work>
Blocker: <smallest blocker>
Route: <and-pack, and-triage, and-sweep, wait, or human decision>
```

Do not copy the Package Contract, rejected slate, implementation summary, or empty optional sections into the report. Compare multiple candidates only when the user asks for the slate.
