---
name: and-interview-contract
description: Apply AND interview evidence, recovery, domain-modeling, and artifact-output rules when another AND skill runs a human decision interview.
---

# AND Interview Contract

Shared reference for AND decision interviews. It makes confirmed results recoverable and ready for the calling workflow skill's next mutation without owning interview cadence or workflow state.

The calling workflow skill owns its target, backend mutations, receipts, stage, and lifecycle. `grilling` owns question cadence. This contract owns evidence quality, local recovery, backend-safe domain modeling, and compact structured output.

## Inputs

The workflow skill supplies:

- its canonical skill name;
- interview objective: `clarify-decision`, `chart-map`, or `resolve-investigation`;
- canonical repository identity;
- configured-backend work-record identity;
- one focused decision boundary, destination question, or investigation question;
- current authoritative backend evidence.

Read authoritative backend state before loading local recovery.

## Evidence

Keep facts and human-owned decisions distinct while `grilling` conducts the exchange:

- Establish facts from code, tests, docs, configured-backend state, or another authoritative source whenever practical.
- Resolve a human-owned decision only from an authoritative maintainer decision, a direct user answer, or explicit acceptance of a recommendation.
- Use repository evidence to inform recommendations, not to authorize product, domain, architecture, naming, testing, or acceptance choices.
- Treat guesses, partial answers, ambiguous text, and unaccepted recommendations as unresolved.

Read [backend-safe-domain-modeling.md](backend-safe-domain-modeling.md) for every interview and keep its active discipline inside the supplied boundary.

## Recovery

Use one disposable local buffer for confirmed interview results between backend writes. The configured backend remains authoritative.

- Use the platform's standard per-user temporary directory as `<system-temp>`.
- Resolve identities through `and-backend-contract`: `and-clarify` uses session-recovery identity; `and-wayfind` uses durable-workflow identity so map promotion and worktree changes do not move its buffer. A chart interview targets the top-level map identity; an investigation interview targets that investigation's stable identity, keeping parallel HITL buffers distinct.
- Derive the key through the backend contract's deterministic operation-key rules with namespace `<workflow-skill>:v1`. Locate the buffer at `<system-temp>/<workflow-skill>/<key>.md`.
- A materially confirmed result changes package scope, canonical terminology, architecture, acceptance, required documentation, chart destination or scope, or the durable answer to an investigation.
- The checkpoint is the SHA-256 hash of the buffer from `## Confirmed result` through `## Current unresolved question`, with LF line endings and exactly one final newline.

Use this shape:

```markdown
# Interview Recovery Buffer

Workflow skill: <and-clarify or and-wayfind>
Repository: <canonical identity>
Work record: <backend identity>
Checkpoint: <digest>

## Confirmed result
## Current unresolved question
```

For `chart-map`, insert `## Investigation candidates` and `## Remaining fog` immediately before `## Current unresolved question`. When present, add `## Required repository updates` and then `## Acceptance implications` in that order after `## Confirmed result`. Every added section stays inside the checkpoint range.

On resume, reconcile the matching buffer with newer backend state. Treat it as synchronized only when the corresponding backend receipt contains the same valid checkpoint; retain unsynchronized confirmed content and surface a conflict before continuing.

Create the buffer lazily after the first materially confirmed result. Rewrite the complete cumulative structure after each later material confirmation and recompute its checkpoint. Keep partial reasoning, ordinary dialogue, credentials, and unconfirmed recommendations out of it.

If the buffer cannot be written or its checkpoint cannot be verified, stop before advancing workflow state and report the local recovery failure.

## Interview Output

Return one complete, compact result. Its primary output is:

- `clarify-decision`: the confirmed decisions and rationale needed to resolve one bounded decision space, one precise remaining blocker, or destination-level uncertainty routed to `and-wayfind` when later questions depend on investigation;
- `chart-map`: confirmed destination and scope, currently sharp investigation candidates with methods and dependencies, and any remaining fog;
- `resolve-investigation`: one durable answer with required evidence and asset disposition, or one precise remaining blocker.

Include repository updates or acceptance implications only when they are confirmed package inputs under the backend-safe domain-modeling rules. Leave absent categories out of the result.

A chart result is complete while multiple investigations and fog remain. It leaves every investigation open and package readiness unset.

Before returning a resolved result, obtain the final shared-understanding confirmation required by `grilling`. It confirms the result rather than granting separate permission for the routine backend write.

Delete the matching buffer only after every required backend mutation is verified. Retain it when synchronization fails. Cleanup failure after authoritative synchronization is a local warning, not a workflow rollback.

## Completion Criteria

The contract is complete when:

- every fact and human-owned decision required by the current interview objective has an allowed source;
- every material result is recoverable with a valid checkpoint;
- required package-ready outputs preserve exact confirmed meaning and absent artifact categories are omitted;
- `clarify-decision` resolves one bounded decision space with confirmed decisions and rationale, or returns one precise blocker or destination-level `and-wayfind` route;
- `chart-map` has a confirmed destination, scope, first visible frontier, and explicit remaining fog without resolving an investigation;
- `resolve-investigation` has one durable answer or one precise blocker;
- final shared understanding is confirmed before returning a resolved output;
- one compact complete result is returned without this contract mutating workflow state.

## Boundaries

- Workflow state and durable receipts remain with the calling skill and configured backend.
- Repository docs, ADRs, glossary files, tests, and implementation files remain unchanged; required edits are package inputs for claimed implementation.
- An isolated investigation asset and its disposition remain linked evidence owned by the calling workflow, not a mutation by this contract.
