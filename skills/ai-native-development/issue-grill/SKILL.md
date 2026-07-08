---
name: issue-grill
description: A relentless interview to sharpen an issue before packaging, recording backend-safe decisions instead of local docs.
disable-model-invocation: true
---

# Issue Grill

Run a `/grilling` session, using the `/domain-modeling` skill as a lens, with one workflow override:

Do not update repository docs during the session. When `/domain-modeling` would write `CONTEXT.md`, an ADR, glossary, or another local doc, record the proposed change in the configured workflow state backend as packaging input instead.

Use this when a triaged issue is `needs-info` because a correct package depends on human product, domain, architecture, naming, testing, access, or acceptance decisions.

Begin from the work record's latest State Reason when one exists. `issue-grill` is the right route when `Resume with` is `issue-grill`, or when the State Reason cause is `decision-needed` and a structured interview can resolve it. If the latest State Reason is only missing reporter facts, access, external state, or acceptance input that does not need an interview, report the question and route to its owner instead of grilling.

## External Skill Preflight

`grilling` and `domain-modeling` are required runtime skills. Before starting the interview, verify that both are available in the current session or installed skill list.

If either required skill is missing, stop and route to `setup-ai-native-development` with the exact missing skill name. Do not simulate `/grilling` or silently continue without the domain-modeling lens.

## Backend Rule

Before writing decisions, read `.and/config.yml`, then use `ai-native-backend-contract` for the backend contract and configured backend reference. Use the configured backend reference for decision notes, State Reasons, receipts, and stage-state changes.

If `ai-native-backend-contract` is unavailable, stop and ask the user to install it; do not infer backend rules.

If setup is missing or the backend value is unsupported, route to `setup-ai-native-development`. Do not create local ADRs, glossary entries, or context-doc edits during grilling.

## Session Rule

Ask one question at a time, recommend an answer for each question, and explore the codebase instead of asking when the answer can be verified locally.

Keep interview working notes in chat during the session. Do not update the backend after each question, partial answer, or newly resolved decision. Write one backend note when the session resolves, pauses, or discovers a materially different State Reason, owner, resume skill, or exit criteria.

## Decision Capture

- A resolved decision must come from repository evidence, a direct user answer, or the user's explicit acceptance of a recommended answer.
- Do not record guesses as resolved decisions. If the user has not confirmed a needed judgment, record it as a remaining blocker.
- The invocation authorizes recording confirmed decisions in the configured backend. Do not ask for a second confirmation before writing the backend note.
- Ask before writing only when the target work record is ambiguous, the write would overwrite or contradict existing maintainer text, or backend permissions/access are unclear.

When a blocker remains at the end or pause point, append a new State Reason with the shared fields: `Cause`, `Owner`, `Question`, `Resume with`, and `Exit criteria`. Do not edit earlier State Reason comments or receipts. A backend may also update latest-reason metadata for queries. The latest State Reason supersedes earlier State Reasons.

## Record

When the decision is clear enough to package, record this backend note:

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

When a blocker remains, append the State Reason:

```markdown
## State Reason

State: needs-info
Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
Owner: <reporter, maintainer, human, agent, or external-system>
Question: <one specific question, decision, permission, external event, or acceptance gate>
Resume with: <issue-triage, issue-grill, or issue-pack>
Exit criteria: <what must be true before this delivery unit can leave needs-info>
```

If no blocker remains, move the work from `needs-info` to `needs-pack` when backend edits are allowed, then recommend `issue-pack`. If a blocker remains, keep `needs-info`, set `Next step` to follow the latest State Reason, and write the State Reason with the exact unanswered question. When a State Reason exists, it is the only recovery pointer.

Report with a short receipt: issue link or work ID, decisions recorded, stage change when any, remaining blocker when any, and next skill. Do not paste the full `Issue Grill Notes` back into chat after writing them to the backend.

Do not edit repository docs or implementation files outside the configured backend, create ADRs, update `CONTEXT.md`, pack, claim, or implement work.

Completion criterion: the configured backend contains enough recorded decisions for `issue-pack` to package the work, or one specific remaining blocker is named.
