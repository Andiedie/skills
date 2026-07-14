---
name: and-interview-contract
description: Apply AND interview evidence, recovery, domain-modeling, and artifact-output rules when another AND skill runs a human decision interview.
---

# AND Interview Contract

Shared reference for AND decision interviews. It makes confirmed results recoverable and ready for the calling workflow skill's next mutation without owning interview cadence or workflow state.

The calling workflow skill owns its target, synchronization boundaries, GitHub mutations, receipts, stage, and lifecycle. `grilling` owns question cadence. This contract owns evidence quality, local recovery, workflow-safe domain modeling, and compact structured output.

## Interview Continuation

The one-question waits required by `grilling` stay inside the active interview. Keep confirmed results in local recovery, preserve current GitHub workflow state, and continue when the next answer arrives.

## Inputs

The workflow skill supplies:

- its canonical skill name;
- interview objective: `clarify-decision`, `chart-map`, or `resolve-investigation`;
- canonical repository identity;
- GitHub work-record identity;
- one focused decision boundary, destination question, or investigation question;
- current authoritative GitHub evidence.

Read authoritative GitHub state before loading local recovery.

## Evidence

Keep facts and human-owned decisions distinct while `grilling` conducts the exchange:

- Establish facts from code, tests, docs, GitHub workflow state, or another authoritative source whenever practical.
- Resolve a human-owned decision only from an authoritative maintainer decision, a direct user answer, or explicit acceptance of a recommendation.
- Use repository evidence to inform recommendations, not to authorize product, domain, architecture, naming, testing, or acceptance choices.
- Treat guesses, partial answers, ambiguous text, and unaccepted recommendations as unresolved.

## Workflow-Safe Domain Modeling

Sharpen the domain model inside the supplied interview boundary while leaving repository files unchanged. Return only confirmed package input that a future claimed implementation must apply.

### Active Discipline

- Read the relevant `CONTEXT.md`, `CONTEXT-MAP.md`, ADRs, code, and tests before asking questions those sources can answer.
- Challenge conflicts with established language as soon as they appear.
- Sharpen vague or overloaded words into one canonical term.
- Test domain boundaries with concrete scenarios and edge cases.
- Surface contradictions between the proposed model, existing docs, and current behavior.
- Continue until the terminology and architectural decisions required by the interview objective are precise enough to package, or one human-owned decision remains as the blocker.

### Choose The Authoritative Home

Start with purposeful omission: a confirmed decision needs no repository-document output unless future readers must consult a durable authority beyond this delivery unit.

- Use the Package Contract for delivery-local scope, behavior, acceptance, and reversible implementation choices.
- Return a required `CONTEXT.md` update when a project-specific, implementation-independent term must govern future work. General programming concepts stay in their existing technical authorities.
- Return a required ADR draft only when the decision is hard to reverse, surprising without context, and the result of a real tradeoff. All three conditions must hold.
- Return another required repository-document update when a stable interface, operational rule, or project fact has an established authoritative home outside the Package Contract.

When no existing authority fits a required durable update, propose the smallest new artifact. File creation remains lazy and belongs to implementation. When no category passes these tests, return no repository update.

### Artifact-Ready Outputs

Emit only categories that pass the authority test. For a canonical term, record:

```markdown
Target: <existing or proposed CONTEXT.md path>

**<Preferred term>**:
<One or two sentence implementation-independent definition.>
_Avoid_: <ambiguous or rejected alternatives, when relevant>
```

For an ADR, record:

```markdown
Proposed title: <short decision title>
Target: <existing or proposed ADR directory>
Draft: <one to three sentences stating the context, decision, and why>
Relevant options or consequences: <only when they add durable value>
```

For another documentation update, record the target document and section, the precise content to add or replace, and why that document is authoritative.

### Boundaries

- Preserve exact confirmed meaning as package input while repository files remain unchanged.
- Keep `CONTEXT.md` entries implementation-independent, project-specific, concise, and opinionated about preferred language.
- Keep ADRs sparse; only hard-to-reverse, surprising tradeoffs qualify.
- Keep delivery-local decisions in the Package Contract and emit durable-document updates only when their authority test passes.
- Return unconfirmed language or decisions as the current blocker, not as an artifact-ready draft.

## Recovery

Use one disposable local buffer for confirmed interview results between GitHub writes. GitHub remains authoritative.

