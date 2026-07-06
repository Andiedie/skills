---
name: issue-claim
description: Claim an executable delivery unit without changing its scope.
disable-model-invocation: true
---

# Issue Claim

Claim records ownership for work that has already been picked. The claim unit must match the delivery unit: one single issue package, or one PRD package.

## Claimable work

Work can be claimed only when it is:

- a single issue package with `ready-for-agent`, or a `parent-prd` with `ready-for-agent`
- open
- `ready-for-agent`
- not carrying `needs-info` or `needs-pack`
- unblocked by open external work
- unclaimed
- specified enough to implement

For a PRD package, claiming the parent PRD claims all of its children. PRD children cannot be claimed separately through the tracker workflow, though the parent owner may use them as internal subagent work units.

## Process

1. Resolve the claim unit.
   - Identify whether the claim is a single issue package or a PRD package.
   - For a single issue package, read labels, comments, assignees, blockers, linked PRs, active branches, and related issues.
   - For a PRD package, read the parent PRD, every child issue, child ordering blockers, external blockers, assignees, claim comments, and linked PRs.
   - If this follows `issue-pick`, compare the claim target with the pick report.
   - Completion criterion: the complete delivery unit is named and no child, sibling, or parent scope is hidden.

2. Validate claimability.
   - Reject PRD children claimed without their parent PRD.
   - Reject delivery units that are not `ready-for-agent`, or that still carry `needs-info` or `needs-pack`.
   - Reject delivery units with open external blockers.
   - Reject work already claimed by assignee, claim comment, active branch, draft PR, or active PR. For a PRD package, any claimed child means the package is already partly claimed.
   - Absence of ownership evidence satisfies `unclaimed`.
   - If existing ownership evidence looks old or inactive, report it as possibly stale; do not release or override it without explicit approval or an `issue-sweep` route.
   - Route unclear scope, weak package contract, missing verification, or broken PRD child structure to `issue-pack`.
   - Reject or route hard blockers here; do not move them into confirmation gates. Open external blockers, unclaimable targets, PRD child claims, and scope-changing claims cannot be made safe by confirmation.
   - Completion criterion: the claim is valid, or the report names the correct route back to `issue-pick`, `issue-pack`, `issue-sweep`, or `needs-info`.

3. Prepare side effects and check confirmation gates.
   - State claimant, issues affected, claim comment, assignee changes, branch or PR link, and any ownership metadata.
   - For a PRD package, state that the parent and all children will be covered by one claim.
   - If known, record any internal subagent split as delegation under the parent owner, not as separate ownership.
   - Treat invocation as authorization to claim the resolved delivery unit after claimability validation.
   - Ask before applying ownership changes only when the claim target is ambiguous, the claimant is ambiguous, the delivery-unit boundary is unclear, existing ownership or active work exists, stale ownership must be released or overridden, or tracker permissions/access are unclear.
   - Completion criterion: the claim side effects are safe to apply, or one exact confirmation question is asked with the ownership risk named.

4. Apply the claim.
   - Prefer assignee plus claim comment.
   - For a PRD package, apply ownership to the parent PRD and comment with the full child list.
   - Add child coverage comments only when repository setup explicitly requires them.
   - Link an existing branch or draft PR when available.
   - Add ownership labels only when the repository setup explicitly defines them.
   - Use the claim template below.
   - Completion criterion: the tracker shows one clear owner for the whole delivery unit.

5. Report.
   - Keep the user-facing report as a short receipt; the claim comment is the durable structured record.
   - Include claim links, owner, delivery unit, material dependency or ownership risks, and the `issue-implement` handoff.
   - Do not repeat the Package Contract or child issue bodies in chat.
   - Omit empty risk sections.
   - Completion criterion: an implementation agent can start `issue-implement` from the claim.

## Claim comment

```markdown
## Claim

Claimed by: <actor>
Claim unit: <single issue package or PRD package>
Scope owner: <single issue package or parent PRD>
Children covered: <none or child issue list>
External blockers checked: <none or list>
Existing ownership checked: <assignee, comment, branch, or PR evidence>
Internal delegation: <none or child slices delegated under this claim>
Expected next step: <run issue-implement, branch, draft PR, or implementation update>
```

## Boundaries

- Do not change scope during claim.
- Do not claim PRD children independently.
- Do not claim around unresolved external blockers.
- Do not claim work with stale ownership evidence unless release or override has been explicitly approved.
- Do not release or override another owner without explicit approval.
