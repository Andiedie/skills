---
name: ask-andie
description: Router for the AI-native development loop.
disable-model-invocation: true
---

# Ask Andie

Find the current position, name one next move, and teach one reusable rule. Read enough evidence to point; leave the move itself to the skill or owner that owns it.

## Workflow Contract

Use `and-workflow-contract` when routing depends on GitHub workflow state. Route incomplete repository setup or an unavailable contract to `setup-and`.

## Route Map

Main loop: `and-intake` -> `and-triage` -> `and-clarify` when a bounded decision space needs resolution -> `and-pack` -> `and-pick` -> `and-claim` -> `and-implement` -> `and-finish`.

`and-wayfind` is an on-ramp before `and-pack` when the destination is visible but the investigation path cannot yet be enumerated.

| Surface or evidence | Next move |
| --- | --- |
| Initial setup, a Setup Contract gap, or an explicit setup audit, repair, or full-ready check | `setup-and` |
| Required GitHub workflow state is inaccessible | Ask the accountable owner to restore the named access or service prerequisite |
| Untracked raw signal, including an external PR or local diff with no work record | `and-intake` |
| Existing work with unclear state, new activity, a duplicate or closure question, or a missing State Reason | `and-triage` |
| `needs-info` with `Resume with: and-clarify` | `and-clarify` |
| `needs-info` with `Resume with: and-wayfind` | `and-wayfind` |
| Map-shaped evidence without a recorded Wayfinding route | `and-triage` |
| `needs-info` waiting for facts, access, external state, or acceptance | Ask the State Reason owner; resume with its recorded skill |
| `needs-pack` | `and-pack` |
| Ready slate with no selected delivery unit | `and-pick` |
| Unclaimed ready single issue or parent PRD package with no active implementation evidence | `and-claim` |
| Claimed delivery unit with incomplete implementation or review | `and-implement` |
| Claimed PRD child used as an internal work unit | `and-implement` with the parent PRD and child record |
| Reviewed delivery with no pending acceptance or blocker, including an in-progress finish, merged implementation, incomplete lifecycle, or incomplete cleanup | `and-finish` |
| Implementation waiting on required acceptance or another external owner | Ask that accountable owner for the exact pending input |
| Stale or partial claim, relationship drift, contradictory state, or blocked ready work | `and-sweep` |

## Evidence Budget

Read the smallest evidence set that distinguishes the routes: setup readiness, stage and lifecycle, latest State Reason, ownership or claim, blockers and parent/child identity, linked implementation artifacts, and the current branch or diff when relevant. Stop when one route follows from one or two decisive facts.

Leave full triage, ready-work ranking, package validation, implementation planning, and drift audit to their owning skills.

## Route

Identify the current surface, check setup when workflow state matters, spend the evidence budget, and choose exactly one route from the map. When evidence is incomplete, use the smallest accountable fallback: `and-triage` for unclear GitHub state or an unrecorded map-shaped signal; the recorded `and-clarify` or `and-wayfind` route for `needs-info`; `setup-and` for missing repository rules; or one direct question for a human-owned decision. Return the route card and stop.

Completion criterion: the user can invoke one named skill next or answer one concrete owner question that makes the next move clear.

## Route Card

```markdown
Current position: <stage or surface>
Next: <skill or accountable owner action>
Why: <one sentence grounded in one or two decisive facts>
Rule to learn: <one reusable sentence>
Human input: <one exact question, only when needed>
```

Use the user's language and keep skill names, labels, issue numbers, work IDs, commands, and code identifiers literal. Omit `Human input` when none is needed.

## Boundary

Ask Andie is read-only. Name the next skill or accountable owner action and stop; the destination owns its judgments and mutations. Route a missing stage precondition to its owner rather than bypassing it.
