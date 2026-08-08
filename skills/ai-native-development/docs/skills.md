# AI-native Development Skills

Use this guide to choose the next skill in the AND delivery loop. If the current position is unclear, start with [`ask-andie`](../ask-andie/SKILL.md).

## Route Map

| Position | Situation | Action | Result | Usually next |
| --- | --- | --- | --- | --- |
| Setup | The repository needs initial setup, has a current Setup Contract gap, or needs an explicit setup audit, repair, or full-ready check. | [`setup-and`](../setup-and/SKILL.md) | A current-state audit, or after one approved write envelope a conformant repository plus a separate readiness result. | `and-intake`, `and-triage`, or `ask-andie` |
| Route | The current position is unclear. | [`ask-andie`](../ask-andie/SKILL.md) | One next skill or accountable-owner action. | The named route |
| Observe | A raw signal has no authoritative work record. | [`and-intake`](../and-intake/SKILL.md) | A work record, usually entering `needs-triage`. | `and-triage` |
| Decide | A work record needs a route. | [`and-triage`](../and-triage/SKILL.md) | A lifecycle outcome, `needs-info` with a State Reason, or `needs-pack`. | Input owner, `and-clarify`, `and-wayfind`, or `and-pack` |
| Clarify | `needs-info` names one bounded decision space whose questions are currently enumerable, or another required input. | [`and-clarify`](../and-clarify/SKILL.md) for that decision space; otherwise the accountable owner | Confirmed input or a current State Reason. | The recorded resume skill |
| Wayfind | A destination is visible, but later questions depend on unfinished investigation and cannot yet be enumerated. | [`and-wayfind`](../and-wayfind/SKILL.md) | A resumable investigation map, or a clear map ready to package. | `and-wayfind` or `and-pack` |
| Pack | Worth-doing work is not executable yet. | [`and-pack`](../and-pack/SKILL.md) | A `ready-for-agent` single issue package or PRD package. | `and-pick` |
| Ready | A delivery unit should be recommended for execution. | [`and-pick`](../and-pick/SKILL.md) | One read-only delivery-unit recommendation. | `and-claim` |
| Claim | An unclaimed ready delivery unit with no active implementation evidence has been chosen. | [`and-claim`](../and-claim/SKILL.md) | Ownership of the complete delivery unit. | `and-implement` |
| Implement | The current actor owns or is delegated a claimed delivery unit whose implementation, review, Deployment disposition, or present Cleanup handoff is incomplete. | [`and-implement`](../and-implement/SKILL.md) | Committed implementation, verification, review, a reviewed-head-bound Deployment disposition, and typed Cleanup items only when supported resources survive for Finish; a Deployment Manifest only for `custom`. | `and-finish`, an acceptance owner, or a route back |
| Finish | Reviewed delivery has no pending acceptance or blocker, or an earlier finish needs to resume delivery, lifecycle completion, or terminal cleanup. | [`and-finish`](../and-finish/SKILL.md) | Merged pull request, linked handoffs, terminal lifecycle evidence, typed local cleanup only for an explicit required handoff, and safe Git artifact cleanup. | A new follow-up signal, environment deployment, or done |
| Audit | Stage state, State Reasons, relationships, blockers, ownership, implementation artifacts, the Deployment disposition or present Cleanup handoff, or lifecycle outcomes may have drifted. | [`and-sweep`](../and-sweep/SKILL.md) | Actionable findings and approved low-risk cleanup; an omitted Cleanup field is a valid no-handoff path. | The skill or owner responsible for the repair |

## Workflow Reference

Workflow skills use [`and-workflow-contract`](../and-workflow-contract/SKILL.md) for shared concepts, GitHub representation, operations, and invariants. The reference returns control to the calling skill rather than performing a workflow stage.

Decision interviews use [`and-interview-contract`](../and-interview-contract/SKILL.md) for shared evidence, recovery, domain modeling, and artifact-ready output. `and-clarify` and `and-wayfind` retain their distinct workflow effects.

## Runtime Skills

AND composes with one repository-owned review skill and four external Matt skills:

| Skill | Source | Used by |
| --- | --- | --- |
| `code-review` | `Andiedie/skills` | `and-implement` before finalizing the delivery-unit diff. |
| `grilling` | `mattpocock/skills` | `and-clarify` and `and-wayfind` for interview behavior. |
| `research` | `mattpocock/skills` | `and-wayfind` for unattended investigation. |
| `prototype` | `mattpocock/skills` | `and-wayfind` for human-in-the-loop concrete exploration. |
| `tdd` | `mattpocock/skills` | `and-implement` when test-first work is practical at the agreed seam. |

Example for a global Codex and Claude Code environment:

```sh
npx --yes skills add Andiedie/skills -g --agent codex claude-code --skill code-review -y
npx --yes skills add mattpocock/skills -g --agent codex claude-code --skill grilling research prototype tdd -y
```

The repository-owned generic `code-review` uses [mattpocock/skills v1.2.3](https://github.com/mattpocock/skills/releases/tag/v1.2.3) as its provenance baseline and remains available for direct review outside `and-implement`. A migration replaces the Matt source under the same public name rather than retaining both copies.
