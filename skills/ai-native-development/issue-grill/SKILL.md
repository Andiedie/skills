---
name: issue-grill
description: A relentless interview to sharpen an issue before packaging, recording tracker-safe decisions instead of local docs.
disable-model-invocation: true
---

# Issue Grill

Run a `/grilling` session, using the `/domain-modeling` skill as a lens, with one workflow override:

Do not update repository docs during the session. When `/domain-modeling` would write `CONTEXT.md`, an ADR, glossary, or another local doc, record the proposed change on the issue as packaging input instead.

Use this when a triaged issue is `needs-info` because a correct package depends on human product, domain, architecture, naming, testing, access, or acceptance decisions.

## Session Rule

Ask one question at a time, recommend an answer for each question, and explore the codebase instead of asking when the answer can be verified locally.

## Decision Capture

- A resolved decision must come from repository evidence, a direct user answer, or the user's explicit acceptance of a recommended answer.
- Do not record guesses as resolved decisions. If the user has not confirmed a needed judgment, record it as a remaining blocker.
- The invocation authorizes recording confirmed decisions on the issue. Do not ask for a second confirmation before writing the tracker note.
- Ask before writing only when the target issue is ambiguous, the write would overwrite or contradict existing maintainer text, or tracker permissions/access are unclear.

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
- <blocker or none>

Resume point:
- `issue-pack`
```

If no blocker remains, move the issue from `needs-info` to `needs-pack` when tracker edits are allowed, then recommend `issue-pack`. If a blocker remains, keep `needs-info` and name the exact unanswered question.

Report with a short receipt: issue link, decisions recorded, label change when any, remaining blocker when any, and next skill. Do not paste the full `Issue Grill Notes` back into chat after writing them to the tracker.

Do not edit local files, create ADRs, update `CONTEXT.md`, pack, claim, or implement work.

Completion criterion: the issue contains enough recorded decisions for `issue-pack` to package the work, or one specific remaining blocker is named.
