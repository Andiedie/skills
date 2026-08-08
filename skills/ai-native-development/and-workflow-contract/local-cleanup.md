# Optional Local Cleanup Handoff

Read this reference when an implementation path creates a worktree-owned local resource, when `and-implement` prepares or refreshes its final handoff, or when `and-finish` validates or performs terminal local cleanup.

## Responsibility And Disposition

A worktree-owned local resource is created exclusively for one delivery unit's implementation worktree. Creation ownership, not later use, makes its creator accountable until the resource is verified absent or accepted by a supported typed cleanup handoff.

When no worktree-owned local resource remains for Finish, omit Cleanup entirely. An omitted Cleanup field requires no cleanup identity or access to any resource runtime. It carries no history of resources that were already removed, and absence is not a request for runtime discovery.

When a supported worktree-owned local resource survives for Finish, the same latest reviewed-head-bound Implementation receipt uses the only emitted Cleanup form:

```markdown
Cleanup: required — see typed cleanup items below
```

`Cleanup: required` is valid only with one or more supported typed items in that same receipt:

```markdown
### Cleanup Items
- docker-compose: runtime=<Docker context and daemon identity>; project=<exact project>; files=<exact Compose files>
- docker-label: runtime=<Docker context and daemon identity>; selector=<exact AND cleanup label>
```

The receipt never stores or executes an arbitrary cleanup command. Each kind's rules below are the only cleanup behavior it authorizes. Unsupported resources must be removed and verified by their creator before the final handoff.

Select the latest issue comment headed `## Implementation`; older receipts are history, not fallback. The latest receipt is authoritative for local cleanup only when it contains exactly one full reviewed head and either no Cleanup field or one complete `Cleanup: required` form, the head matches the current source and pull-request head before merge or the recorded pull-request head after merge, and every required item uses a supported form. A changed head, malformed required handoff, or explicit contradiction routes back to `and-implement`.

If a later authorized action leaves a new owned resource, publish one complete superseding Implementation receipt before Finish. Its required item list covers every supported resource still handed to Finish; it is not a partial overlay, amendment, event ledger, standalone cleanup receipt, or mutable inventory. An action that only uses pre-existing, shared, external, bind-mounted, or merely used resources, or that removes and verifies its own resources before ending, needs no handoff refresh. When only cleanup state changes and the source head and Package Contract are unchanged, the refreshed receipt may reuse the reviewed head and clean review evidence after revalidating the complete item list. A changed source head follows normal verification and review.

## Creator Responsibility

Before creating a supported local resource, the creator chooses its typed ownership identity, supplies it to every delegated skill, Agent, or tool that may create the resource, and retains the item for the final handoff. A creator may instead remove and verify the resource as soon as it is no longer needed; it then omits Cleanup from the final receipt.

If implementation stops before a valid final handoff, the creator removes its resources. When that cannot complete, append exact residual identities, runtime, failed operation, accountable owner, and resume condition to the delivery-unit issue. Never leave a silent residual behind an omitted Cleanup field.

## Docker Types

Docker v1 supports only the two item kinds above:

- `docker-compose` uses a unique Compose project created by this delivery and exact Compose files retained in the source worktree. The recorded runtime names both Docker context and daemon identity.
- `docker-label` uses one exact implementation-scoped AND label applied when non-Compose containers, networks, and named volumes are created. Non-Compose creators use a labeled named volume instead of an anonymous volume so ownership survives independently of its container. Remove labeled containers first, then labeled networks, then labeled volumes.

Together the Docker types cover each owned container, network, named volume, and anonymous volume: Compose cleanup removes its attached anonymous volumes, while non-Compose creators use labeled named volumes. A pre-existing, shared, external, bind-mounted, or merely used resource is never relabeled, adopted, stopped, or deleted. Compose external resources and bind-mount contents remain outside the deletion set.

Resource names and worktree paths are not ownership proof. Do not use `prune`, substring-only matching, globs, unresolved variables, or all-object deletion. The creator-assigned Compose project or exact AND label is the positive deletion boundary.

## Finish Consumption

Before merge, `and-finish` validates the latest receipt, reviewed head, required item forms, and retained Compose files without performing cleanup. An omitted Cleanup field is a valid no-handoff path and requires no Docker access.

After merge and after lifecycle completion is authoritative, Finish performs no resource-runtime operation when Cleanup is omitted. For `Cleanup: required`, it processes each item only when the current Docker context and daemon identity match its recorded runtime:

- For `docker-compose`, use the retained files and exact project to remove the project with its owned volumes and orphans, then verify no project-labeled container, network, or volume remains.
- For `docker-label`, remove exactly matching containers, networks, and volumes in that order, then verify the selector returns no object.

An already-absent owned object is complete. An unavailable or mismatched runtime, missing ownership, or failed action is incomplete cleanup: append the exact residual IDs or names, failed operation, runtime, and resume point; retain the source worktree and branches; and resume `and-finish` at local cleanup without repeating merge or lifecycle completion.

Only after every required item verifies absent may Finish remove recovery-bearing Git artifacts. Successful cleanup is reported in Finish's result without a second mandatory success receipt.

## Boundary

Local cleanup is separate from Deployment disposition and never proves an environment deployed. Images, build cache, registries, remote resources, host bind-mount contents, unsupported local resource kinds, DDL, DML, secrets, infrastructure, and external systems are outside this authority.
