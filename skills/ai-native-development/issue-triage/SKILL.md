---
name: issue-triage
description: Decide whether recorded work should close, wait for information, or be packed.
disable-model-invocation: true
---

# Issue Triage

Triage decides the next route for recorded work: close it, wait for information, or move it to `needs-pack`.

Triage produces an evidence-backed routing decision. It does not make work executable.

## Backend Contract

Before reading or writing workflow state, read `.and/config.yml`, then use `ai-native-backend-contract`.

Use the configured backend reference for all reads and writes. If setup is missing, unsupported, or the backend contract is unavailable, stop and route to `setup-ai-native-development` or ask the user to install the missing skill.

Do not infer backend labels, frontmatter, State Reason placement, lifecycle representation, or receipt placement inside this skill.

## Outcomes

Triage may produce only one outcome:

- `closed`: no further workflow action is needed because the work is complete, duplicate, rejected, not actionable, already implemented, or no longer relevant.
- `needs-info`: safe packaging is blocked by one specific missing fact, human decision, permission, external state, or acceptance input.
- `needs-pack`: the work is worth doing and has enough confirmed input for `issue-pack`.

Open work must not carry contradictory public stage state.

Every `needs-info` route must include a current State Reason with `Cause`, `Owner`, `Question`, `Resume with`, and `Exit criteria`. Representation belongs to the configured backend reference.

## Confirmation Gates

Apply ordinary `needs-info` and `needs-pack` routes without confirmation when the target is clear and evidence supports the route. The user invoked triage, so do not ask them to approve routine Decide-stage updates.

Ask before editing only when:

- the target is ambiguous;
- the route is uncertain;
- the route depends on unrecorded human judgment;
- closure is needed without explicit closure authority;
- the duplicate or rejection target is unclear;
- the edit would overwrite maintainer conclusions;
- existing ownership, linked PRs, containment, dependencies, or State Reasons make the side effect unsafe.

## Process

1. Resolve target or attention list.
   - Use the specific target when the user names a work ID, issue number, path, URL, or PR.
   - When no target is named, list untriaged work, `needs-triage`, and `needs-info` with new activity.
   - Include external PRs only when repository setup treats PRs as request surfaces.
   - Do not batch-update by default.
   - Completion criterion: one target is selected, or the report says no triage work is in scope.

2. Collect route evidence.
   - Read title, body, current stage, lifecycle, latest State Reason, comments or receipts, ownership, linked implementation artifacts, attachments, containment, dependency relationships, and prior triage notes.
   - Inspect code, tests, docs, domain notes, and architecture decisions only when the route depends on them.
   - Check duplicates by concept, not wording.
   - Check whether the requested behavior is already implemented.
   - Check prior rejection or out-of-scope records when the repository has them.
   - For bugs, make a proportionate reproduction attempt from reporter steps.
   - For PR request surfaces, inspect the diff and checks enough to route.
   - Completion criterion: the route decision can name established facts, verified behavior, unknowns, blockers, duplicate or prior-rejection result, and any reproduction or PR verification result that materially affected the route.

3. Decide the route.
   - Choose `closed` when the work has a verified terminal reason and closure authority exists or confirmation is obtained.
   - Choose `needs-info` when one specific missing input blocks safe packaging.
   - Choose `needs-pack` when the work is worth doing and packageable.
   - Use `issue-grill` as the resume path for structured product, domain, architecture, naming, or testing decisions.
   - Use the smallest accountable owner for missing facts, access, external state, or acceptance input.
   - Treat package-shape recommendations as hints only; final package shape belongs to `issue-pack`.
   - Completion criterion: exactly one route is selected, or one confirmation question is asked with the evidence and risk named.

4. Apply the route when safe or confirmed.
   - Update one work record at a time unless the user explicitly requests batch work.
   - Remove contradictory public stage state through the configured backend.
   - For `needs-info`, write triage notes and a current State Reason.
   - For `needs-pack`, write triage notes and package inputs.
   - For `closed`, write close reason and completion evidence, then close only with authority.
   - Completion criterion: the backend expresses exactly one route without contradictory public stage state, and any waiting state has a current State Reason.

5. Report a receipt.
   - Include the work link or ID, outcome, state or lifecycle change, material facts verified, exact unresolved question when any, and next skill.
   - Do not repeat full issue bodies, full triage notes, full State Reason markdown, long reproduction logs, or empty sections.
   - Completion criterion: the next actor can continue with `issue-grill`, `issue-pack`, or closure follow-up without rereading the whole triage session.

## Backend Notes

### Needs Info Notes

```markdown
## Triage Notes

Category: <bug, enhancement, or repository category>

Established facts:
- <fact>

Verified behavior:
- <reproduction, PR check, current behavior check, or not applicable>

Needed input:
- Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
- Owner: <reporter, maintainer, human, agent, or external-system>
- Question: <one specific question, decision, permission, external event, or acceptance gate>
- Resume with: <issue-triage, issue-grill, or issue-pack>
- Exit criteria: <what must be true before this work can leave needs-info>
```

### Needs Pack Notes

```markdown
## Triage Notes

Category: <bug, enhancement, or repository category>

Established facts:
- <fact>

Package inputs:
- Current behavior:
- Desired behavior:
- Known constraints:
- Scope clues:
- Verification clues:
- Evidence links:
- Non-blocking unknowns:

Package shape hint: <single issue package, PRD package, or unknown>
```

### Close Notes

```markdown
## Triage Notes

Closure reason: <duplicate, already implemented, rejected, not actionable, no longer relevant, or complete>

Evidence:
- <fact, duplicate link, implementation evidence, maintainer decision, or prior rejection record>

Authority:
- <explicit user request, maintainer comment, prior decision, or confirmation>
```

## Boundaries

- Do not write a Package Contract, create child records, or mark work `ready-for-agent`; route packageable work to `issue-pack`.
- Do not claim, implement, review, merge, or release ownership.
- Do not close work without explicit authority or confirmation.
- Do not ask broad questions when a specific State Reason can be written.
- Do not run a structured decision interview; route those decisions to `issue-grill`.
