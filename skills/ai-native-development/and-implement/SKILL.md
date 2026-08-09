---
name: and-implement
description: Implement a claimed AI-native delivery unit in an isolated worktree.
disable-model-invocation: true
---

# AND Implement

Implement the complete claimed delivery unit from its GitHub Package Contract. Work in one isolated worktree and finish with a committed, verified, reviewed diff plus durable implementation evidence.

## Runtime Contracts

Use `and-workflow-contract` with [work-records.md](../and-workflow-contract/work-records.md) and [delivery-units.md](../and-workflow-contract/delivery-units.md) for `Read Delivery Unit`, `Record Receipt`, and `Reference Implementation Artifact`. When the repository-owned review is called with AND context, load [review-attestation.md](../and-workflow-contract/review-attestation.md) for its attestation operation. Read [local-cleanup.md](../and-workflow-contract/local-cleanup.md) directly before creating a worktree-owned local resource and again before finalizing its reviewed handoff. Read [deployment-handoff.md](../and-workflow-contract/deployment-handoff.md) directly for `Read Deployment Handoff` before that handoff. Route incomplete setup or a missing contract to `setup-and`.

Real `tdd` and `code-review` skills are required. If either is unavailable, name the missing skill and stop with the documented installation route. Give `tdd` the Package Contract's agreed seam as confirmed input where test-first work is practical. Use `code-review` against the retained fixed point with the complete Package Contract and every acceptance-bearing PRD child supplied as the Spec.

## Preconditions

Begin only when the current actor owns or is delegated the complete open `ready-for-agent` delivery unit and no external blocker remains. A PRD claim covers its parent and every child.

Route an unready or unowned unit to the smallest upstream AND skill. If the current head already has clean implementation evidence, an authoritative Deployment disposition, and a valid optional Cleanup handoff when resources survive, plus a complete Deployment Manifest when Deployment is `custom`, route to `and-finish`. If implementation and review are clean but Deployment is missing or stale, or an emitted Cleanup handoff is malformed or stale, resume at handoff classification; route a linked non-authoritative finish proposal to `and-finish` before implementation resumes.

## Process

1. **Resolve the work.**
   - Read the claim, Package Contract, accepted decisions, deployment constraints, blockers, implementation artifacts, verification expectations, and every PRD child.
   - Require an agreed test seam or explicit non-test verification strategy. Route any omission to `and-pack`; when human judgment is required, resume through an existing State Reason or `and-triage` before `and-clarify`.
   - Completion criterion: the whole claim scope, expected behavior, dependency order, deployment constraints, blockers, seam, and verification path are known from GitHub.

2. **Isolate the diff.**
   - Inspect Git status, branches, worktrees, and linked artifacts. Reuse a worktree tied to this delivery unit only when all its changes are in scope; otherwise leave it untouched and create a dedicated branch and worktree, or stop when isolation cannot be proven.
   - Retain the full commit SHA that predates every delivery-unit change. For a new worktree use its branch point; for a reused worktree prove the fixed point still covers the whole diff.
   - Completion criterion: one isolated worktree contains no unrelated work, and one valid review fixed point covers its complete diff.

3. **Implement the contract.**
   - Plan from the Package Contract and PRD dependencies. Internal delegation remains under the parent claim owner.
   - When this path creates a worktree-owned local resource, load the shared cleanup authority before creation. Give every delegated creator a supported typed ownership identity, or require it to remove unsupported resources before the final handoff.
   - Use `tdd` at the agreed seam where practical. Work incrementally, run focused tests and typechecking regularly, then run the full relevant suite once the delivery unit is complete.
   - Apply required documentation or domain updates. For each Required item, retain its source, target, and reviewed diff evidence for the Implementation receipt. For None, retain its source and reason.
   - Before applying a Required item, re-read its target authority. Integrate compatible edits on the latest baseline and include them in complete-diff review; route semantic conflicts to `and-pack`.
   - Route a disputed disposition or new durable repository knowledge to `and-pack` before changing the contract.
   - On abort before a valid final handoff, clean and verify every owned resource or append the exact residual and resume evidence required by the shared cleanup authority.
   - Route an incorrect boundary, unclear verification requirement, or new human judgment to its owning stage instead of changing scope locally.
   - Completion criterion: code, tests, and required docs satisfy every parent and child requirement, or one evidenced upstream blocker is named.

