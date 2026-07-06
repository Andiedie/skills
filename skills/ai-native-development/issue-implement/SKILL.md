---
name: issue-implement
description: Implement a claimed AI-native delivery unit in an isolated worktree.
disable-model-invocation: true
---

# Issue Implement

Implement a claimed single issue package or PRD package. The tracker package is the source of truth; chat history is only context.

## Preconditions

- The delivery unit is claimed.
- The claim unit is one single issue package, or one parent PRD plus all children.
- The delivery unit is open, `ready-for-agent`, and free of open external blockers.
- The current actor is the claimant, or the claimant explicitly delegated the implementation.

If a precondition is missing, stop and route to `issue-claim`, `issue-pick`, `issue-pack`, `issue-grill`, or `issue-sweep` as appropriate.

## Process

1. Resolve the delivery unit.
   - Read the claim comment, assignee, branch or PR link, parent PRD when present, every child issue, blockers, linked PRs, and all package comments that carry requirements or decisions.
   - Treat the issue or parent PRD package as the implementation contract.
   - Completion criterion: source-of-truth links, claim scope, blockers, and verification expectations are known.

2. Create or enter an isolated worktree.
   - Inspect current branch, `git status`, existing worktrees, and linked branch or PR evidence.
   - Use an existing linked worktree only when it matches the claimed delivery unit and has no unrelated changes.
   - Otherwise create a dedicated branch and worktree for the delivery unit.
   - Do not implement on `main`, in a shared dirty worktree, or in a worktree containing unrelated changes.
   - Completion criterion: implementation is happening in one isolated worktree whose branch is tied to the delivery unit.

3. Plan from the tracker contract.
   - Derive the implementation plan from the Package Contract, child issues, accepted grill decisions, and documented verification strategy.
   - For a PRD package, choose child slice order from true blocker relationships; children may be delegated internally, but the parent claim owner remains responsible for integration.
   - If the package is wrong or underspecified, stop and route back instead of privately changing scope.
   - Completion criterion: the plan covers the claimed delivery unit and no unconfirmed scope change is needed.

4. Implement and verify incrementally.
   - Prefer test-first changes at the package's agreed seam when practical.
   - Run focused tests regularly, typechecking regularly when available, and the full relevant suite before finishing.
   - Keep changes inside the claimed scope, including required documentation or domain updates from the package.
   - Completion criterion: code, docs, and tests satisfy the Package Contract, or the blocker is named with evidence.

5. Review before finalizing.
   - Run the repository's review flow when defined. Use Matt `code-review` when available and appropriate for the diff.
   - Fix actionable findings that are within scope.
   - Route scope or spec problems back to `issue-pack` or `issue-grill`.
   - Completion criterion: review is clean, or remaining findings are explicitly outside the implementation scope or require human judgment.

6. Commit and report.
   - Commit only the delivery-unit changes on the isolated branch.
   - Update tracker or PR discussion with a short implementation receipt when the repository workflow expects it.
   - Do not close issues, release claims, or merge unless repository policy or explicit human approval allows it.
   - Report worktree, branch, commit or PR link, verification run, review result, remaining blockers, and next close or merge step.
   - Completion criterion: the claimed delivery unit is implemented, verified, reviewed, and committed, or it is routed back with the smallest blocker.

## Boundaries

- Do not implement unclaimed work.
- Do not use chat summaries as the implementation contract.
- Do not implement in a dirty shared worktree or on the main branch.
- Do not claim, release, override, close, or merge work inside this skill unless explicitly authorized by repository policy or the user.
- Do not silently expand or shrink the Package Contract.
- Do not split PRD children into independent public claims during implementation.
