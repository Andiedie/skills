---
name: issue-claim
description: Claim an executable delivery unit without changing its scope.
disable-model-invocation: true
---

# Issue Claim

Claim records ownership for work that has already been picked. The claim unit must match the delivery unit: one ordinary issue, or one PRD package.

## Claimable work

Work can be claimed only when it is:

- an ordinary `ready-for-agent` issue, or a `parent-prd` with `ready-for-agent`
- open
- unblocked by external work
- unclaimed
- specified enough to implement

For a PRD package, claiming the parent PRD claims all of its children. PRD children cannot be claimed separately.

## Process

1. Resolve the claim unit.
   - Identify whether the claim is an ordinary issue or a PRD package.
   - For an ordinary issue, read labels, comments, assignees, blockers, linked PRs, and related issues.
   - For a PRD package, read the parent PRD, every child issue, child ordering blockers, external blockers, assignees, claim comments, and linked PRs.
   - If this follows `issue-pick`, compare the claim target with the pick report.
   - Completion criterion: the complete delivery unit is named and no child, sibling, or parent scope is hidden.

2. Validate claimability.
   - Reject PRD children claimed without their parent PRD.
   - Reject delivery units with open external blockers.
   - Reject work already claimed by assignee, claim comment, active branch, or active PR. For a PRD package, any claimed child means the package is already partly claimed.
   - Route unclear scope or broken PRD child structure to `issue-pack`.
   - Completion criterion: the claim is valid, or the report names the correct route back to `issue-pick`, `issue-pack`, or `needs-info`.

3. Confirm side effects.
   - State claimant, issues affected, claim comment, assignee changes, branch or PR link, and any ownership metadata.
   - For a PRD package, state that the parent and all children will be covered by one claim.
   - If the user already gave an explicit claim instruction, include this confirmation in the action summary before applying.
   - Completion criterion: the durable tracker edits are known before they happen.

4. Apply the claim.
   - Prefer assignee plus claim comment.
   - For a PRD package, apply ownership to the parent PRD and comment with the full child list.
   - Link an existing branch or draft PR when available.
   - Add ownership labels only when the repository setup explicitly defines them.
   - Use the claim template below.
   - Completion criterion: the tracker shows one clear owner for the whole delivery unit.

5. Report.
   - Include claim links, owner, delivery unit, dependencies checked, and the Matt `implement` handoff.
   - Completion criterion: an implementation agent can start Matt `implement` from the claim.

## Claim comment

```markdown
## Claim

Claimed by: <actor>
Claim unit: <ordinary issue or PRD package>
Scope: <complete delivery unit>
Children covered: <none or child issue list>
Dependencies checked: <none, internal order, or external blocker list>
Expected next artifact: <branch, draft PR, or implementation update>
```

## Boundaries

- Do not change scope during claim.
- Do not claim PRD children independently.
- Do not claim around unresolved external blockers.
- Do not release or override another owner without explicit approval.
