---
name: and-implement
description: Implement a claimed AI-native delivery unit in an isolated worktree.
disable-model-invocation: true
---

# AND Implement

Implement the complete claimed delivery unit from its configured-backend Package Contract. Work in one isolated worktree and finish with a committed, verified, reviewed diff plus durable implementation evidence.

## Runtime Contracts

Read `.and/config.yml`, then use `and-backend-contract` for the delivery unit, ownership, relationships, blockers, and receipts. Route missing or unsupported setup to `setup-and`.

Real `tdd` and `code-review` skills are required. If either is unavailable, name the missing skill and stop with the documented installation route. Give `tdd` the Package Contract's agreed seam as confirmed input where test-first work is practical. Use `code-review` against the retained fixed point with the complete Package Contract and every acceptance-bearing PRD child supplied as the Spec.

## Preconditions

Begin only when the current actor owns or is delegated the complete open `ready-for-agent` delivery unit and no external blocker remains. A PRD claim covers its parent and every child.

Route an unready or unowned unit to the smallest upstream AND skill. If the current head already has clean implementation evidence satisfying the contract, route to `and-finish`; route a linked non-authoritative finish proposal there before implementation resumes.

## Process

1. **Resolve the work.**
   - Read the claim, Package Contract, accepted decisions, blockers, implementation artifacts, verification expectations, and every PRD child.
   - Require an agreed test seam or explicit non-test verification strategy. Route any omission to `and-pack`; when human judgment is required, resume through an existing State Reason or `and-triage` before `and-clarify`.
   - Completion criterion: the whole claim scope, expected behavior, dependency order, blockers, seam, and verification path are known from the backend source of truth.

2. **Isolate the diff.**
   - Inspect Git status, branches, worktrees, and linked artifacts. Reuse a worktree tied to this delivery unit only when all its changes are in scope; otherwise leave it untouched and create a dedicated branch and worktree, or stop when isolation cannot be proven.
   - Retain the full commit SHA that predates every delivery-unit change. For a new worktree use its branch point; for a reused worktree prove the fixed point still covers the whole diff.
   - Completion criterion: one isolated worktree contains no unrelated work, and one valid review fixed point covers its complete diff.

3. **Implement the contract.**
   - Plan from the Package Contract and PRD dependencies. Internal delegation remains under the parent claim owner.
   - Use `tdd` at the agreed seam where practical. Work incrementally, run focused tests and typechecking regularly, then run the full relevant suite once the delivery unit is complete.
   - Apply required documentation or domain updates. Keep the diff within the claimed contract.
   - Route an incorrect boundary, unclear verification requirement, or new human judgment to its owning stage instead of changing scope locally.
   - Completion criterion: code, tests, and required docs satisfy every parent and child requirement, or one evidenced upstream blocker is named.

4. **Review the complete diff.**
   - Commit the scoped review candidate so no relevant change exists only in the working tree.
   - Verify the fixed point still resolves, then invoke `code-review` with that fixed point and the complete backend Package Contract as Spec.
   - Fix in-scope implementation findings, update the scoped commit, rerun relevant verification, and review the same complete diff again. Route contract defects to `and-pack`; route human-owned judgments through the current State Reason owner or `and-triage` when no decision route exists.
   - Completion criterion: Standards and Spec review are clean, or every remaining finding is explicitly outside scope or human-owned.

5. **Record the handoff.**
   - Verify every delivery-unit change is committed on the isolated branch and record the Implementation receipt through the configured backend.
   - Link the branch, reviewed head, pull request, CI, and review evidence when they exist. Leave PR delivery, lifecycle completion, and cleanup to `and-finish`.
   - Completion criterion: implementation is committed, verified, reviewed, and recoverable from backend evidence, or routed back with the smallest blocker.

## Implementation Receipt

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

Report only the worktree, branch, reviewed head, pull request when any, verification and review result, blocker when any, and next step.

## Boundaries

- Keep implementation in the claimed delivery unit and its isolated worktree.
- Use the backend Package Contract, not chat, pick, or claim summaries, as the Spec.
- Keep parent ownership unchanged when delegating PRD children internally.
- Let `and-finish` own pull-request delivery, terminal lifecycle state, and cleanup.