4. **Review the complete diff.**
   - Commit the scoped review candidate so no relevant change exists only in the working tree.
   - Verify the fixed point still resolves, then invoke the repository-owned `code-review` with that fixed point and the complete GitHub Package Contract plus every acceptance-bearing PRD child supplied as the Spec. Provide the delivery-unit identity and complete authority records so the shared conditional mode is selected; a generic call without that context stays generic.
   - Fix in-scope implementation findings, update the scoped commit, rerun relevant verification, and review the same complete diff again. Spec review checks each documentation item against its source, Package entry, and diff. Route contract defects to `and-pack`; route human-owned judgments through the current State Reason owner or `and-triage` when no decision route exists.
   - When attestation mode is active, call the shared `render` operation and retain its exact block bytes for the later Implementation receipt. Do not append a GitHub comment or perform readback in this review step; do not transcribe, reinterpret, or publish another review receipt.
   - Completion criterion: Standards and Spec review are clean, or every remaining finding is explicitly outside scope or human-owned.

5. **Classify deployment and local cleanup handoffs.**
   - After the review is clean, apply the shared Deployment Handoff inspection standard to the complete fixed-point diff, Package Contract, every PRD child, migrations, data scripts, configuration, infrastructure, documentation, and stable runbooks.
   - Bind one Deployment disposition to the reviewed implementation head. Choose `none`, `standard`, or `custom` only after every deployment-affecting surface has been inspected. Any shared custom trigger requires `custom` and a complete Deployment Manifest; `none` and `standard` use only their one-line disposition and must not include a Manifest.
   - If inspection exposes missing in-scope implementation or documentation, return to implementation, repeat verification and review, then regenerate the handoff for the new head.
   - Route a missing contract decision to `and-pack` and a new human-owned rollout or risk judgment through its current State Reason owner or `and-triage`. For a custom Manifest, link every pre-merge requirement to its existing acceptance or external-blocker authority; keep later external actions as deployment prerequisites with their owner and required evidence.
   - Completion criterion: one disposition bound to the reviewed head accounts for the whole delivery unit without unowned ambiguity or unstated deployment-affecting surfaces, and `custom` additionally has one complete Manifest covering every custom trigger.
   - Account for every local-resource creator. When no worktree-owned local resource remains for Finish, omit Cleanup entirely; do not create a cleanup identity or query a runtime to justify the omission. Otherwise record `Cleanup: required` with each surviving supported typed item. Remove unsupported or unowned resources before handoff.
   - After any later authorized action, apply the handoff-refresh rules in [local-cleanup.md](../and-workflow-contract/local-cleanup.md) before Finish. If inspection exposes missing ownership or a silent residual, return to implementation or cleanup and regenerate the handoff.
   - Completion criterion: Deployment is bound to the reviewed head, Cleanup is omitted when no worktree-owned local resource remains for Finish or is a complete `required` handoff for surviving supported resources, and only Deployment `custom` has a Manifest.

6. **Record the handoff.**
   - Verify every delivery-unit change is committed on the isolated branch and append the `## Implementation` receipt to the delivery-unit issue.
   - After the GitHub comment is written, attestation mode immediately runs shared `extract` against that comment's node/permalink, compares the exact block bytes and reviewed implementation head, and retains the node/permalink readback; a mismatch is a failed persistence check.
   - Include the Deployment disposition in the receipt and include `Cleanup: required` with typed items only when supported resources survive; omit Cleanup entirely otherwise. Include a Deployment Manifest only for Deployment `custom`. Link the branch, reviewed head, pull request, CI, review, and cleanup evidence when they exist. Leave PR delivery, lifecycle completion, deployment execution, and valid handed-off terminal cleanup to their owning stages.
   - Completion criterion: implementation and the reviewed-head-bound Deployment disposition, plus any required Cleanup handoff, are committed, verified, reviewed, and recoverable from one GitHub receipt, or routed back with the smallest blocker.

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
Review attestation:
<embed the complete block emitted by shared attestation render unchanged when AND context is supplied; omit this section for generic review>
Docs / domain updates:
- <source, target, and reviewed diff evidence for each Required item; or source and reason for None>
Remaining blockers:
- <none or blocker>
Deployment: <none — reason | standard — environments; stable runbook link | custom — see Deployment Manifest below>
<omit Cleanup when no owned local resource remains; include the required form only for surviving supported resources>
Next step:
- <and-finish, acceptance owner, or route back>

<for `custom` only: complete `## Deployment Manifest` form from deployment-handoff.md>
<for Cleanup `required` only: complete typed cleanup items from local-cleanup.md>
```

Report only the worktree, branch, reviewed head, pull request when any, verification and review result, Deployment disposition, Cleanup handoff and typed items when required, Deployment Manifest link when required, blocker when any, and next step.

## Boundaries

- Keep implementation in the claimed delivery unit and its isolated worktree.
- Use the GitHub Package Contract, not chat, pick, or claim summaries, as the Spec.
- Keep parent ownership unchanged when delegating PRD children internally.
- Let `and-finish` own pull-request delivery, terminal lifecycle state, and valid handed-off terminal cleanup; Implement owns every creator until its resource is absent or validly handed off.
