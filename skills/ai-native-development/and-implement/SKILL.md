---
name: and-implement
description: Implement a claimed AI-native delivery unit in an isolated worktree.
disable-model-invocation: true
---

# AND Implement

Implement a claimed single issue package or PRD package. The configured workflow backend is the implementation source of truth; chat history is context only.

Implementation happens in an isolated worktree and finishes with verification, code review, a scoped commit, and implementation evidence.

## Backend Contract

Before implementation work, read `.and/config.yml`, then use `and-backend-contract`.

Use the configured backend reference for reading the claimed delivery unit and recording implementation evidence. If setup is missing, unsupported, or the backend contract is unavailable, stop and route to `setup-and` or ask the user to install the missing skill.

Do not infer backend ownership, receipt, child, relationship, or implementation artifact representation inside this skill.

## External Implementation Skills

`tdd` and `code-review` are required implementation skills. Verify they are available before implementation work begins.

If one is missing, stop with the exact missing skill and route to `setup-and` or the documented install command. Do not simulate missing skills.

Invoke `tdd` where test-first work is practical, supplying the testing seam already confirmed in the Package Contract. Invoke `code-review` before finalizing the implementation diff, supplying both the implementation fixed point and the complete Package Contract as its explicit Spec source.

The AND-provided tracker and Spec context satisfy their inputs, so continue directly to their runtime process.

## Preconditions

- The delivery unit is claimed.
- The current actor is the claimant or explicitly delegated by the claimant.
- The claim unit is one single issue package, or one parent PRD package plus all children.
- The delivery unit is open, `ready-for-agent`, and free of open external blockers.

If a precondition is missing, route to the smallest upstream skill: `and-claim`, `and-pick`, `and-pack`, `and-clarify`, `and-triage`, or `and-sweep`.

If the current implementation head already has a clean implementation receipt satisfying the Package Contract and no acceptance or blocker remains, stop and route to `and-finish`. If the linked branch carries a non-authoritative finish proposal, route to `and-finish` to wait or withdraw it before implementation continues.

## Isolation Rule

Implementation must happen in a dedicated branch/worktree tied to the delivery unit.

Reuse an existing worktree only when it is linked to the same delivery unit and has no unrelated changes. Do not implement on `main`, in a shared dirty worktree, or in a worktree containing unrelated changes.

## Process

1. Resolve claimed delivery unit.
   - Read the claim record, ownership evidence, Package Contract, accepted `and-clarify` decisions, blockers, linked implementation artifacts, agreed testing seam, and verification expectations.
   - For a PRD package, read the parent PRD and every child record.
   - Treat the configured backend package as the implementation contract.
   - If the Package Contract does not state the expected behavior or verification expectations, or does not state an agreed testing seam or explicit non-test verification strategy, stop before tests or implementation changes. Route a packaging omission to `and-pack`; route a missing human testing decision to `and-clarify`. Do not make or reconfirm that decision during implementation.
   - Completion criterion: source-of-truth links, claim scope, blockers, child coverage, expected behavior, agreed seam or verification strategy, and verification expectations are known.

2. Enter isolated worktree.
   - Inspect current branch, `git status`, existing worktrees, and linked implementation artifact evidence.
   - Reuse only a safe linked worktree.
   - Otherwise create a dedicated branch/worktree using repository convention.
   - Before changing tests, code, or docs, resolve and retain the full commit SHA from which the delivery-unit diff must be reviewed. For a new worktree, use its branch creation point. For a reused worktree, verify the fixed point predates all changes for this delivery unit.
   - Completion criterion: implementation is happening in one isolated worktree whose branch is tied to the claimed delivery unit and contains no unrelated changes, and the review fixed point resolves to the intended base commit.

3. Plan from Package Contract.
   - Derive the plan from the Package Contract, child slices, accepted grill decisions, required documentation or domain updates, true dependency blockers, agreed testing seam, and documented verification strategy.
   - For a PRD package, use child slice order from true dependency relationships; children may be delegated internally, but the parent claim owner remains responsible for integration.
   - If the package is wrong, verification is unclear, or scope is inconsistent, stop and route back instead of privately changing scope.
   - Completion criterion: the plan covers the full claimed delivery unit and needs no unconfirmed scope change.

4. Implement and verify.
   - When test-first work is practical, invoke `tdd` with the pre-agreed seam as confirmed input. Do not ask the user to confirm the same seam again.
   - Implement incrementally.
   - Run focused tests regularly.
   - Run typechecking regularly when available.
   - Run the full relevant suite before finishing.
   - Update docs or domain artifacts required by the package.
   - Keep changes scoped to the delivery unit.
   - Completion criterion: code, docs, and tests satisfy the Package Contract, or the smallest blocker is named with evidence.

5. Review.
   - Commit the scoped delivery-unit changes as the review candidate. The external review compares committed `HEAD` with the fixed point, so do not invoke it while relevant changes exist only in the working tree.
   - Verify the retained fixed point still resolves and covers the complete delivery-unit diff.
   - Invoke `code-review` with that fixed point and the configured-backend Package Contract as the explicit Spec source. Include all child records when they refine a PRD package's acceptance or verification requirements.
   - Do not make `code-review` rediscover the tracker or Spec.
   - Do not claim review ran unless it actually ran.
   - Fix implementation defects that are actionable within the Package Contract, update the scoped commit, then rerun relevant verification and review against the same fixed point.
   - Route Package Contract or scope defects to `and-pack`. Route missing human-owned judgments to `and-clarify` or the owner named by the State Reason.
   - Completion criterion: review is clean, or remaining findings are explicitly outside scope or require human judgment.

6. Record evidence and report.
   - Verify all delivery-unit changes are contained in scoped commits on the isolated branch and no relevant change remains only in the working tree.
   - Record an implementation receipt through the configured backend.
   - Link branch, commit, PR, CI, or review result when available.
   - Leave pull-request delivery, terminal lifecycle completion, and cleanup to `and-finish`.
   - Report a short receipt: worktree, branch, reviewed implementation head, pull request when any, verification run, review result, remaining blockers, and next `and-finish`, acceptance-owner, or route-back step.
   - Completion criterion: the claimed delivery unit is implemented, verified, reviewed, committed, and recorded, or routed back with the smallest blocker.

## Implementation Receipt

Use this receipt through the configured backend reference:

```markdown
## Implementation

Implemented by: <actor>
Claim unit: <single issue package or PRD package>
Branch / worktree: <branch and path>
Fixed point: <full base commit SHA>
Reviewed implementation head: <full commit SHA>
Pull request: <URL and number, or none yet>
Verification:
- <tests, typecheck, manual verification, CI, or none with reason>
Review:
- <code-review result or pending with reason>
Docs / domain updates:
- <updated, not required, or pending>
Remaining blockers:
- <none or blocker>
Next step:
- <and-finish, acceptance owner, or route back>
```

Do not copy full test logs, review findings, diffs, or Package Contracts into the user-facing report.

## Boundaries

- Do not implement unclaimed or undelegated work.
- Do not use chat summaries, pick reports, or claim receipts as the implementation contract; use the backend Package Contract.
- Do not implement in a dirty shared worktree, on `main`, or in a worktree with unrelated changes.
- Do not silently expand, shrink, or rewrite the Package Contract.
- Keep the recorded claim and public ownership unchanged.
- Do not split PRD children into independent public claims during implementation.
