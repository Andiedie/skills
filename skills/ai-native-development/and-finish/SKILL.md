---
name: and-finish
description: Merge and complete one reviewed AND delivery unit, then clean its delivery artifacts.
disable-model-invocation: true
---

# AND Finish

Finish one reviewed delivery unit through a GitHub pull request. The operation connects the delivered code to the configured backend's terminal lifecycle outcome, then cleans only the source artifacts proven safe to remove.

The operation is resumable. Derive completed steps from GitHub, Git, and backend evidence instead of repeating them.

## Backend Contract

Read `.and/config.yml`, then use `and-backend-contract` before reading or changing workflow state.

Use the configured backend reference for the delivery unit, ownership, receipts, active stage, and lifecycle outcome. Use GitHub only for repository hosting and delivery artifacts. If setup is missing, unsupported, or the backend contract is unavailable, stop and route to `setup-and`.

Finish delivers through GitHub pull requests. Resolve the GitHub repository from Git remotes. For unsupported or ambiguous hosting, stop before mutation and report the exact boundary.

## Preconditions

- Before merge, one open `ready-for-agent` delivery unit is claimed by the current actor or explicitly delegated to them.
- On a post-merge resume, the delivery unit may already be terminal; the merged pull request and backend evidence must identify the same claim scope and actor.
- The Package Contract and complete claim scope are available from the configured backend.
- The implementation receipt identifies the source branch or worktree, committed implementation head, verification, and clean review evidence.
- Required acceptance is complete and no external blocker remains.

Route missing or stale implementation and review evidence to `and-implement`, Package Contract defects to `and-pack`, and ownership, relationship, stage, or lifecycle drift to `and-sweep`.

## Process

1. Resolve the finish operation.
   - Read the complete delivery unit, claim, Package Contract, implementation receipt, verification and review evidence, blockers, relationships, and linked artifacts.
   - For a PRD package, read every child and confirm the parent claim covers them all.
   - Resolve the source branch, linked worktree, reviewed implementation head, GitHub remote and repository, default branch, existing pull request when any, explicit target when supplied, and repository merge policy.
   - Resolve the authenticated actor and verify the capability to push the source, create or update and merge the pull request, and perform the configured backend's finish mutations. Stop before the first mutation when any required capability is unavailable or ambiguous.
   - Match an open or merged pull request by repository, source branch, and target. Treat multiple or mismatched pull requests as ambiguity rather than creating a duplicate.
   - Completion criterion: the delivery unit, owner, source artifacts, reviewed head, repository, target evidence, and existing pull request state are unambiguous.

2. Validate delivery readiness.
   - For unmerged work, verify the claim still covers the complete delivery unit and the package remains executable without an open blocker. For a merged resume, verify the original claim scope and actor from backend and pull-request evidence.
   - For unmerged work, verify the reviewed implementation head exists on the source branch and the implementation receipt's verification and review evidence apply to it. For a merged resume, verify the recorded pull-request head and merge evidence cover that reviewed head.
   - Inspect the fixed-point diff and any commits after the reviewed head. Before merge, the source worktree must be clean, the diff must match the Package Contract, and no unreviewed implementation or scope change may follow the reviewed head.
   - For a PRD package, verify every child requirement is integrated according to the Package Contract.
   - Inspect local cleanup candidates for unrelated changes or commits not represented by the source branch.
   - Completion criterion: the reviewed delivery unit is ready to publish or resume from proven post-merge evidence, or the smallest owning stage and evidence for the stop are named.

3. Resolve authorization.
   - For a merged resume, recover the completed target and merge method from the merged pull request without asking again.
   - For unmerged work, resolve the merge method from authoritative repository policy or the single enabled GitHub method. Do not infer policy from incidental Git history.
   - For unmerged work, treat an explicit target branch as authorized without asking for it again. If the target is absent or multiple merge methods remain equally valid, ask one question containing only the unresolved choice or choices.
   - Treat that authorization as covering merge, terminal lifecycle recording, and later cleanup of source artifacts that pass every safety check. Safety failures remain stop conditions rather than confirmable choices.
   - Verify the target exists, belongs to the resolved repository, and matches any reusable pull request. Verify the source differs from both the target and the repository default branch.
   - Completion criterion: one target and merge method are authorized once for the whole finish operation.

4. Prepare one ready pull request.
   - Reuse exactly one matching pull request, or push the source branch and create one against the authorized target. Stop on multiple or mismatched pull-request surfaces instead of retargeting or creating a duplicate.
   - If the matching pull request is merged, retain it as delivery evidence and continue to final-head validation.
   - For an unmerged pull request, reference the delivery unit without using an auto-close keyword; backend lifecycle completion follows verified merge.
   - For an unmerged pull request, follow the configured backend reference's pre-merge finish steps. When that reference requires a source-branch completion proposal, make it the only finish-owned source change, commit and push it, and use the resulting commit as the final pull-request head.
   - Make an unmerged pull request ready after its final head is prepared.
   - Completion criterion: exactly one ready or merged pull request represents the complete delivery unit, and its final head is known.

