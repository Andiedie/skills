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
| Decide | A recorded issue needs routing. | `issue-triage` | Closed issue, `needs-info`, or `needs-pack`. | `issue-grill`, `issue-pack`, or human input |
| Clarify | Human product, domain, architecture, naming, testing, access, or acceptance input is missing. | `issue-grill` when a decision interview is needed; otherwise capture the answer on the issue. | Recorded decision, documentation proposal, or specific unanswered question. | `issue-pack` or `issue-triage` |
| Pack | Worth-doing work is not executable yet. | `issue-pack` | Single issue package or PRD package. | `issue-pick` |
| Ready | Executable work exists. | `issue-pick` | Recommended single issue package or PRD package. | `issue-claim` |
| Claim | A delivery unit has been chosen. | `issue-claim` | Ownership recorded without changing scope. | `issue-implement` |
| Execute | Claimed work is being implemented. | `issue-implement` | Code, tests, verification, review, and commit from an isolated worktree. | Close or route back to `issue-pack` |
| Close/Learn | Work is complete or workflow state has drifted. | `issue-sweep` for drift. | Closed work, cleanup, docs, or follow-up issues. | New signal or no action |

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
- Usually next: `issue-grill`, `issue-pack`, or human input.

### `issue-grill`

- Use when: a correct package depends on human product, domain, architecture, naming, testing, access, or acceptance decisions.
- Produces: tracker-safe issue notes with resolved decisions, documentation proposals, acceptance implications, remaining blockers, and the resume point; when blockers are resolved, moves the issue to `needs-pack`.
- Must not: edit local docs, create ADRs, update `CONTEXT.md`, pack, claim, or implement.
- Usually next: `issue-pack` when decisions are resolved, or `issue-triage` when new information changes the route.

### `issue-pack`

- Use when: worth-doing work needs to become one executable delivery unit.
- Produces: a `ready-for-agent` single issue package, or a `parent-prd + ready-for-agent` PRD package with independently-grabbable child slices, relationships, blockers, and verification criteria.
- Before publishing: refuses when a missing decision blocks a correct package; otherwise publishes normal package tracker edits without re-confirming decisions already resolved by the issue thread or `issue-grill`.
- Must not: replace `issue-grill`, claim, implement, or mark PRD children as independently ready.
- Usually next: `issue-pick`.

### `issue-pick`

- Use when: the tracker has ready work and the agent needs one delivery unit.
- Produces: a concise read-only recommendation with the claim unit, readiness reason, source-of-truth links, PRD context when present, and any real blocker or ownership risk.
- Must not: edit issues, claim, implement, pick PRD children independently, or pick blocked, claimed, or contradictory work.
- Usually next: `issue-claim`.

### `issue-claim`

- Use when: a specific delivery unit has been chosen and ownership should be recorded.
- Produces: assignee/comment/branch/PR ownership signal for the whole delivery unit; PRD child slices may be used for internal subagent delegation under that claim.
- Must not: change scope, claim PRD children independently, or claim around unresolved external blockers.
- Usually next: `issue-implement`.

### `issue-implement`

- Use when: a delivery unit has been claimed and should be implemented.
- Produces: implementation in an isolated worktree, focused and full verification, review result, and commit or PR evidence.
- Must not: implement unclaimed work, work from chat summaries instead of the tracker source of truth, use a shared dirty worktree, or silently change scope.
- Usually next: close, merge, route back to `issue-pack`, or route back to `issue-grill`.

### `issue-sweep`

- Use when: tracker state may have drifted.
- Produces: findings for stale claims, contradictory labels, wrong relationships, blocked ready work, and parent PRDs needing follow-up.
- Must not: implement, decide priority, or override active owners without approval.
- Usually next: approved metadata cleanup, `issue-triage`, `issue-pack`, `issue-claim`, or human approval.

### `setup-ai-native-development`

- Use when: a repository needs this loop configured.
- Produces: tracker label mapping, relationship rules, claim policy, and agent-facing workflow docs.
- Must not: change product requirements, implementation code, or existing issues unless explicitly asked.
- Usually next: `issue-intake` or `issue-triage`.

## External Matt Skills

These Matt skills are used directly or adapted by this workflow.

| Skill | Use when |
| --- | --- |
| `grilling` | `issue-grill` needs a relentless one-question-at-a-time interview. |
| `domain-modeling` | `issue-grill` needs domain vocabulary and ADR judgment without writing local docs. |
| `implement` | General implementation reference; `issue-implement` adapts it for claimed AI-native delivery units. |
| `code-review` | `issue-implement` needs a review pass over the implementation diff. |

`issue-grill` adapts Matt `grill-with-docs` for this issue workflow. It keeps the `/grilling` and `/domain-modeling` handfeel, but records decisions and documentation proposals on the issue so `issue-pack` can make them part of the delivery unit.

`issue-pack` adapts the PRD and tracer-bullet issue ideas from Matt `to-prd` and `to-issues`, but the published tracker state follows this package's `needs-pack`, PRD package, relationship, and claim rules.

## Maintain These Skills

- Change loop rules in [delivery loop](delivery-loop.md), then update any affected `SKILL.md` files.
- Put runtime rules in the relevant `SKILL.md`; package docs explain the workflow and shared vocabulary.
- Keep the workflow skills together in this package.
- Update the root `README.md` and `skills.sh.json` when skill names, descriptions, or groups change.

## Acknowledgements

This workflow builds on [Matt Pocock's skills repository](https://github.com/mattpocock/skills). It adapts `grill-with-docs` into `issue-grill`, adapts `implement` into `issue-implement`, and adapts the PRD and tracer-bullet issue patterns from `to-prd` and `to-issues` to this repository's delivery loop, tracker vocabulary, and ownership rules.
