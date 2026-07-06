---
name: issue-grill
description: A relentless interview to sharpen an issue before packaging, recording tracker-safe decisions instead of local docs.
disable-model-invocation: true
---

# Issue Grill

Run a `/grilling` session, using the `/domain-modeling` skill as a lens, with one workflow override:

Do not update repository docs during the session. When `/domain-modeling` would write `CONTEXT.md`, an ADR, glossary, or another local doc, record the proposed change on the issue as packaging input instead.

Use this when a triaged issue is `needs-info` because a correct package depends on human product, domain, architecture, naming, testing, access, or acceptance decisions.

Begin from the issue's latest Blocker block when one exists. `issue-grill` is the right route when `Resume with` is `issue-grill`, or when the blocker cause is `decision-needed` and a structured interview can resolve it. If the latest blocker is only missing reporter facts, access, external state, or acceptance input that does not need an interview, report the blocker and route to its owner instead of grilling.

## Session Rule

Ask one question at a time, recommend an answer for each question, and explore the codebase instead of asking when the answer can be verified locally.

Keep interview working notes in chat during the session. Do not update the tracker after each question, partial answer, or newly resolved decision. Write one tracker note when the session resolves, pauses, or discovers a materially different blocker, owner, resume skill, or exit criteria.

## Decision Capture

- A resolved decision must come from repository evidence, a direct user answer, or the user's explicit acceptance of a recommended answer.
- Do not record guesses as resolved decisions. If the user has not confirmed a needed judgment, record it as a remaining blocker.
- The invocation authorizes recording confirmed decisions on the issue. Do not ask for a second confirmation before writing the tracker note.
- Ask before writing only when the target issue is ambiguous, the write would overwrite or contradict existing maintainer text, or tracker permissions/access are unclear.

When a blocker remains at the end or pause point, append a new Blocker with the shared fields: `Cause`, `Owner`, `Question`, `Resume with`, and `Exit criteria`. Do not edit earlier Blocker comments. The latest Blocker supersedes earlier Blockers.

## Record

When the decision is clear enough to package, comment on the issue:

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
- <`issue-pack` when no blocker remains, or follow the latest Blocker>
```

When a blocker remains, append the Blocker block:

```markdown
## Blocker

Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
Owner: <reporter, maintainer, human, agent, or external-system>
Question: <one specific question, decision, permission, external event, or acceptance gate>
Resume with: <issue-triage, issue-grill, or issue-pack>
Exit criteria: <what must be true before this issue can leave needs-info>
```

If no blocker remains, move the issue from `needs-info` to `needs-pack` when tracker edits are allowed, then recommend `issue-pack`. If a blocker remains, keep `needs-info`, set `Next step` to follow the latest Blocker, and write the Blocker block with the exact unanswered question. When a Blocker exists, it is the only recovery pointer.

Report with a short receipt: issue link, decisions recorded, label change when any, remaining blocker when any, and next skill. Do not paste the full `Issue Grill Notes` back into chat after writing them to the tracker.

Do not edit local files, create ADRs, update `CONTEXT.md`, pack, claim, or implement work.

Completion criterion: the issue contains enough recorded decisions for `issue-pack` to package the work, or one specific remaining blocker is named.
