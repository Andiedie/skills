# Deployment Handoff

Read this reference when `and-implement` classifies the deployment needs of a reviewed delivery unit, when `and-finish` validates or links that handoff, or when `and-sweep` audits it.

## Authority And Selection

The Package Contract records confirmed deployment constraints known before implementation. Its `none known` value means no constraint was confirmed at packaging time; it does not preselect the `none` disposition. The Deployment disposition records the actual package-wide deployment class proven from the complete reviewed implementation. A Deployment Manifest supplies package-specific operational instructions only when that disposition is `custom`.

Select the latest issue comment headed `## Implementation` on the delivery-unit issue; earlier Implementation receipts are historical and never serve as fallback. Its `Deployment:` line is authoritative only when all of these hold:

- the receipt contains exactly one disposition;
- the receipt names one full reviewed implementation head;
- before merge, that head equals the current source-branch head and pull-request head when one exists; after merge, it equals the recorded pull-request head; and
- the disposition uses one complete form from this reference.

A changed source head makes the deployment handoff stale and routes the delivery unit to `and-implement`. Target-branch movement alone does not invalidate it. A PRD package has one disposition on its parent issue covering the parent contract, every contained child, and their integrated diff.

Use one explicit disposition:

- `none`: the reviewed delivery unit requires no environment rollout;
- `standard`: rollout uses only a named stable runbook and has none of the custom triggers below; or
- `custom`: rollout has at least one custom trigger and therefore requires a complete Deployment Manifest.

Record it in the Implementation receipt with exactly one of these forms:

```markdown
Deployment: none — <why no environment rollout is required>
Deployment: standard — <named environments>; <stable runbook link>
Deployment: custom — see Deployment Manifest below
```

For `none` and `standard`, the disposition is the complete handoff and the receipt must not contain a `## Deployment Manifest` section. For `custom`, the same receipt must contain exactly one complete Manifest from this reference.

The handoff is immutable operational guidance, not a mutable checklist, environment state, or proof of deployment. Stable procedures remain authoritative in repository runbooks; a standard disposition links them, while a custom Manifest records only this delivery unit's concrete delta.

## Inspection And Classification

`and-implement` classifies the disposition from the complete fixed-point diff, every contained PRD child, the Package Contract's deployment constraints, migrations, data scripts, configuration and infrastructure changes, documentation updates, and relevant stable runbooks. It explicitly checks application or service rollout, DDL, DML or backfills, configuration or secrets, infrastructure, external systems, release ordering, mixed-version compatibility, verification, and recovery.

Choose `custom` when any of these triggers applies:

- a required rollout is not fully governed by a named stable runbook;
- a DDL or schema migration;
- DML, data repair, or a backfill;
- a package-specific configuration, secret, infrastructure, or external-system change;
- multi-service sequencing or another package-specific execution order;
- behavior or actions that differ by environment;
- a mixed-version constraint, downtime requirement, or feature-flag sequence;
- a manual step, permission, or approval needed for rollout;
- rollback or forward-fix behavior that is not fully covered by the stable runbook; or
- package-specific deployment verification.

Choose `standard` only when rollout is required, a named stable runbook completely governs it, and none of those triggers applies. Choose `none` only when no environment rollout is required. Package size alone never determines the disposition.

Use exact migration identifiers, paths, commands, dashboards, or runbook links when they are the executable source. Record secret names and provisioning requirements without secret values. A custom action names its phase, target environment, owner or authority when external to the Agent, success evidence, retry or idempotency behavior, and rollback or forward-fix path where those facts affect safe execution.

A pre-merge requirement must link to its existing authoritative acceptance or external-blocker evidence. The Manifest does not own that requirement's status. If implementation discovers a new pre-merge requirement, route it to the stage or owner that can record the authoritative gate before completing the implementation handoff. Deployment prerequisites may remain for the deployment owner after merge; they name the required owner and evidence without claiming that either is complete.

Material implementation facts may refine the planned constraints. A refinement that changes product scope, risk acceptance, rollout policy, or another human-owned judgment routes to the owning upstream stage instead of being silently accepted in the handoff.

Completion criterion: the disposition is bound to the reviewed head and every deployment-affecting surface is accounted for. A `custom` disposition additionally has a complete Manifest whose verifiable instructions account for every custom trigger.

## Custom Deployment Manifest

Use this form only for a `custom` disposition:

```markdown
## Deployment Manifest

Delivery unit: <link or work ID>
Package summary: <one-line behavior change>
Reviewed implementation head: <full commit SHA>
Environments: <preview, staging, production, named environments, or all>
Stable runbook: <link or none>

### Change Inventory

- Application / services: <change or none>
- DDL / schema migrations: <identifiers, paths, locking or transaction facts, or none>
- DML / backfills: <identifiers, paths, volume or batching facts, or none>
- Configuration / secrets: <names and provisioning requirements, or none>
- Infrastructure: <change or none>
- External systems: <change or none>

### Prerequisites

- Pre-merge requirements: <authoritative acceptance or external-blocker links, or none>
- Deployment prerequisites: <owner and required evidence, or none>
- Environment rollout order: <delivery-unit, version, or environment sequencing constraints, or none>

### Ordered Execution

1. <phase, environment, action, owner or authority, and success evidence>

### Compatibility And Recovery

- Mixed-version compatibility: <constraint or not applicable>
- Retry / idempotency: <behavior>
- Rollback: <procedure and boundary, or unavailable with the required forward-fix authority>
- Irreversible actions / downtime: <risk, approval owner, and required evidence, or none>

### Verification

- <command, query, metric, log, smoke test, or observable result>
```

## Consumption

`and-finish` selects the authoritative disposition and checks its receipt and head identity, form, and internal consistency. For `custom`, it also checks the Manifest's head identity, schema completeness, internal consistency, and pre-merge evidence links. The exhaustive semantic inspection belongs to `and-implement`; Finish neither reconstructs the disposition or Manifest from the diff nor executes deployment actions or claims that an environment is deployed.

Environment rollout order governs only rollout sequencing; it does not replace a native dependency relationship or change work-record readiness. When the same prerequisite also blocks implementation, the Manifest links the authoritative native edge instead of duplicating it.
