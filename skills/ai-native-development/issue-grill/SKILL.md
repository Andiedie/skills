---
name: issue-grill
description: A relentless interview to sharpen an issue before packaging, recording backend-safe decisions instead of local docs.
disable-model-invocation: true
---

# Issue Grill

Issue Grill runs a relentless decision interview for `needs-info` work that cannot be packaged until human product, domain, architecture, naming, testing, access, or acceptance decisions are resolved.

It uses `grilling` and `domain-modeling` behavior, but records backend-safe package input instead of editing local docs.

## External Skill Behavior

Run `grilling` with the `domain-modeling` lens:

- ask one question at a time;
- include a recommended answer for each question;
- explore code and docs before asking verifiable questions;
- challenge glossary conflicts and fuzzy terms;
- probe concrete scenarios;
- identify ADR candidates when a decision is hard to reverse, surprising without context, and a real tradeoff.

Workflow override: when `domain-modeling` would update `CONTEXT.md`, an ADR, glossary, or another local doc, record the proposed glossary, ADR, or documentation change in the workflow backend as package input.

## Backend Contract

Before reading or writing workflow state, read `.and/config.yml`, then use `ai-native-backend-contract`.

Use the configured backend reference for reading the target work, writing grill notes, writing State Reasons, and moving stage state. If setup is missing, unsupported, or the backend contract is unavailable, stop and route to `setup-ai-native-development` or ask the user to install the missing skill.

Do not infer backend comments, receipts, frontmatter, labels, or State Reason placement inside this skill.

## When To Use

Use `issue-grill` when:

- work is `needs-info`;
- the latest State Reason says `Resume with: issue-grill`;
- the State Reason cause is `decision-needed`;
- packaging depends on human product, domain, architecture, naming, testing, or acceptance judgment;
- an access or permission issue requires a policy or tradeoff decision.

Do not use `issue-grill` when:

- missing reporter facts can be answered directly;
- missing access is only waiting for an owner to provide a token or permission;
- external state needs to change;
- acceptance input is a direct owner answer and does not need an interview;
- work is already packable.

When this is not a grill case, report the existing State Reason question, route it to the accountable owner, and resume with the recorded skill.

## External Skills

`grilling` and `domain-modeling` are required runtime skills. Verify both are available before the interview.

If either is missing, stop with the exact missing skill and route to setup or installation. Do not simulate them.

## Session Rules

- Ask one question at a time.
- Provide a recommended answer for each question.
- Explain why the question blocks packaging.
- Explore the codebase instead of asking when the answer is verifiable.
- Keep working notes in chat during the interview.
- Do not write backend notes after each question, partial answer, or newly resolved decision.

## Decision Capture

- A resolved decision must come from repository evidence, a direct user answer, or the user's explicit acceptance of a recommended answer.
- Record guesses, partial answers, and unconfirmed recommendations as blockers, not decisions.
- The invocation plus interview confirmation authorizes normal backend recording. Do not ask for a second confirmation before writing confirmed decisions.
- Ask before writing only when the target work record is ambiguous, the write would overwrite or contradict existing maintainer text, backend access is unclear, or the write would introduce unconfirmed judgment.

## Process

1. Resolve target and State Reason.
   - Read the target work and latest State Reason.
   - Verify `issue-grill` is the right resume path.
   - Distinguish decision-needed blockers from simple missing facts, access waits, or external state waits.
   - Completion criterion: the interview target, current blocker, owner, and decision scope are explicit, or the work is routed to the accountable owner without grilling.

2. Run the interview.
   - Use `grilling` with the `domain-modeling` lens.
   - Ask one decision question, recommend an answer, wait for the user, then continue.
   - Explore code, tests, docs, and existing workflow state before asking facts the repository can answer.
   - Walk decision dependencies one by one; probe scenarios and challenge terms when they affect package correctness.
   - Completion criterion: every package-blocking decision is resolved, proven answerable from repository evidence, or captured as one specific remaining blocker.

3. Capture package inputs.
   - List resolved decisions and rationale.
   - List glossary proposals.
   - List ADR candidates.
   - List documentation updates to include in the package.
   - List acceptance implications.
   - Identify any remaining blocker.
   - Completion criterion: the package inputs are concise enough for `issue-pack` and do not require replaying the interview.

4. Record the backend note.
   - Write one backend note when the session resolves, pauses, the remaining blocker materially changes, or owner/resume skill/exit criteria materially changes.
   - If no blocker remains, move the work from `needs-info` to `needs-pack` when backend edits are allowed.
   - If a blocker remains, keep `needs-info` and write latest State Reason fields: `Cause`, `Owner`, `Question`, `Resume with`, and `Exit criteria`.
   - Do not edit local docs.
   - Do not ask for second confirmation for normal recording.
   - Completion criterion: the backend contains enough confirmed decisions for `issue-pack`, or one specific remaining blocker with owner, resume skill, and exit criteria.

5. Report a receipt.
   - Include the issue link or work ID, decisions recorded, stage change when any, remaining blocker when any, and next skill.
   - Do not paste the full Issue Grill Notes, full interview transcript, full State Reason markdown, local doc diffs, or package draft back into chat after writing them to the backend.
   - Completion criterion: the user knows what was recorded and whether the next step is `issue-pack` or resolving a named blocker.

## Issue Grill Note

Use this backend note when the session resolves, pauses, or materially changes the blocker:

```markdown
## Issue Grill Notes

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
- <`issue-pack` when no blocker remains, or follow the latest State Reason>
```

When a blocker remains, write State Reason fields through the configured backend reference. Do not copy a backend-specific State Reason schema into this skill.

## Boundaries

- Do not replace `grilling` with a checklist or multi-question form.
- Do not update local docs, ADRs, glossary, implementation files, branches, or PRs during the grill.
- Do not record guesses, partial answers, or unconfirmed recommendations as resolved decisions.
- Do not write backend notes after every question; write when the session resolves, pauses, or the blocker materially changes.
- Do not pack, claim, implement, close, or merge work.
- Do not use `issue-grill` for simple missing facts, access waits, external state waits, or direct acceptance input that does not need an interview.
