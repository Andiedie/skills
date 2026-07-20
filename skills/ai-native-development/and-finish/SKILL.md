---
name: and-finish
description: Merge and complete one reviewed AND delivery unit, then clean its delivery artifacts.
disable-model-invocation: true
---

# AND Finish

Finish is a resumable transaction: publish one reviewed delivery unit through one authorized GitHub pull request, make its lifecycle completion authoritative in GitHub, then remove only source artifacts proven safe to clean. Derive completed steps from evidence instead of repeating them.

## Runtime Contracts

Use `and-workflow-contract` for the delivery unit, ownership, receipts, active stage, lifecycle outcome, and `Read Deployment Handoff`. Read [deployment-handoff.md](../and-workflow-contract/deployment-handoff.md) when resolving and revalidating the implementation handoff. Route incomplete setup to `setup-and`; stop before mutation when the Git remote does not identify one GitHub repository.

## Preconditions

Before merge, the current actor owns or is delegated one open `ready-for-agent` delivery unit whose latest Implementation receipt identifies a committed reviewed head, verification, clean review, and authoritative Deployment disposition for that head, plus a complete Deployment Manifest when the disposition is `custom`. Required acceptance must be complete and no external blocker may remain. On resume after merge, the pull request and GitHub evidence must identify the same original scope and actor.

Route stale implementation or review evidence to `and-implement`, contract defects to `and-pack`, and ownership, relationship, stage, or lifecycle drift to `and-sweep`.
Report pending acceptance as a wait for its recorded owner without mutation.

## Process

1. **Resolve the transaction.**
   - Read the complete delivery unit, claim, contract, every PRD child, Implementation receipt, Deployment disposition, its Deployment Manifest when `custom`, verification, review, acceptance, blockers, relationships, and linked artifacts.
   - Resolve the actor, source branch and worktree, reviewed head, implementation-handoff permalink, fixed point, GitHub repository, default branch, explicit target when any, merge policy, and one matching open or merged pull request.
   - Prove the actor can push, create or update and merge the pull request, and complete GitHub workflow state. Match pull requests by repository, source, and target; multiple or mismatched matches are ambiguity, not permission to create another.
   - Completion criterion: scope, owner, source, reviewed head, deployment handoff, repository, target evidence, capabilities, and pull-request identity are unambiguous.

2. **Prove delivery readiness.**
   - Before merge, verify the claim still covers the complete executable package, no blocker is open, and the reviewed head exists on the source branch.
   - Inspect the fixed-point diff and commits after the reviewed head. The source worktree must be clean, every PRD child integrated, and no unreviewed implementation or scope change may follow the reviewed head.
   - Apply the shared deployment-handoff selection and validation rules to the latest Implementation receipt. Rely on Implement's exhaustive inspection rather than reconstructing the disposition or Manifest from the diff.
   - Preserve deployment prerequisites for the deployment owner rather than treating them as completed or executing them in Finish.
   - On post-merge resume, prove the recorded pull-request head contains the reviewed head and the authorized target contains the merge result.
   - Inspect cleanup candidates for unrelated changes or unique commits.
   - Completion criterion: the complete reviewed unit and its authoritative operational handoff are ready to publish or resume, and every cleanup candidate is classified as safe or retained.

3. **Authorize once.**
   - Recover the target from a merged pull request, explicit user instruction, or authoritative repository policy. Recover the merge method from the same evidence or the single enabled GitHub method.
   - Ask one focused question only when target or merge method remains genuinely ambiguous. That answer authorizes merge, lifecycle completion, and cleanup that later passes every safety check.
   - Verify the target exists in this repository and the source differs from the target and default branch.
   - Completion criterion: one target and one merge method authorize the whole remaining transaction.

4. **Prepare one pull request.**
   - Reuse the sole matching pull request, or push the source and create one against the authorized target. Reference the delivery unit and implementation-handoff permalink without an auto-close keyword or duplicated handoff body.
   - Make the pull request ready after its final head is known.
   - Completion criterion: exactly one ready or merged pull request represents the complete delivery unit.

5. **Revalidate the final head.**
   - Immediately before merge, re-read the delivery unit, claim, acceptance, blockers, contract, Implementation receipt, Deployment disposition, its Deployment Manifest when `custom`, source worktree, remote branch, pull request, checks, reviews, conflicts, target, and cleanup candidates.
   - Reapply the shared deployment-handoff head-binding and form validation to the final head. Prove required checks, reviews, acceptance, and blocker evidence apply to that head and are successful, no blocking review or conflict remains, and GitHub reports it mergeable.
   - Report a genuine external wait without claiming completion. Route a changed head, stale or defective deployment handoff, or implementation defect back to `and-implement`; route a deployment contract defect to `and-pack`; and verify the source still represents open work.
   - Completion criterion: the current pull-request head is safe to merge, or one precise wait or owning route is named.

6. **Merge exactly once.**
   - Reuse verified merge evidence on resume; otherwise merge with the authorized method and keep source cleanup outside the merge operation.
   - Verify GitHub records the merge and the target contains its result. Retain the pull request, reviewed head, and target evidence.
   - Completion criterion: delivery to the authorized target is proven exactly once.

7. **Complete workflow state.**
   - Run the workflow contract's post-merge Finish Delivery steps for exactly the claimed unit. For a PRD, verify every claimed child requirement is integrated, complete every contained child, then complete the parent; leave merely related work unchanged.
   - If merge succeeded but lifecycle completion did not, resume only that operation. Route contradictory state to `and-sweep`.
   - Completion criterion: GitHub records `completed` with delivery evidence for the single package or every contained PRD child followed by its parent.

8. **Clean proven-safe artifacts.**
   - After merge and lifecycle completion, remove the remote source branch only when it remains uniquely tied to this merged unit and is neither target nor default.
   - From another clean worktree, remove the linked source worktree and local branch under the same proof. Fetch and prune, then fast-forward a clean target worktree.
   - Preserve any dirty, unique, ambiguous, or unrelated artifact and name the reason.
   - Completion criterion: all proven-safe source artifacts are gone and the clean target is synchronized, or every retained artifact has one exact reason.

9. **Report the result.**
   - Report delivery unit, pull request, target, merge, lifecycle, Deployment disposition and implementation-handoff permalink, cleanup, and the one remaining operation when any.
   - Completion criterion: delivery, operational handoff, completion, and cleanup status are each clear without copying contracts, manifests, logs, or diffs.

## Completion Receipt

```markdown
## Completion

Completed by: <actor>
Delivery unit: <single issue package or parent PRD package>
Pull request: <URL and number>
Reviewed implementation head: <full commit SHA>
Target: <repository and branch>
Delivery evidence: <merge commit and pull request>
Verification / review: <linked evidence>
Deployment handoff: <none|standard|custom and Implementation receipt permalink>
Lifecycle outcome: completed
```

Cleanup follows authoritative completion and is reported separately.

## Boundaries

- Finish the whole claimed unit through its one authorized pull request; PRD children are not separate finish targets.
- Consume reviewed evidence and route implementation, CI, conflict, or scope defects to their owner.
- Preserve the Deployment disposition and conditional Manifest as an operational handoff; Finish neither executes deployment actions nor claims an environment is deployed.
- Preserve active workflow state until the workflow contract's completion point.
- Clean only artifacts proven to belong exclusively to the completed delivery unit.
