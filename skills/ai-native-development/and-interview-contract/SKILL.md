---
name: and-interview-contract
description: Apply AND interview evidence, recovery, domain-modeling, and artifact-output rules when another AND skill runs a human decision interview.
---

# AND Interview Contract

Shared reference for AND decision interviews. It makes confirmed results recoverable and ready for the calling workflow skill's next mutation without owning workflow state.

The calling workflow skill owns its target, backend mutations, receipts, stage, and lifecycle. This contract owns evidence quality, local recovery, domain-modeling discipline, and structured interview output.

## Inputs

The workflow skill supplies:

- its canonical skill name;
- interview objective: `clarify-decision`, `chart-map`, or `resolve-investigation`;
- canonical repository identity;
- configured-backend work-record identity;
- the decision boundary or investigation question;
- current authoritative backend evidence.

Read authoritative backend state before loading local recovery.

## Evidence

Keep facts and human-owned decisions distinct:

- Establish facts from code, tests, docs, configured-backend state, or another authoritative source whenever practical.
- Resolve a human-owned decision only from an explicit authoritative maintainer decision, a direct user answer, or explicit acceptance of a recommendation.
- Use repository evidence to inform recommendations, not to authorize product, domain, architecture, naming, testing, or acceptance choices.
- Treat guesses, partial answers, ambiguous text, and unaccepted recommendations as unresolved.

Read [backend-safe-domain-modeling.md](backend-safe-domain-modeling.md) and keep its discipline active throughout every interview.

## Recovery

Use one disposable local buffer for confirmed interview results between backend writes. The configured backend remains authoritative.

- Use the platform's standard per-user temporary directory as `<system-temp>`.
- Resolve identities through `and-backend-contract`: `and-clarify` uses session-recovery identity; `and-wayfind` uses durable-workflow identity so map promotion and worktree changes do not move its buffer. A chart interview targets the top-level map identity; an investigation interview targets that investigation's stable identity, keeping parallel HITL buffers distinct.
- Derive the key through the backend contract's deterministic operation-key rules with namespace `<workflow-skill>:v1`. Locate the buffer at `<system-temp>/<workflow-skill>/<key>.md`.
- A materially confirmed decision changes package scope, canonical terminology, architecture, acceptance, or required documentation.
- The checkpoint is the SHA-256 hash of the buffer from `## Confirmed decisions and rationale` through `## Current unresolved question`, with LF line endings and exactly one final newline.

Use this shape:

```markdown
# Interview Recovery Buffer

Workflow skill: <and-clarify or and-wayfind>
Repository: <canonical identity>
Work record: <backend identity>
Checkpoint: <digest>

## Confirmed decisions and rationale
## Glossary updates
## ADR drafts
## Documentation updates
## Acceptance implications
## Current unresolved question
```

Use this shape for `clarify-decision`. For `chart-map`, insert `## Investigation candidates` and `## Remaining fog` immediately before `## Current unresolved question`; both stay inside the checkpoint range.

On resume, reconcile the matching buffer with newer backend state. Treat it as synchronized only when the corresponding backend receipt contains the same valid checkpoint; retain unsynchronized confirmed content and surface a conflict before continuing.

Create the buffer lazily after the first materially confirmed decision. Rewrite the complete cumulative structure after each later material decision and recompute its checkpoint. Keep partial reasoning, ordinary dialogue, credentials, and unconfirmed recommendations out of it.

If the buffer cannot be written or its checkpoint cannot be verified, stop before advancing workflow state and report the local recovery failure.

## Interview Output

Return the complete structured result. Every objective may return confirmed glossary, ADR, documentation, and acceptance implications. Its primary output is:

- `clarify-decision`: the confirmed decisions and rationale needed to resolve one bounded decision space, or one precise remaining blocker;
- `chart-map`: confirmed destination and scope, currently sharp investigation candidates with methods and dependencies, and any remaining fog;
- `resolve-investigation`: one durable answer with required evidence and asset disposition, or one precise remaining blocker.

A chart result is complete while multiple investigations and fog remain. It must not resolve those questions or pretend the work is package-ready.

Before returning a resolved result, obtain the final shared-understanding confirmation required by `grilling`. This confirms the decisions; it is not separate permission for the routine backend write.

Delete the matching buffer only after every required backend mutation is verified. Retain it when synchronization fails. Cleanup failure after authoritative synchronization is a local warning, not a workflow rollback.

## Completion Criteria

The contract is complete when:

- every fact and human-owned decision required by the current interview objective has an allowed source;
- every material result is recoverable with a valid checkpoint;
- artifact-ready outputs preserve exact confirmed meaning;
- `clarify-decision` resolves one bounded decision space with confirmed decisions and rationale, or has one precise blocker;
- `chart-map` has a confirmed destination, scope, first visible frontier, and explicit remaining fog without resolving an investigation;
- `resolve-investigation` has one durable answer or one precise blocker;
- final shared understanding is confirmed before returning a resolved output;
- the complete result is returned without this contract mutating workflow state.

## Boundaries

- This contract does not write stage state, State Reasons, receipts, maps, investigations, relationships, claims, lifecycle outcomes, branches, or pull requests.
- This contract does not edit repository docs, ADRs, glossary files, tests, or implementation files. A calling workflow may invoke an investigation method that creates an isolated asset; treat that asset and its disposition as linked evidence rather than an interview-contract mutation.
- Keep workflow-local scope in the future Package Contract and create durable repository artifacts only during claimed implementation.
