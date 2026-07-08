---
name: ask-andie
description: Router for the AI-native development loop.
disable-model-invocation: true
---

# Ask Andie

Ask Andie is the teaching router for the AI-native development loop. Use it when you need to know the current loop position, the next skill, or the rule that makes the route obvious.

Do more than route, but only a little. Teach one reusable rule so the user needs this skill less often next time.

## Relationship To Ask Matt

This follows Matt `ask-matt` as a user-invoked router: the user should not need to remember every skill.

AND adapts that idea to a workflow-state-backed loop. Routing is based on backend state, ownership, blockers, and delivery-unit shape.

## Backend Contract

When routing workflow-backed work, read `.and/config.yml`, then use `ai-native-backend-contract` for the configured backend.

If setup is missing, invalid, unsupported, or the backend contract is unavailable, route to `setup-ai-native-development`.

## Route Map

Main loop: `issue-intake` -> `issue-triage` -> `issue-grill` when needed -> `issue-pack` -> `issue-pick` -> `issue-claim` -> `issue-implement` -> close/learn.

Keep clarification and packaging in one context until the package is published. After a PRD package is claimed, its owner may use child records as subagent work units grounded in the parent PRD plus the child record.

| Surface / evidence | Route |
| --- | --- |
| New repo, missing `.and/config.yml`, invalid backend, or missing backend contract | `setup-ai-native-development` |
| Raw idea, bug report, screenshot, feedback, or note not yet tracked | `issue-intake` |
| Existing work with unclear state, new activity, duplicate or closure question, or missing State Reason | `issue-triage` |
| `needs-info` with `Resume with: issue-grill` or `Cause: decision-needed` | `issue-grill` |
| `needs-info` waiting for facts, access, external state, or acceptance | Route the State Reason question to its owner; resume with the recorded skill |
| `needs-pack` | `issue-pack` |
| Ready work slate with no chosen delivery unit | `issue-pick` |
| Specific ready single issue package or parent PRD package | `issue-claim` |
| Claimed delivery unit | `issue-implement` |
| Stale claim, partial PRD claim, relationship drift, contradictory state, or blocked ready work | `issue-sweep` |
| Local branch or diff tied to claimed work | `issue-implement` or the repository review/finish route |
| Local branch or diff not tied to workflow state | Ask whether to intake/triage it or treat it outside AND |

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

1. Identify the current surface: raw request, existing work, ready slate, specific delivery unit, claimed work, local branch/diff, backend drift, setup gap, or outside-AND work.
2. Check setup when workflow-backed routing is needed. If setup is missing or unsupported, route to `setup-ai-native-development`.
3. Read minimal routing evidence. The route should be justifiable with one or two facts.
4. Choose exactly one next skill, one owner question, or one setup/install route. Do not run the next workflow skill inside `ask-andie`.
5. Report the route and one teaching rule using the user's language. Keep skill names, labels, issue numbers, work IDs, commands, and code identifiers literal.

If the route is uncertain, choose the smallest clarifying route: `issue-triage` for unclear backend state, `issue-grill` for missing product or business decisions, `setup-ai-native-development` for missing repository rules, or one direct question when the user must decide.

## Output Shape

Use this compact route card:

```markdown
Current position: <stage or surface>
Next skill: <skill>
Why: <one sentence>
Rule to learn: <one sentence>
```

Add optional lines only when useful:

```markdown
Evidence: <routing facts>
Watch-out: <real blocker, claim, PRD child, stale state, or setup issue>
Human input needed: <one exact question>
Skip ask next time: <recognizable condition>
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
