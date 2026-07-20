---
name: and-sweep
description: Audit AND workflow drift and stale work.
disable-model-invocation: true
---

# AND Sweep

Sweep audits GitHub workflow state for drift that can make delivery unsafe. Every finding is classified before mutation:

- **Detect:** the default; report authoritative drift without changing it.
- **Normalize:** when the user explicitly asks to fix or normalize, apply reported, unambiguous low-risk representation fixes without a second confirmation.
- **Repair:** changes to meaning or authority require explicit approval for the exact mutation, or route to the owning workflow skill.

## Workflow Contract

Use `and-workflow-contract` before auditing, then read [sweep-checks.md](../and-workflow-contract/sweep-checks.md). Read [deployment-handoff.md](../and-workflow-contract/deployment-handoff.md) when the selected scope contains reviewed implementation or Finish evidence.

Use `Locate Work`, `Read Work Record` or `Read Delivery Unit`, and `Audit Invariants`, then apply the direct Sweep checklist. Those authorities own exact state, relationship, ownership, receipt, lifecycle, Wayfinding, and representation checks; Sweep owns finding classification and repair control.

If repository setup or the contract is unavailable, stop and route to `setup-and` or ask the user to install the missing skill.

## Scope

Default to open work in the current repository. Respect a specific work ID, ready slate, stage, PRD, map, ownership condition, or other bounded subset supplied by the user. Use an explicit limit or pagination.

Ask one direct question before a large, cross-repository, destructive, or ambiguous scope. A plain audit or sweep request selects Detect; a clear fix or normalize request authorizes only matching low-risk normalizations.

## Audit Coverage

Apply every relevant workflow invariant and Sweep Check. The required domains are:

- stage, State Reason, and lifecycle;
- package shape, relationships, dependencies, and external blockers;
- whole-unit ownership, stale or conflicting claims, implementation artifacts, deployment handoffs, and duplicate-work risk;
- Wayfinding maps, investigations, handoff, and temporary assets;
- completion evidence and GitHub representation.

Read a complete delivery unit when a finding can block Pick, Claim, implementation, or completion. Skip only checks that do not apply to the selected records. A required GitHub capability that is missing or unverified is a `setup-and` finding, not a skipped check.

## Finding Classes

### Detect

Detect is read-only. Report the observed state, expected state and authority, evidence, delivery impact, and smallest next action. When no authority exists or plausible authorities conflict, preserve the conflict and classify any proposed resolution as Repair.

### Normalize

A normalization must satisfy all of these conditions:

- the expected state is uniquely derived from the workflow contract;
- the change is representation-only, bounded, and reversible;
- it preserves scope, package shape, relationship and dependency intent, blocker meaning, ownership, readiness, and lifecycle outcome;
- it was reported before mutation and falls within the requested fix or normalize scope.

Examples include removing public stage state from a PRD child or investigation, or removing a contradictory duplicate stage when one authoritative stage is proven. Examples do not override the criteria.

Re-read the target immediately before mutation. If evidence changed or the expected state is no longer unique, return the finding to Detect or Repair.

### Repair

Repair covers changes that choose or alter workflow meaning or authority, including ownership release or override, lifecycle outcome, readiness, blocker intent, scope or package shape, relationship or dependency intent, and resolution of conflicting authorities.

State the exact proposed mutation, authority, impact, and rollback or route, then wait for explicit approval. Sweep may apply an approved repair only when it restores workflow consistency without performing another stage's decision; package publication, triage outcomes, implementation, merge, and lifecycle completion route to their owning skills. Record an applied repair on the affected GitHub work record with the changed authority, approval, evidence, verified result, and next route.

Sweep never silently releases or overrides ownership, closes or reopens work, marks work ready, rewrites scope, removes blockers, changes relationship intent, or chooses among conflicting authorities.

## Process

1. **Resolve scope and mode.** Determine the GitHub repository, bounded query, pagination strategy, and whether this run is Detect or explicitly requested Normalize.
   - Completion criterion: the audit boundary and mutation budget are explicit.

2. **Collect and audit.** Read authoritative records for the scope, apply `Audit Invariants` and every relevant Sweep Check, and inspect complete delivery units where execution safety is involved.
   - Completion criterion: each relevant check is passed, a finding, or a named confidence gap.

3. **Classify and report.** Classify each finding as Detect, Normalize, or Repair and report it before any mutation. Omit passed checks and empty groups.
   - Completion criterion: each finding has one authority, impact, and next action, or explicitly preserves an authority conflict.

4. **Act and verify.** Detect stops after reporting. Normalize applies only requested low-risk changes. Repair waits for exact approval and applies only Sweep-owned consistency repair; otherwise route it. Re-read before every write, do not expand the reported change, and verify authoritative state afterward.
   - Completion criterion: every attempted mutation matches its authorization and is verified, while every remaining finding has a route or explicit no-action status.

## Report Shape

When there are no findings:

```markdown
No workflow drift found.
Scope: <query and count>
Repository: <GitHub owner/repository>
```

When there are findings:

```markdown
Sweep: <scope and GitHub repository>

- [Detect|Normalize|Repair] <work>: <observed> -> <expected>
  Authority/evidence: <source and fact>
  Impact/action: <delivery impact and route, applied normalization, or exact approval needed>
```

After mutation, append only:

```markdown
Applied:
- <work>: <verified change>

Remaining:
- <work>: <route, approval, or no action>
```

Omit empty sections, passed-check inventories, full work records, raw API dumps, and unapproved changes phrased as completed work.
