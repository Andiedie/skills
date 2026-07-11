# AI-native Development Skills

Use this guide to choose the next skill in the AND delivery loop. If the current position is unclear, start with [`ask-andie`](../ask-andie/SKILL.md).

## Route Map

| Position | Situation | Action | Result | Usually next |
| --- | --- | --- | --- | --- |
| Setup | The repository has no valid AND configuration or minimum integration. | [`setup-and`](../setup-and/SKILL.md) | Configured backend, readiness checks, and an Agent entrypoint. | `and-intake`, `and-triage`, or `ask-andie` |
| Route | The current position is unclear. | [`ask-andie`](../ask-andie/SKILL.md) | One next skill or accountable-owner action. | The named route |
| Observe | A raw signal has no authoritative work record. | [`and-intake`](../and-intake/SKILL.md) | A work record, usually entering `needs-triage`. | `and-triage` |
| Decide | A work record needs a route. | [`and-triage`](../and-triage/SKILL.md) | A lifecycle outcome, `needs-info` with a State Reason, or `needs-pack`. | Input owner, `and-clarify`, or `and-pack` |
| Clarify | `needs-info` names a required decision, fact, permission, acceptance input, or external event. | [`and-clarify`](../and-clarify/SKILL.md) for a structured decision; otherwise the accountable owner | Confirmed input or a current State Reason. | The recorded resume skill |
| Pack | Worth-doing work is not executable yet. | [`and-pack`](../and-pack/SKILL.md) | A `ready-for-agent` single issue package or PRD package. | `and-pick` |
| Ready | A delivery unit should be recommended for execution. | [`and-pick`](../and-pick/SKILL.md) | One read-only delivery-unit recommendation. | `and-claim` |
| Claim | A ready delivery unit has been chosen. | [`and-claim`](../and-claim/SKILL.md) | Ownership of the complete delivery unit. | `and-implement` |
| Implement | The current actor is the claimant or has been explicitly delegated by the claimant. | [`and-implement`](../and-implement/SKILL.md) | Implementation artifacts, verification, review, commit, and implementation receipt. | Merge, acceptance, closure, or a route back |
| Audit | Stage state, State Reasons, relationships, blockers, ownership, implementation artifacts, or lifecycle outcomes may have drifted. | [`and-sweep`](../and-sweep/SKILL.md) | Actionable findings and approved low-risk cleanup. | The skill or owner responsible for the repair |

## Backend Reference

Workflow skills use [`and-backend-contract`](../and-backend-contract/SKILL.md) to load backend-neutral concepts and the configured backend representation. The reference returns control to the calling skill rather than performing a workflow stage.

## External Runtime Skills

AND composes with three external runtime skills:

| Skill | Used by |
| --- | --- |
| `grilling` | `and-clarify` for interview behavior. |
| `tdd` | `and-implement` when test-first work is practical at the agreed seam. |
| `code-review` | `and-implement` before finalizing the delivery-unit diff. |

Install missing dependencies with:

```sh
npx --yes skills add mattpocock/skills -g --agent codex claude-code --skill grilling tdd code-review -y
```
