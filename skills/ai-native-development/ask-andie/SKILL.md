---
name: ask-andie
description: Router for the AI-native development loop.
disable-model-invocation: true
---

# Ask Andie

Ask Andie is the teaching router for the AI-native development loop. Use it when you need to know the current loop position, the next skill, or the rule that makes the route obvious.

Do more than route, but only a little. Teach one reusable rule so the user needs this skill less often next time.

## Backend Contract

When routing workflow-backed work, read `.and/config.yml`, then use `and-backend-contract` for the configured backend.

If setup is missing, invalid, unsupported, or the backend contract is unavailable, route to `setup-and`.

## Route Map

Main loop: `and-intake` -> `and-triage` -> `and-clarify` when needed -> `and-pack` -> `and-pick` -> `and-claim` -> `and-implement` -> `and-finish`.

Keep clarification and packaging in one context until the package is published. After a PRD package is claimed, its owner may use child records as subagent work units grounded in the parent PRD plus the child record.

| Surface / evidence | Route |
| --- | --- |
| Initial repository setup, a current Setup Contract gap, or an explicit request for a setup audit, repair, or full-ready check | `setup-and` |
| Untracked raw signal, including an external PR or local diff with no work record | `and-intake` |
| Existing work with unclear state, new activity, duplicate or closure question, or missing State Reason | `and-triage` |
| `needs-info` with `Resume with: and-clarify` or `Cause: decision-needed` | `and-clarify` |
| `needs-info` waiting for facts, access, external state, or acceptance | Route the State Reason question to its owner; resume with the recorded skill |
| `needs-pack` | `and-pack` |
| Ready work slate with no chosen delivery unit | `and-pick` |
| Unclaimed ready single issue package or parent PRD package with no active implementation evidence | `and-claim` |
| Claimed delivery unit whose implementation or review is incomplete, including its linked branch, diff, or pull request | `and-implement` |
| Reviewed delivery with no pending acceptance or blocker, including an in-progress finish with a completion proposal, merged pull request, incomplete lifecycle, or incomplete cleanup | `and-finish` |
| Implementation waiting on required acceptance or another external owner | Route the exact pending input to its accountable owner |
| Stale claim, partial PRD claim, relationship drift, contradictory state, or blocked ready work | `and-sweep` |

## Evidence Budget

Read only enough evidence to route:

- setup/config;
- stage and lifecycle;
- latest State Reason;
- ownership or claim evidence;
- blocker state;
- parent/child identity;
- linked implementation artifacts;
- current branch or diff when relevant.

Do not perform full triage, pick ranking, package validation, implementation planning, or sweep audit.

## When Invoked

1. Identify the current surface: raw request or external PR, existing work, ready slate, specific delivery unit, claimed work, local branch/diff, backend drift, setup gap, or explicit repository setup audit or repair request.
2. Check setup when workflow-backed routing is needed. If setup is missing or unsupported, route to `setup-and`.
3. Read minimal routing evidence. The route should be justifiable with one or two facts.
4. Choose exactly one next skill, one owner question, or one setup/install route. Do not run the next workflow skill inside `ask-andie`.
5. Report the route and one teaching rule using the user's language. Keep skill names, labels, issue numbers, work IDs, commands, and code identifiers literal.

If the route is uncertain, choose the smallest clarifying route: `and-triage` for unclear backend state, `and-clarify` for missing product or business decisions, `setup-and` for missing repository rules, or one direct question when the user must decide.

## Output Shape

Use this compact route card:

```markdown
Current position: <stage or surface>
Next: <skill or accountable owner action>
Why: <one sentence>
Rule to learn: <one sentence>
```

Add optional lines only when useful:

```markdown
Evidence: <routing facts>
Watch-out: <real blocker, claim, PRD child, stale state, or setup issue>
Human input needed: <one exact question>
```

Do not print empty optional sections. Do not include full issue bodies, full State Reasons, candidate lists, Package Contracts, child records, or implementation plans.

Completion criterion: the user can run one named skill next, or answer one concrete question that will make the next skill clear.

## Boundaries

- Do not edit workflow backend state.
- Do not run the next workflow skill from inside `ask-andie`; name it and stop.
- Do not synthesize requirements, package work, rank ready candidates, repair drift, claim, implement, close, merge, or release ownership.
- Do not decide product priority or business tradeoffs.
- Do not duplicate Package Contracts, issue bodies, child records, or full State Reasons in chat.
- Do not use `ask-andie` to bypass stage preconditions; route to the stage that owns the missing work.
