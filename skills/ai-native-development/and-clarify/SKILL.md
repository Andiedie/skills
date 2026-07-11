---
name: and-clarify
description: Clarify decision-blocked work before packaging, recording backend-safe decisions instead of local docs.
disable-model-invocation: true
---

# AND Clarify

AND Clarify runs a relentless decision interview for `needs-info` work that cannot be packaged until human product, domain, architecture, naming, testing, access, or acceptance decisions are resolved.

It invokes `grilling` as the authority for interview behavior.

## Authoritative Interview Behavior

Invoke `grilling` and follow it as the single source of truth for the interview. Its rules govern:

- how questions and recommendations are presented;
- how facts are investigated;
- which choices belong to the human;
- when shared understanding has been reached.

## Backend Contract

Before reading or writing workflow state, read `.and/config.yml`, then use `and-backend-contract`.

Use the configured backend reference for reading the target work, writing clarification notes, writing State Reasons, and moving stage state. If setup is missing, unsupported, or the backend contract is unavailable, stop and route to `setup-and` or ask the user to install the missing skill.

Do not infer backend comments, receipts, frontmatter, labels, or State Reason placement inside this skill.

## Recovery Buffer

Use one local recovery buffer to protect confirmed interview results between backend writes. The buffer is disposable runtime state; the configured backend remains authoritative.

- Use the platform's standard per-user temporary directory as `<system-temp>`.
- For `github-native`, use lowercase `<host>/<owner>/<repo>` from the issue URL as the repository identity and the decimal issue number as the work-record identity.
- For `markdown-file-based`, use the real path of the repository root containing `.and/config.yml` as the repository identity and the repository-relative work-record path, with `.` and `..` resolved and `/` separators, as the work-record identity.
- Hash three newline-delimited UTF-8 lines containing `and-clarify:v1`, the repository identity, and the work-record identity. Use the SHA-256 result as `<key>` and locate the buffer at `<system-temp>/and-clarify/<key>.md`.
- A materially confirmed decision is an explicitly accepted decision that changes package scope, canonical terminology, architecture, acceptance, or required documentation.
- The checkpoint digest is the SHA-256 hash of the buffer sections from `## Confirmed decisions and rationale` through `## Current unresolved question`, using LF line endings and exactly one final newline.
- On resume, read the backend first, then the matching buffer and recompute its digest. A Clarification Notes receipt is synchronized only when its `Checkpoint` exactly matches that digest; carry forward confirmed unsynchronized content and surface any conflict with newer backend state before continuing.

Use this compact shape:

