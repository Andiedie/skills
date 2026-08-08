---
name: and-finish
description: Merge and complete one reviewed AND delivery unit, then clean its delivery artifacts.
disable-model-invocation: true
---

# AND Finish

Finish is a resumable transaction: publish one reviewed delivery unit through one authorized GitHub pull request, make its lifecycle completion authoritative in GitHub, then remove only typed local resources and source artifacts proven safe to clean. Derive completed steps from evidence instead of repeating them.

## Runtime Contracts

Use `and-workflow-contract` with [work-records.md](../and-workflow-contract/work-records.md) and [delivery-units.md](../and-workflow-contract/delivery-units.md) for `Read Delivery Unit`, `Finish Delivery`, `Record Receipt`, and `Record Lifecycle Outcome`. Read [deployment-handoff.md](../and-workflow-contract/deployment-handoff.md) and [local-cleanup.md](../and-workflow-contract/local-cleanup.md) directly for their handoff operations when resolving, revalidating, or resuming the implementation handoff. Route incomplete setup to `setup-and`; stop before mutation when the Git remote does not identify one GitHub repository.

## Preconditions

Before merge, the current actor owns or is delegated one open `ready-for-agent` delivery unit whose latest Implementation receipt identifies a committed reviewed head, verification, clean review, an authoritative Deployment disposition, and, when present, a complete `Cleanup: required` handoff for that head. A complete Deployment Manifest is required when Deployment is `custom`; complete typed items are required when Cleanup is `required`. Required acceptance must be complete and no external blocker may remain. On resume after merge, the pull request and GitHub evidence must identify the same original scope and actor.

Route stale implementation or review evidence to `and-implement`, contract defects to `and-pack`, and ownership, relationship, stage, or lifecycle drift to `and-sweep`.
Report pending acceptance as a wait for its recorded owner without mutation.

## Process

1. **Resolve the transaction.**
   - Read the complete delivery unit, claim, contract, every PRD child, Implementation receipt, Deployment disposition and any present Cleanup handoff, the conditional Deployment Manifest or typed cleanup items when required, verification, review, acceptance, blockers, relationships, and linked artifacts.
   - Resolve the actor, source branch and worktree, reviewed head, implementation-handoff permalink, fixed point, GitHub repository, default branch, explicit target when any, merge policy, and one matching open or merged pull request.
   - Prove the actor can push, create or update and merge the pull request, and complete GitHub workflow state. Match pull requests by repository, source, and target; multiple or mismatched matches are ambiguity, not permission to create another.
   - Completion criterion: scope, owner, source, reviewed head, Deployment disposition and any present Cleanup handoff, repository, target evidence, capabilities, and pull-request identity are unambiguous.

2. **Prove delivery readiness.**
   - Before merge, verify the claim still covers the complete executable package, no blocker is open, and the reviewed head exists on the source branch.
   - Inspect the fixed-point diff and commits after the reviewed head. The source worktree must be clean, every PRD child integrated, and no unreviewed implementation or scope change may follow the reviewed head.
   - Apply the shared deployment-handoff selection and validation rules to the latest Implementation receipt. Rely on Implement's exhaustive inspection rather than reconstructing the disposition or Manifest from the diff.
   - Apply the shared local-cleanup selection and form validation to the same receipt. An omitted Cleanup field is a valid no-handoff path and requires no resource-runtime access; for Cleanup `required`, validate every typed item and retain its recovery inputs without performing cleanup.
   - Preserve deployment prerequisites for the deployment owner rather than treating them as completed or executing them in Finish.
   - On post-merge resume, prove the recorded pull-request head contains the reviewed head and the authorized target contains the merge result.
   - Inspect cleanup candidates for unrelated changes or unique commits.
   - Completion criterion: the complete reviewed unit and its authoritative Deployment disposition, plus any present Cleanup handoff, are ready to publish or resume, and every cleanup candidate is classified as safe or retained.

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
   - Immediately before merge, re-read the delivery unit, claim, acceptance, blockers, contract, Implementation receipt, Deployment disposition and any present Cleanup handoff with its conditional Deployment Manifest or typed cleanup items, source worktree, remote branch, pull request, checks, reviews, conflicts, target, and cleanup candidates.
   - Reapply shared handoff head-binding and form validations to the final head. Prove required checks, reviews, acceptance, and blocker evidence apply to that head and are successful, no blocking review or conflict remains, and GitHub reports it mergeable.
   - Report a genuine external wait without claiming completion. Route a changed head, stale or defective handoff, or implementation defect back to `and-implement`; route a contract defect to `and-pack`; route conflicting authorities to `and-sweep`; and verify the source still represents open work.
   - Completion criterion: the current pull-request head is safe to merge, or one precise wait or owning route is named.

6. **Merge exactly once.**
   - Reuse verified merge evidence on resume; otherwise merge with the authorized method and keep source cleanup outside the merge operation.
   - Verify GitHub records the merge and the target contains its result. Retain the pull request, reviewed head, and target evidence.
   - Completion criterion: delivery to the authorized target is proven exactly once.

7. **Complete workflow state.**
   - Run the workflow contract's post-merge Finish Delivery steps for exactly the claimed unit. For a PRD, verify every claimed child requirement is integrated, complete every contained child, then complete the parent; leave merely related work unchanged.
   - If merge succeeded but lifecycle completion did not, resume only that operation. Route contradictory state to `and-sweep`.
   - Completion criterion: GitHub records `completed` with delivery evidence for the single package or every contained PRD child followed by its parent.

8. **Clean typed local resources.**
   - Preserve the order lifecycle completion, typed local cleanup, then Git cleanup. When Cleanup is omitted, perform no resource-runtime operation.
   - For Cleanup `required`, re-read each item and apply only its shared type rules. Treat already-absent owned resources as complete.
   - On an unavailable or mismatched runtime, missing ownership, or failed action, append the exact residual IDs or names, failed operation, runtime, and resume point; retain every recovery-bearing source artifact; and resume here without repeating merge or lifecycle completion.
   - Completion criterion: every typed item verifies absent, or exact residual evidence and the recovery-bearing Git artifacts remain.

9. **Clean proven-safe Git artifacts.**
   - Only after local cleanup verification, remove the remote source branch when it remains uniquely tied to this merged unit and is neither target nor default.
   - From another clean worktree, remove the linked source worktree and local branch under the same proof. Fetch and prune, then fast-forward a clean target worktree.
   - Preserve any dirty, unique, ambiguous, or unrelated artifact and name the reason.
   - Completion criterion: all proven-safe source artifacts are gone and the clean target is synchronized, or every retained artifact has one exact reason and resume point.

10. **Report the result.**
   - Report delivery unit, pull request, target, merge, lifecycle, the Deployment disposition, any Cleanup handoff and implementation-handoff permalink, local cleanup result when applicable, and the one remaining operation when any.
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
- Consume only supported typed cleanup items; never infer ownership, execute receipt-supplied commands, or treat local cleanup as deployment evidence.
- Preserve active workflow state until the workflow contract's completion point.
- Clean only artifacts proven to belong exclusively to the completed delivery unit.
