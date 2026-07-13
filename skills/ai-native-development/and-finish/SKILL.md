---
name: and-finish
description: Merge and complete one reviewed AND delivery unit, then clean its delivery artifacts.
disable-model-invocation: true
---

# AND Finish

Finish is a resumable transaction: publish one reviewed delivery unit through one authorized GitHub pull request, make its configured-backend lifecycle completion authoritative, then remove only source artifacts proven safe to clean. Derive completed steps from evidence instead of repeating them.

## Runtime Contracts

Read `.and/config.yml`, then use `and-backend-contract` for the delivery unit, ownership, receipts, active stage, and lifecycle outcome. Use GitHub only for repository hosting and implementation artifacts. Route missing setup to `setup-and`; stop before mutation when the Git remote does not identify one supported GitHub repository.

## Preconditions

Before merge, the current actor owns or is delegated one open `ready-for-agent` delivery unit whose Implementation receipt identifies a committed reviewed head, verification, and clean review. Required acceptance must be complete and no external blocker may remain. On resume after merge, the pull request and backend evidence must identify the same original scope and actor.

Route stale implementation or review evidence to `and-implement`, contract defects to `and-pack`, and ownership, relationship, stage, or lifecycle drift to `and-sweep`.
Report pending acceptance as a wait for its recorded owner without mutation.

## Process

1. **Resolve the transaction.**
   - Read the complete delivery unit, claim, contract, every PRD child, Implementation receipt, verification, review, acceptance, blockers, relationships, and linked artifacts.
   - Resolve the actor, source branch and worktree, reviewed head, fixed point, GitHub repository, default branch, explicit target when any, merge policy, and one matching open or merged pull request.
   - Prove the actor can push, create or update and merge the pull request, and perform backend completion. Match pull requests by repository, source, and target; multiple or mismatched matches are ambiguity, not permission to create another.
   - Completion criterion: scope, owner, source, reviewed head, repository, target evidence, capabilities, and pull-request identity are unambiguous.

2. **Prove delivery readiness.**
   - Before merge, verify the claim still covers the complete executable package, no blocker is open, and the reviewed head exists on the source branch.
   - Inspect the fixed-point diff and commits after the reviewed head. The source worktree must be clean, every PRD child integrated, and no unreviewed implementation or scope change may follow the reviewed head.
   - On post-merge resume, prove the recorded pull-request head contains the reviewed head and the authorized target contains the merge result.
   - Inspect cleanup candidates for unrelated changes or unique commits.
   - Completion criterion: the complete reviewed unit is ready to publish or resume, and every cleanup candidate is classified as safe or retained.

3. **Authorize once.**
   - Recover the target from a merged pull request, explicit user instruction, or authoritative repository policy. Recover the merge method from the same evidence or the single enabled GitHub method.
   - Ask one focused question only when target or merge method remains genuinely ambiguous. That answer authorizes merge, backend completion, and cleanup that later passes every safety check.
   - Verify the target exists in this repository and the source differs from the target and default branch.
   - Completion criterion: one target and one merge method authorize the whole remaining transaction.

4. **Prepare one pull request.**
   - Reuse the sole matching pull request, or push the source and create one against the authorized target. Reference the delivery unit without an auto-close keyword.
   - Follow the configured backend's pre-merge Finish Delivery steps. When it requires a source-branch completion proposal, make that the only finish-owned source change and use its commit as the final pull-request head.
   - Make the pull request ready after its final head is known.
   - Completion criterion: exactly one ready or merged pull request represents the complete delivery unit.

5. **Revalidate the final head.**
   - Immediately before merge, re-read the delivery unit, claim, acceptance, blockers, contract, source worktree, remote branch, pull request, checks, reviews, conflicts, target, and cleanup candidates.
   - Prove the final head contains the reviewed implementation head; any later diff is only the backend-authorized completion proposal. Prove required checks and reviews apply to that final head and are successful, no blocking review or conflict remains, and GitHub reports it mergeable.
   - Report a genuine external wait without claiming completion. Before routing a defect back, withdraw any non-authoritative completion proposal through the backend reference and verify the source again represents open work.
   - Completion criterion: the current pull-request head is safe to merge, or one precise wait or owning route is named.

6. **Merge exactly once.**
   - Reuse verified merge evidence on resume; otherwise merge with the authorized method and keep source cleanup outside the merge operation.
   - Verify GitHub records the merge and the target contains its result. Retain the pull request, reviewed head, and target evidence.
   - Completion criterion: delivery to the authorized target is proven exactly once.

7. **Complete workflow state.**
   - Run the backend's post-merge Finish Delivery steps for exactly the claimed unit. For a PRD, verify every claimed child requirement is integrated, complete every contained child, then complete the parent; leave merely related work unchanged.
   - If merge succeeded but backend completion did not, resume only that operation. Route contradictory state, or a merged markdown delivery without its required proposal, to `and-sweep`.
   - Completion criterion: the configured backend authoritatively records `completed` with delivery evidence for the single package or every contained PRD child followed by its parent.

8. **Clean proven-safe artifacts.**
   - After merge and lifecycle completion, remove the remote source branch only when it remains uniquely tied to this merged unit and is neither target nor default.
   - From another clean worktree, remove the linked source worktree and local branch under the same proof. Fetch and prune, then fast-forward a clean target worktree.
   - Preserve any dirty, unique, ambiguous, or unrelated artifact and name the reason.
   - Completion criterion: all proven-safe source artifacts are gone and the clean target is synchronized, or every retained artifact has one exact reason.

9. **Report the result.**
   - Report delivery unit, pull request, target, merge, lifecycle, cleanup, and the one remaining operation when any.
   - Completion criterion: delivery, completion, and cleanup status are each clear without copying contracts, logs, or diffs.

## Completion Receipt

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

Cleanup follows authoritative completion and is reported separately.

## Boundaries

- Finish the whole claimed unit through its one authorized pull request; PRD children are not separate finish targets.
- Consume reviewed evidence and route implementation, CI, conflict, or scope defects to their owner.
- Preserve active workflow state until the configured backend's completion point.
- Clean only artifacts proven to belong exclusively to the completed delivery unit.
