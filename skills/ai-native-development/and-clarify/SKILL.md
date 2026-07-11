---
name: and-clarify
description: Clarify decision-blocked work before packaging, recording backend-safe decisions instead of local docs.
disable-model-invocation: true
---

# AND Clarify

AND Clarify runs a relentless decision interview for `needs-info` work that cannot be packaged until human product, domain, architecture, naming, testing, access, or acceptance decisions are resolved.

It invokes `grilling` as the authority for interview behavior and uses [backend-safe domain modeling](backend-safe-domain-modeling.md) for domain, naming, glossary, and ADR judgment.

## Authoritative Interview Behavior

Invoke `grilling` and follow it as the single source of truth for the interview. Its rules govern:

- how questions and recommendations are presented;
- how facts are investigated;
- which choices belong to the human;
- when shared understanding has been reached.

When domain, naming, glossary, or ADR judgment affects package correctness, read [backend-safe-domain-modeling.md](backend-safe-domain-modeling.md). Its outputs belong in Clarification Notes as package input, not in local docs.

## Backend Contract

Before reading or writing workflow state, read `.and/config.yml`, then use `and-backend-contract`.

Use the configured backend reference for reading the target work, writing clarification notes, writing State Reasons, and moving stage state. If setup is missing, unsupported, or the backend contract is unavailable, stop and route to `setup-and` or ask the user to install the missing skill.

Do not infer backend comments, receipts, frontmatter, labels, or State Reason placement inside this skill.

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
   - Distinguish decision-needed blockers from simple missing facts, access waits, or external state waits.
   - Completion criterion: the interview target, current blocker, owner, and decision scope are explicit, or the work is routed to the accountable owner without grilling.

2. Run the interview.
   - Invoke `grilling` and follow its interview behavior without replacing or restating it.
   - Read and apply [backend-safe-domain-modeling.md](backend-safe-domain-modeling.md) when domain, naming, glossary, or ADR judgment affects package correctness.
   - Apply the fact and human-owned decision evidence rules above as the interview resolves package blockers.
   - Completion criterion: every package-blocking fact is established, every package-blocking decision has an allowed human source, or one specific remaining blocker is identified.

3. Capture package inputs.
   - List resolved decisions and rationale.
   - List glossary proposals.
   - List ADR candidates.
   - List documentation updates to include in the package.
   - List acceptance implications.
   - Identify any remaining blocker.
   - When no blocker remains, obtain `grilling`'s final shared-understanding confirmation.
   - Completion criterion: the package inputs are concise enough for `and-pack` and do not require replaying the interview, and a resolved session has passed the shared-understanding gate.

4. Record the backend note.
   - Write one backend note when the session resolves, pauses, the remaining blocker materially changes, or owner/resume skill/exit criteria materially changes.
   - If no blocker remains, move the work from `needs-info` to `needs-pack` when backend edits are allowed.
   - If a blocker remains, keep `needs-info` and write latest State Reason fields: `Cause`, `Owner`, `Question`, `Resume with`, and `Exit criteria`.
   - Do not edit local docs.
   - Do not ask for second confirmation for normal recording.
   - Completion criterion: the backend contains enough confirmed decisions for `and-pack`, or one specific remaining blocker with owner, resume skill, and exit criteria.

5. Report a receipt.
   - Include the issue link or work ID, decisions recorded, stage change when any, remaining blocker when any, and next skill.
   - Do not paste the full Clarification Notes, full interview transcript, full State Reason markdown, local doc diffs, or package draft back into chat after writing them to the backend.
   - Completion criterion: the user knows what was recorded and whether the next step is `and-pack` or resolving a named blocker.

## Clarification Note

Use this backend note when the session resolves, pauses, or materially changes the blocker:

```markdown
## Clarification Notes

Resolved decisions:
- <decision and rationale>

Glossary proposals:
- <term -> meaning, or none>

ADR candidates:
- <decision, alternatives, why it may deserve an ADR, or none>

Documentation updates to include in the package:
- <CONTEXT.md, ADR, README, runbook, or none>

Acceptance implications:
- <criteria, edge cases, or manual acceptance>

Remaining blockers:
- <none, or one specific blocker>

Next step:
- <`and-pack` when no blocker remains, or follow the latest State Reason>
```

When a blocker remains, write State Reason fields through the configured backend reference. Do not copy a backend-specific State Reason schema into this skill.

## Boundaries

- Do not replace `grilling` with a checklist or multi-question form.
- Do not update local docs, ADRs, glossary, implementation files, branches, or PRs during the grill.
- Do not record guesses, partial answers, or unconfirmed recommendations as resolved decisions.
- Do not infer a human-owned decision from repository evidence or implementation precedent.
- Do not write backend notes after every question; write when the session resolves, pauses, or the blocker materially changes.
- Do not pack, claim, implement, close, or merge work.
- Do not use `and-clarify` for simple missing facts, access waits, external state waits, or direct acceptance input that does not need an interview.