5. Validate the final pull-request head.
   - For a merged resume, verify the recorded final head contains the reviewed implementation head and the authorized target contains the merge result, then continue with the first incomplete post-merge step.
   - For an unmerged pull request, re-read the claim, blockers, Package Contract, source worktree, remote branch, pull request, and target immediately before merge.
   - For an unmerged pull request, verify the reviewed implementation head is contained in the final pull-request head. Any later diff must be only the source-branch completion proposal allowed by the configured backend reference.
   - For an unmerged pull request, verify required checks and reviews apply to the final head and are successful, no blocking review or conflict remains, and GitHub reports the pull request mergeable.
   - Verify cleanup candidates remain clean and contain no unrelated or unique work.
   - Report genuinely pending external checks or reviews without claiming completion and leave any resumable completion proposal in place.
   - Before routing an unmerged final head back for a defect, follow the configured backend reference to withdraw any non-authoritative completion proposal and verify the source again represents open work. Then route changed implementation, failed required checks, blocking reviews, or conflicts to `and-implement` or the stage owning the defect; route package contradictions to `and-pack` and workflow drift to `and-sweep`.
   - Completion criterion: the current pull-request head is safe to merge, or one precise wait or route-back is reported.

6. Merge once.
   - If the pull request is already merged, verify its repository, source, target, and delivered head, then continue from the first incomplete step.
   - Otherwise merge using the authorized method without requesting source-branch cleanup as part of the merge operation.
   - Verify GitHub records the pull request as merged and the authorized target contains the merge result. Retain the pull request, reviewed implementation head, and merge or target evidence for lifecycle completion.
   - Completion criterion: delivery to the authorized target is proven exactly once.

7. Complete workflow state.
   - Follow the configured backend reference's post-merge finish steps to record or verify the completion receipt and terminal `completed` lifecycle outcome for exactly the claimed delivery unit.
   - On a merged resume, if the configured backend required a pre-merge completion proposal and the merged head lacks it, stop and route the lifecycle drift to `and-sweep`.
   - Verify a PRD package is complete before completing its parent delivery unit; leave merely related work unchanged.
   - If merge succeeded but lifecycle completion did not, perform only the recovery allowed by the configured backend reference without repeating merge. Route contradictory backend state to `and-sweep`.
   - Completion criterion: the configured backend authoritatively shows the exact delivery unit as completed with delivery evidence.

8. Clean delivery artifacts.
   - Begin only after both merge and lifecycle completion are verified.
   - Delete the remote source branch only when it still exists, is proven merged, and is neither the target nor repository default branch. From another clean worktree, remove the linked source worktree and local source branch under the same identity and uniqueness checks.
   - Fetch and prune, then fast-forward an existing clean target worktree. Leave a dirty target worktree unchanged and report it precisely.
   - On resume, perform only missing cleanup. Preserve every artifact whose safety cannot be proven.
   - Completion criterion: all proven-safe source artifacts are removed and the clean target is synchronized, or each intentionally retained artifact has one exact reason.

9. Report the result.
   - Report the delivery unit, pull request, target, merge result, lifecycle result, cleanup result, and any remaining operation.
   - Keep full Package Contracts, logs, diffs, and backend receipts in their authoritative systems.
   - Completion criterion: the user can see whether delivery, completion, and cleanup each succeeded without reading internal execution logs.

## Completion Receipt

Record this receipt through the configured backend:

```markdown
## Completion

Completed by: <actor>
Delivery unit: <single issue package or parent PRD package>
Pull request: <URL and number>
Reviewed implementation head: <full commit SHA>
Target: <repository and branch>
Delivery evidence: <merge commit, or markdown proposal that becomes authoritative with this PR merge>
Verification / review: <linked evidence>
Lifecycle outcome: completed
```

Cleanup is reported after lifecycle completion and is not required to make the terminal outcome authoritative.

## Boundaries

- Finish only the complete claimed delivery unit; child slices are not independent finish targets.
- Consume review evidence without rerunning review or fixing implementation, CI, conflicts, or scope.
- Merge only through the authorized GitHub pull request and target.
- Preserve active workflow state until the configured backend's completion point.
- Clean only artifacts proven to belong exclusively to the merged delivery unit.
- Leave deployment, release, production rollout, and unrelated repository cleanup to their owners.