```markdown
# Clarification Recovery Buffer

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

## When To Use

Use `and-clarify` when:

- work is `needs-info`;
- the latest State Reason says `Resume with: and-clarify`;
- the State Reason cause is `decision-needed`;
- packaging depends on human product, domain, architecture, naming, testing, or acceptance judgment;
- an access or permission issue requires a policy or tradeoff decision.

Do not use `and-clarify` when:

- missing reporter facts can be answered directly;
- missing access is only waiting for an owner to provide a token or permission;
- external state needs to change;
- acceptance input is a direct owner answer and does not need an interview;
- work is already packable.

When this is not a grill case, report the existing State Reason question, route it to the accountable owner, and resume with the recorded skill.

## External Skills

`grilling` is the only required external runtime skill. Verify it is available before the interview.

If it is missing, stop with the exact missing skill and route to setup or installation. Do not simulate it.

## Evidence And Confirmation

Keep facts and human-owned decisions distinct:

- A fact may be established from repository code, tests, docs, configured-backend state, or another authoritative source. Investigate it instead of asking the user when practical.
- A human-owned decision is resolved only by an existing explicit maintainer decision in an authoritative source, a direct user answer, or the user's explicit acceptance of a recommendation.
- Repository evidence may inform a recommendation or establish a fact. Existing implementation patterns alone do not authorize a product, domain, architecture, naming, testing, or acceptance choice.
- Guesses, partial answers, ambiguous maintainer text, and unconfirmed recommendations remain blockers.

Before recording a resolved session, obtain the final shared-understanding confirmation required by `grilling`. This is approval of the decisions, not a separate approval to write them. Once shared understanding is confirmed, normal backend recording and the `needs-info` to `needs-pack` transition require no second confirmation.

Ask before writing only when the target work record is ambiguous, the write would overwrite or contradict existing maintainer text, backend access is unclear, or the write would introduce unconfirmed judgment. A paused session may record its one remaining blocker without claiming that shared understanding has been reached.

## Process

1. Resolve target and State Reason.
   - Read the target work and latest State Reason.
   - Verify `and-clarify` is the right resume path.
   - Read and reconcile a matching recovery buffer after the backend state.
   - Distinguish decision-needed blockers from simple missing facts, access waits, or external state waits.
   - Read [backend-safe-domain-modeling.md](backend-safe-domain-modeling.md) and keep its discipline active throughout the interview.
   - Completion criterion: the interview target, current blocker, owner, confirmed recovered inputs, and decision scope are explicit, or the work is routed to the accountable owner without grilling.

2. Run the interview.
   - Invoke `grilling` and follow its interview behavior without replacing or restating it, using the backend-safe domain-modeling guidance loaded in step 1.
   - Apply the fact and human-owned decision evidence rules above as the interview resolves package blockers.
   - After each materially confirmed decision, create the buffer lazily or rewrite it with the complete cumulative structure, including the decision's rationale and the current unresolved question, then recompute its `Checkpoint`.
   - Keep partial thoughts, unconfirmed recommendations, ordinary dialogue, and sensitive credentials out of the buffer.
   - If the recovery buffer cannot be written, stop and report the failure without advancing workflow state.
   - Completion criterion: every package-blocking fact is established, every package-blocking decision has an allowed human source, or one specific remaining blocker is identified, and every materially confirmed decision is recoverable locally with its rationale and current unresolved question.

3. Capture package inputs.
   - List resolved decisions and rationale.
   - Capture artifact-ready glossary updates, ADR drafts, and documentation changes when required.
   - List acceptance implications.
   - Identify any remaining blocker.
   - When no blocker remains, obtain `grilling`'s final shared-understanding confirmation.
   - Completion criterion: the package inputs are precise enough for `and-pack` and later implementation without replaying the interview, and a resolved session has passed the shared-understanding gate.

4. Synchronize the backend.
   - At completion, explicit pause, task switch, or handoff, perform only missing operations. When a buffer exists, append one Clarification Notes receipt only when no receipt has its checkpoint. When no buffer exists because no materially confirmed decision occurred, skip the empty receipt and local cleanup.
   - When a blocker remains, ensure the latest State Reason contains `Cause`, `Owner`, `Question`, `Resume with`, and `Exit criteria`. When no blocker remains, move the work from `needs-info` to `needs-pack` after any confirmed results are authoritative.
   - Verify every required backend mutation. If one fails, retain the buffer when present, keep `needs-info`, and report the failure; on resume, retry only the missing operation.
   - After all required backend mutations succeed, delete the matching recovery buffer when present. Report cleanup failure as a local warning without rolling back or blocking authoritative workflow state.
   - Completion criterion: the backend contains either a Clarification Notes receipt with the matching checkpoint or no unsynchronized materially confirmed decision, plus either enough input for `and-pack` or one current blocker with owner, resume skill, and exit criteria; local cleanup was attempted when a buffer existed.

5. Report a receipt.
   - Include the issue link or work ID, decisions recorded, stage change when any, remaining blocker when any, and next skill.
   - Do not paste the full Clarification Notes, full interview transcript, full State Reason markdown, recovery-buffer contents, local doc diffs, or package draft back into chat after writing them to the backend.
   - Completion criterion: the user knows what was recorded and whether the next step is `and-pack` or resolving a named blocker.

## Clarification Note

Use this backend note for the synchronization in step 4:

```markdown
## Clarification Notes

Checkpoint: <recovery-buffer digest>

Resolved decisions:
- <decision and rationale>

Glossary updates:
- <none, or target CONTEXT.md path plus preferred term, concise definition, and avoided alternatives when relevant>

ADR drafts:
- <none, or proposed title, artifact-ready decision and rationale, and useful options or consequences>

Documentation updates:
- <none, or target document and section plus precise content to add or replace>

Acceptance implications:
- <criteria, edge cases, or manual acceptance>

Remaining blockers:
- <none, or one specific blocker>

Next step:
- <`and-pack` when no blocker remains, or follow the latest State Reason>
```

When a blocker remains, write State Reason fields through the configured backend reference. Do not copy a backend-specific State Reason schema into this skill.

## Boundaries

- Keep repository docs, ADRs, glossary files, implementation files, branches, and PRs unchanged during clarification; capture their required content for the package instead.
- Record only confirmed decisions as resolved; guesses, partial answers, and unaccepted recommendations remain blockers.
- Use repository evidence to establish facts and inform recommendations, not to invent human-owned decisions.
- Stop after clarification state is synchronized; packing, claiming, implementation, closure, and merge belong to later stages.
- Route simple missing facts, access waits, external state waits, and direct acceptance input to the accountable owner without a structured interview.
