# AI-native development skills

This document helps humans and agents choose the right skill for each stage of the AI-native delivery loop.

Use it when:

- you have a request, issue, PRD, or PR and need the next workflow step;
- you are maintaining one of the issue-related skills;
- you need to check a skill's responsibility boundary before acting.

If the next step is unclear, use `ask-andie` first.

## Loop Map

| Stage | Situation | Primary skill | Output | Usually next |
| --- | --- | --- | --- | --- |
| Observe | A raw signal has not been recorded yet. | `issue-intake` | Durable issue, usually entering `needs-triage`. | `issue-triage` |
| Decide | A recorded issue needs routing. | `issue-triage` | Closed issue, `needs-info`, or `needs-pack`. | `grill-with-docs`, `issue-pack`, or human input |
| Clarify | Human product, domain, architecture, naming, testing, access, or acceptance input is missing. | Matt `grill-with-docs` when a decision interview is needed; otherwise capture the answer on the issue. | Recorded decision or specific unanswered question. | `issue-pack` or `issue-triage` |
| Pack | Worth-doing work is not executable yet. | `issue-pack` | Ordinary ready issue or PRD package. | `issue-pick` |
| Ready | Executable work exists. | `issue-pick` | Recommended ordinary issue or PRD package. | `issue-claim` |
| Claim | A delivery unit has been chosen. | `issue-claim` | Ownership recorded without changing scope. | Matt `implement` |
| Execute | Claimed work is being implemented. | Matt `implement` | Code, tests, verification, PR, or commit. | Close or route back to `issue-pack` |
| Close/Learn | Work is complete or workflow state has drifted. | `issue-sweeper` for drift. | Closed work, cleanup, docs, or follow-up issues. | New signal or no action |

## Workflow Skills

### `ask-andie`

- Use when: the current position in the loop is unclear.
- Produces: current stage, evidence used, next recommended skill, and any human decision needed.
- Must not: edit tracker state, claim, or implement work.
- Usually next: whichever skill it routes to.

### `issue-intake`

- Use when: a raw signal should become durable tracker work.
- Produces: a clear issue with evidence and open triage questions.
- Must not: decide value, mark readiness, pack, claim, create relationships, or implement.
- Usually next: `issue-triage`.

### `issue-triage`

- Use when: a recorded issue needs a route.
- Produces: close with reason, `needs-info`, or `needs-pack`.
- Must not: write a PRD, create child issues, mark ready, claim, or implement.
- Usually next: `grill-with-docs`, `issue-pack`, or human input.

### `issue-pack`

- Use when: worth-doing work needs to become one executable delivery unit.
- Produces: an ordinary `ready-for-agent` issue or a `parent-prd + ready-for-agent` PRD package with child issues, relationships, blockers, and verification criteria.
- Must not: replace `grill-with-docs`, claim, implement, or mark PRD children as independently ready.
- Usually next: `issue-pick`.

### `issue-pick`

- Use when: the tracker has ready work and the agent needs one delivery unit.
- Produces: a read-only recommendation with claim unit, blockers checked, PRD context, and verification expectations.
- Must not: edit issues, claim, implement, pick PRD children independently, or pick blocked, claimed, or contradictory work.
- Usually next: `issue-claim`.

### `issue-claim`

- Use when: a specific delivery unit has been chosen and ownership should be recorded.
- Produces: assignee/comment/branch/PR ownership signal according to repository setup.
- Must not: change scope, claim PRD children independently, or claim around unresolved external blockers.
- Usually next: Matt `implement`.

### `issue-sweeper`

- Use when: tracker state may have drifted.
- Produces: findings for stale claims, contradictory labels, wrong relationships, blocked ready work, and closable parent PRDs.
- Must not: implement, decide priority, or override active owners without approval.
- Usually next: approved metadata cleanup, `issue-triage`, or `issue-pack`.

### `setup-ai-native-development`

- Use when: a repository needs this loop configured.
- Produces: tracker label mapping, relationship rules, claim policy, and agent-facing workflow docs.
- Must not: change product requirements, implementation code, or existing issues unless explicitly asked.
- Usually next: `issue-intake` or `issue-triage`.

## External Route Targets

These are Matt skills used by this workflow. They are explicit route targets, not hidden substeps inside another skill.

| Skill | Use when |
| --- | --- |
| `grill-with-docs` | A correct package depends on human product, domain, architecture, naming, or testing decisions that should be recorded. |
| `implement` | A delivery unit has been claimed and is ready for code execution. |

`issue-pack` adapts the PRD and tracer-bullet issue ideas from Matt `to-prd` and `to-issues`, but the published tracker state follows this package's `needs-pack`, PRD package, relationship, and claim rules.

## Maintain These Skills

- Change loop rules in [delivery loop](delivery-loop.md), then update any affected `SKILL.md` files.
- Put runtime rules in the relevant `SKILL.md`; package docs explain the workflow and shared vocabulary.
- Keep the workflow skills together in this package.
- Update the root `README.md` and `skills.sh.json` when skill names, descriptions, or groups change.

## Acknowledgements

This workflow builds on [Matt Pocock's skills repository](https://github.com/mattpocock/skills). It reuses `grill-with-docs` and `implement` directly, and adapts the PRD and tracer-bullet issue patterns from `to-prd` and `to-issues` to this repository's delivery loop, tracker vocabulary, and ownership rules.
