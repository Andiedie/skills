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
| Observe | A raw signal has not been recorded yet. | `issue-intake` | Durable work record, usually entering `needs-triage`. | `issue-triage` |
| Decide | A recorded work item needs routing. | `issue-triage` | Lifecycle outcome, `needs-info` with a State Reason, or `needs-pack`. | `issue-grill`, `issue-pack`, or the State Reason owner |
| Clarify | Human product, domain, architecture, naming, testing, access, or acceptance input is missing. | `issue-grill` when a decision interview is needed; otherwise capture the answer in the backend. | Recorded decision, documentation proposal, or current State Reason. | `issue-pack` or `issue-triage` |
| Pack | Worth-doing work is not executable yet. | `issue-pack` | Single issue package or PRD package. | `issue-pick` |
| Ready | Executable work exists. | `issue-pick` | Recommended single issue package or PRD package. | `issue-claim` |
| Claim | A delivery unit has been chosen. | `issue-claim` | Ownership recorded without changing scope. | `issue-implement` |
| Execute | Claimed work is being implemented. | `issue-implement` | Code, tests, verification, review, and commit from an isolated worktree. | Close or route back to `issue-pack` |
| Close/Learn | Work is complete or workflow state has drifted. | `issue-sweep` for drift. | Closed work, cleanup, docs, or follow-up issues. | New signal or no action |

All workflow skills use `ai-native-backend-contract` when they need backend-neutral concepts or configured backend representation rules.

## Workflow And Reference Skills

### `ai-native-backend-contract`

- Use when: another AI-native workflow skill needs the backend contract or configured backend reference.
- Produces: backend-neutral vocabulary and the `github-native` or `markdown-file-based` representation rules.
- Must not: choose a backend, mutate workflow state, or perform a workflow stage.
- Usually next: return to the calling workflow skill.

### `ask-andie`

- Use when: the current position in the loop is unclear.
- Produces: current stage, evidence used, next recommended skill, and the current State Reason question when one exists.
- Must not: edit workflow state, claim, or implement work.
- Usually next: whichever skill it routes to.

### `issue-intake`

- Use when: a raw signal, including an explicitly presented external PR, should become durable backend work.
- Produces: a clear work record with evidence and open triage questions.
- Must not: decide value, mark readiness, pack, claim, create relationships, or implement.
- Usually next: `issue-triage`.

### `issue-triage`

- Use when: a recorded work item needs a route.
- Produces: lifecycle outcome with reason, `needs-info` with a State Reason, or `needs-pack`. A linked PR may supply verification evidence, but triage reads and mutates the work record; an untracked PR routes to `issue-intake` first.
- Must not: write a PRD, create child records, mark ready, claim, or implement.
- Usually next: `issue-grill`, `issue-pack`, or human input.

### `issue-grill`

- Use when: a correct package depends on human product, domain, architecture, naming, testing, access, or acceptance decisions.
- Produces: backend-safe notes with resolved decisions, documentation proposals, acceptance implications, current State Reason when still blocked, and the resume point; when blockers are resolved, moves the delivery unit to `needs-pack`.
- Must not: edit local docs, create ADRs, update `CONTEXT.md`, pack, claim, or implement.
- Usually next: `issue-pack` when decisions are resolved, or `issue-triage` when new information changes the route.

### `issue-pack`

- Use when: worth-doing work needs to become one executable delivery unit.
- Produces: a `ready-for-agent` single package, or a `parent-prd + ready-for-agent` PRD package with independently-grabbable child slices, relationships, blockers, and verification criteria.
- Before publishing: refuses when missing input blocks a correct package and records a `needs-info` State Reason when safe; otherwise publishes normal package backend edits without re-confirming decisions already resolved by prior workflow state or `issue-grill`.
- Must not: replace `issue-grill`, claim, implement, or mark PRD children as independently ready.
- Usually next: `issue-pick`.

### `issue-pick`

- Use when the configured backend has ready work and the agent needs one delivery unit.
- Produces: a concise read-only recommendation with the claim unit, readiness reason, source-of-truth links, PRD context when present, and any real blocker or ownership risk.
- Must not: edit workflow state, claim, implement, pick PRD children independently, or pick blocked, claimed, or contradictory work.
- Usually next: `issue-claim`.

### `issue-claim`

- Use when: a specific delivery unit has been chosen and ownership should be recorded.
- Produces: backend ownership signal for the whole delivery unit; PRD child slices may be used for internal subagent delegation under that claim.
- Must not: change scope, claim PRD children independently, or claim around unresolved external blockers.
- Usually next: `issue-implement`.

### `issue-implement`

- Use when: a delivery unit has been claimed and should be implemented.
- Produces: implementation in an isolated worktree, focused and full verification, review result, and commit or PR evidence. It supplies the Package Contract's agreed seam to `tdd`, and the retained diff fixed point plus Package Contract Spec to `code-review`.
- Must not: implement unclaimed work, work from chat summaries instead of the configured backend source of truth, use a shared dirty worktree, or silently change scope.
- Usually next: close, merge, route back to `issue-pack`, or route back to `issue-grill`.

### `issue-sweep`

- Use when backend state may have drifted.
- Produces: findings for stale claims, contradictory state, missing `needs-info` State Reasons, wrong relationships, blocked ready work, and parent PRDs needing follow-up.
- Must not: implement, decide priority, or override active owners without approval.
- Usually next: approved metadata cleanup, `issue-triage`, `issue-pack`, `issue-claim`, or human approval.

### `setup-ai-native-development`

- Use when: a repository needs this loop configured.
- Produces: `.and/config.yml`, backend readiness checks, a minimal agent entrypoint, missing external skill report, and project-specific notes only when needed.
- Must not: change product requirements, implementation code, or existing issues unless explicitly asked.
- Usually next: `issue-intake` or `issue-triage`.

## External Runtime Skills

The workflow expects these external skills to be installed:

| Skill | Used for |
| --- | --- |
| `grilling` | `issue-grill` runs the interview. |
| `tdd` | Implementation work uses test-first practice when the change benefits from it. |
| `code-review` | Implementation work uses a review pass before finalizing. |

`setup-ai-native-development` must check and report these skills before reporting the skill environment ready. Missing skills are environment readiness gaps, not repository setup failures. Setup should report the install command and should not install them unless explicitly asked.

Install missing skills with:

```sh
npx --yes skills add mattpocock/skills -g --agent codex claude-code --skill <missing-skill...> -y
```

## Maintain These Skills

- Change loop rules in [delivery loop](delivery-loop.md), then update any affected `SKILL.md` files.
- Before adding or tightening workflow rules, check [Design Balances](delivery-loop.md#design-balances) so invariants stay hard and strategies stay adaptable.
- Change backend storage rules in [AI-native backend contract](../ai-native-backend-contract/SKILL.md) and its backend references, then update affected `SKILL.md` files.
- Put runtime rules in the relevant `SKILL.md`; package docs explain the workflow and shared vocabulary.
- Keep the workflow skills together in this package.
- Update the root `README.md` and `skills.sh.json` when skill names, descriptions, or groups change.
- Whenever an AND skill is added, renamed, removed, or changes the loop, recheck every `ask-andie` route.
