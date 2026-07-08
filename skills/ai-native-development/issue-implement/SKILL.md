---
name: issue-implement
description: Implement a claimed AI-native delivery unit in an isolated worktree.
disable-model-invocation: true
---

# Issue Implement

Implement a claimed single issue package or PRD package. The configured workflow backend is the implementation source of truth; chat history is context only.

Implementation happens in an isolated worktree and finishes with verification, code review, a scoped commit, and implementation evidence.

## Backend Contract

Before implementation work, read `.and/config.yml`, then use `ai-native-backend-contract`.

Use the configured backend reference for reading the claimed delivery unit and recording implementation evidence. If setup is missing, unsupported, or the backend contract is unavailable, stop and route to `setup-ai-native-development` or ask the user to install the missing skill.

Do not infer backend ownership, receipt, child, relationship, or implementation artifact representation inside this skill.

## External Implementation Skills

`tdd` and `code-review` are required implementation skills. Verify they are available before implementation work begins.

If one is missing, stop with the exact missing skill and route to `setup-ai-native-development` or the documented install command. Do not simulate missing skills.

Use `tdd` where practical at the package's agreed seam. Run `code-review` before finalizing the implementation diff.

## Preconditions

- The delivery unit is claimed.
- The current actor is the claimant or explicitly delegated by the claimant.
- The claim unit is one single issue package, or one parent PRD package plus all children.
- The delivery unit is open, `ready-for-agent`, and free of open external blockers.

If a precondition is missing, route to the smallest upstream skill: `issue-claim`, `issue-pick`, `issue-pack`, `issue-grill`, `issue-triage`, or `issue-sweep`.

## Isolation Rule

Implementation must happen in a dedicated branch/worktree tied to the delivery unit.

Reuse an existing worktree only when it is linked to the same delivery unit and has no unrelated changes. Do not implement on `main`, in a shared dirty worktree, or in a worktree containing unrelated changes.

## Process

1. Resolve claimed delivery unit.
   - Read the claim record, ownership evidence, Package Contract, accepted `issue-grill` decisions, blockers, linked implementation artifacts, and verification expectations.
   - For a PRD package, read the parent PRD and every child record.
   - Treat the configured backend package as the implementation contract.
   - Completion criterion: source-of-truth links, claim scope, blockers, child coverage, and verification expectations are known.

2. Enter isolated worktree.
   - Inspect current branch, `git status`, existing worktrees, and linked implementation artifact evidence.
   - Reuse only a safe linked worktree.
   - Otherwise create a dedicated branch/worktree using repository convention.
   - Completion criterion: implementation is happening in one isolated worktree whose branch is tied to the claimed delivery unit and contains no unrelated changes.

3. Plan from Package Contract.
   - Derive the plan from the Package Contract, child slices, accepted grill decisions, required documentation or domain updates, true dependency blockers, and documented verification strategy.
   - For a PRD package, use child slice order from true dependency relationships; children may be delegated internally, but the parent claim owner remains responsible for integration.
   - If the package is wrong, verification is unclear, or scope is inconsistent, stop and route back instead of privately changing scope.
   - Completion criterion: the plan covers the full claimed delivery unit and needs no unconfirmed scope change.

4. Implement and verify.
   - Use `tdd` for substantial behavior changes when test-first work is practical at the package's agreed seam.
   - Implement incrementally.
   - Run focused tests regularly.
   - Run typechecking regularly when available.
   - Run the full relevant suite before finishing.
   - Update docs or domain artifacts required by the package.
   - Keep changes scoped to the delivery unit.
   - Completion criterion: code, docs, and tests satisfy the Package Contract, or the smallest blocker is named with evidence.

5. Review.
   - Run the repository review flow when defined.
   - Run `code-review` for the implementation diff.
   - Do not claim review ran unless it actually ran.
   - Fix actionable findings that are within scope.
   - Route spec or scope issues back to `issue-pack` or `issue-grill`.
   - Completion criterion: review is clean, or remaining findings are explicitly outside scope or require human judgment.

6. Commit, record evidence, and report.
   - Commit only delivery-unit changes on the isolated branch.
   - Record an implementation receipt through the configured backend.
   - Link branch, commit, PR, CI, or review result when available.
   - Do not close, merge, or release claim unless repository policy or the user authorizes it.
   - Report a short receipt: worktree, branch, commit or PR, verification run, review result, remaining blockers, and next close, merge, or acceptance step.
   - Completion criterion: the claimed delivery unit is implemented, verified, reviewed, committed, and recorded, or routed back with the smallest blocker.

## Implementation Receipt

Use this receipt through the configured backend reference:

```markdown
## Implementation

Implemented by: <actor>
Claim unit: <single issue package or PRD package>
Branch / worktree: <branch and path>
Commit / PR: <commit, PR, or none yet>
Verification:
- <tests, typecheck, manual verification, CI, or none with reason>
Review:
- <code-review result or pending with reason>
Docs / domain updates:
- <updated, not required, or pending>
Remaining blockers:
- <none or blocker>
Next step:
- <close, merge, PR review, acceptance, or follow-up>
```

Do not copy full test logs, review findings, diffs, or Package Contracts into the user-facing report.

## Boundaries

- Do not implement unclaimed or undelegated work.
- Do not use chat summaries, pick reports, or claim receipts as the implementation contract; use the backend Package Contract.
- Do not implement in a dirty shared worktree, on `main`, or in a worktree with unrelated changes.
- Do not silently expand, shrink, or rewrite the Package Contract.
- Do not claim, release, override, close, merge, or split public ownership inside this skill unless explicitly authorized by repository policy or the user.
- Do not split PRD children into independent public claims during implementation.