- Use the platform's standard per-user temporary directory and keep buffers under `<system-temp>/<workflow-skill>/`.
- Resolve identities through `and-workflow-contract`: `and-clarify` uses session-recovery identity; `and-wayfind` uses durable-workflow identity so map promotion and worktree changes do not move its buffer. A chart interview targets the top-level map identity; an investigation interview targets that investigation's stable identity, keeping parallel HITL buffers distinct.
- Condense the current work-record title into the shortest source-language phrase that still names its subject. Make that topic filesystem-safe by replacing runs of whitespace, path separators, control characters, and platform-reserved characters or forms with one hyphen, trimming dots and separators, and using `work` when nothing remains.
- Name a new buffer `<work-record-number>-<short-topic-title>.md`, such as `74-恢复缓冲区文件名.md`. The basename is a compact label, never recovery identity. Re-read the directory immediately before creating the file and create it without replacement. When another valid identity occupies that basename or wins a creation race, re-scan and use the lowest available numeric suffix such as `-2` rather than a digest; never overwrite an existing buffer.
- Derive the `<workflow-skill>:v1` operation key only when diagnosing recovery or locating a legacy `<key>.md` buffer. Do not create new digest-named buffers or expose the key in routine tool output, logs, receipts, or user-facing responses; refer to the compact basename unless exact diagnostic evidence is required.
- A materially confirmed result changes package scope, canonical terminology, architecture, acceptance, required documentation, chart destination or scope, or the durable answer to an investigation.
- The checkpoint is the SHA-256 hash of the buffer from `## Confirmed result` through `## Current unresolved question`, with LF line endings and exactly one final newline.

Use this shape:

```markdown
# Interview Recovery Buffer

Workflow skill: <and-clarify or and-wayfind>
Repository: <canonical identity>
Work record: <GitHub issue identity>
Checkpoint: <digest>

## Confirmed result
## Current unresolved question
```

For `chart-map`, insert `## Investigation candidates` and `## Remaining fog` immediately before `## Current unresolved question`. When present, add `## Required repository updates` and then `## Acceptance implications` in that order after `## Confirmed result`. Every added section stays inside the checkpoint range.

After reading authoritative GitHub state, scan the workflow-skill directory and classify buffers by their header identity before validating matching content. Select only the exact workflow, repository, and work-record identity regardless of its topic label; a title change does not relocate a live buffer. No match permits lazy creation, one match resumes it, and multiple matches stop as a recovery conflict without merging or deleting content. A buffer attributable to the current identity whose structure or checkpoint is malformed stops recovery. Preserve an unidentifiable or different-identity malformed file and report it as a diagnostic warning without selecting, overwriting, deleting, or allowing it to block unrelated work. A valid different identity at the preferred basename uses the numeric collision rule above.

On continuation or resume, reconcile the matching buffer with newer GitHub state. A corresponding GitHub receipt with the same valid checkpoint marks it synchronized. Otherwise, the buffer is pending interview progress: carry it forward while current authoritative GitHub evidence remains compatible. Materially incompatible newer authoritative GitHub evidence creates a recovery conflict; retain the buffer and stop before workflow mutation.

When the sole match is a legacy digest-named buffer, keep it in place while creating the current semantic path without replacement and copying the complete buffer. Verify that the new file's bytes and checkpoint match the legacy buffer before deleting the legacy path. If creation, copying, verification, or legacy deletion fails, roll back only the new migration copy, retain the legacy buffer, and stop before workflow advancement. If rollback cannot be verified, retain both paths and report a recovery conflict. Never rewrite either path until migration completes, and never dual-write later confirmations.

Create the buffer lazily after the first materially confirmed result. Rewrite the complete cumulative structure after each later material confirmation and recompute its checkpoint. Keep partial reasoning, ordinary dialogue, credentials, and unconfirmed recommendations out of it.

If the buffer cannot be written or its checkpoint cannot be verified, stop before advancing workflow state and report the local recovery failure.

## Interview Output

Return one complete, compact result. Its primary output is:

- `clarify-decision`: the confirmed decisions and rationale needed to resolve one bounded decision space, one precise remaining blocker, or destination-level uncertainty routed to `and-wayfind` when later questions depend on investigation;
- `chart-map`: confirmed destination and scope, currently sharp investigation candidates with methods and dependencies, and any remaining fog;
- `resolve-investigation`: one durable answer with required evidence and asset disposition, or one precise remaining blocker.

Include repository updates or acceptance implications only when they are confirmed package inputs under the workflow-safe domain-modeling rules. Leave absent categories out of the result.

A chart result is complete while multiple investigations and fog remain. It leaves every investigation open and package readiness unset.

Before returning a resolved result, obtain the final shared-understanding confirmation required by `grilling`. It confirms the result rather than granting separate permission for the routine GitHub write.

Delete the matching buffer only after every required GitHub mutation is verified. Retain it when synchronization fails. Cleanup failure after authoritative synchronization is a local warning, not a workflow rollback.

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

- Workflow state and durable receipts remain with the calling skill and GitHub.
- Repository docs, ADRs, glossary files, tests, and implementation files remain unchanged; required edits are package inputs for claimed implementation.
- An isolated investigation asset and its disposition remain linked evidence owned by the calling workflow, not a mutation by this contract.
