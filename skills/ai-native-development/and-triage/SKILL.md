---
name: and-triage
description: Decide whether recorded work should close, wait for information, or be packed.
disable-model-invocation: true
---

# AND Triage

Close, wait, or send one authoritative configured-backend work record to Pack. Ground the route, apply it when authorized, and leave executable package creation to `and-pack`.

## Backend Contract

Before reading or writing workflow state, read `.and/config.yml`, then use `and-backend-contract` for the configured representation. If setup is missing, unsupported, or unavailable, route to `setup-and` or report the missing skill.

The backend contract owns stage, State Reason, lifecycle, relationship, and receipt representation.

A valid but inaccessible backend remains authoritative: report the exact read or write blocker, and identify any route that could not be written as `unapplied`.

## Act Or Ask

Apply a clear `needs-info` or `needs-pack` route directly. Ask one focused question before mutation only when the target is ambiguous, the route itself would encode unrecorded human judgment, closure lacks authority, the duplicate or rejection target is unclear, or the write would overwrite a maintainer conclusion or create an unauthorized side effect.

When human judgment is the missing input rather than the route decision, write `needs-info` and ask the exact State Reason question; the route itself needs no approval.

Treat ownership, linked PRs, containment, dependencies, and prior State Reasons as route evidence, not automatic confirmation gates.

An explicit authorized route instruction supplies the human judgment; ground only enough evidence to apply it safely, then act.

## Process

1. Resolve one target.
   - Use the work record named by ID, issue number, path, or URL.
   - For a named external PR, resolve its authoritative configured-backend work record. When none exists, route the PR to `and-intake`.
   - With no named target, query untriaged work, `needs-triage`, and `needs-info` with new activity; present a compact attention list and let the user select one.
   - Mutate one work record at a time unless the user explicitly requests a batch.
   - Completion criterion: exactly one target is selected, or the run ends with no in-scope work or a short attention list awaiting selection.

2. Ground the route.
   - Read the record, current stage and lifecycle, latest State Reason, material comments or receipts, ownership, relationships and blockers, linked implementation artifacts, attachments, and prior triage notes.
   - Follow evidence into code, tests, docs, domain notes, or architecture decisions only where the route turns on it.
   - Check duplicates by concept, existing implementation, and relevant recorded rejections or out-of-scope decisions.
   - For a bug, make a proportionate reproduction attempt from the reporter's steps.
   - For a linked external PR, inspect its diff and relevant checks far enough to test the request or implementation claim. Keep author claims distinct from Agent-observed evidence.
   - Completion criterion: established facts, verified behavior, material unknowns and blockers, duplicate or prior-decision results, and any reproduction or PR result that changes the route are accounted for.

3. Choose one route.

   - A record with a published Package Contract, claim, or implementation evidence is not an ordinary closure candidate. Preserve its state: route an unclaimed ready unit to `and-pick` or the selected unit to `and-claim`, claimed or incomplete implementation to `and-implement`, reviewed or merged delivery to `and-finish`, and contradictory evidence to `and-sweep`.

   | Route | Use when |
   | --- | --- |
   | `closed` | A pre-delivery terminal reason such as duplicate, already satisfied, rejected, not actionable, or no longer relevant is verified and closure authority exists or is confirmed. |
   | `needs-info` | One specific fact, decision, permission, external state, or acceptance input blocks safe packaging. |
   | `needs-pack` | The work is worth doing and has enough confirmed input for `and-pack`. |

   - Route a bounded product, domain, architecture, naming, or testing decision space to `and-clarify` when its questions can be enumerated now.
   - Route to `and-wayfind` when the destination is visible but later questions depend on unfinished investigation. Size alone does not make work map-shaped.
   - For a Wayfinding route, make the State Reason describe destination-level uncertainty and the condition for a clear map; the map owns individual investigation questions.
   - Name the smallest accountable owner for missing facts, access, external state, or acceptance. Treat package-shape recommendations as hints for `and-pack`.
   - Completion criterion: exactly one route is selected, or one confirmation question names the evidence, authority, or risk preventing a safe mutation.

4. Apply the route.
   - Write the route and its evidence to the selected work record through the configured backend, clearing contradictory public stage state.
   - For `needs-info`, write triage notes and a current State Reason.
   - For `needs-pack`, write triage notes and package inputs, not a Package Contract.
   - For `closed`, write the terminal reason, evidence, and authority, then record the lifecycle outcome.
   - Keep linked external PRs unchanged; they remain source evidence or implementation artifacts.
   - Completion criterion: the backend expresses exactly one route, every waiting state has a current State Reason, and closure has recorded authority and evidence.

5. Report the result.
   - Return a short receipt with the work link or ID, route, state or lifecycle change, decisive evidence, the exact unresolved input when any, and the next skill or owner action.
   - Keep full notes, State Reasons, issue bodies, and logs in the configured backend. Omit receipt fields that do not apply.
   - Completion criterion: the next actor can continue without rereading the triage session.

## Triage Notes

Start one durable note with:

```markdown
## Triage Notes

Category: <bug, enhancement, or repository category>
Outcome: <needs-info, needs-pack, or closed>

Established facts:
- <fact>

Verified behavior:
- <reproduction, PR check, current behavior check, or not applicable>
```

For `needs-pack`, append only:

```markdown
Package inputs:
- Current behavior:
- Desired behavior:
- Constraints and scope clues:
- Verification clues and evidence links:
- Non-blocking unknowns:
```

For `closed`, append only:

```markdown
Closure:
- Reason:
- Evidence:
- Authority:
```

For `needs-info`, write the current State Reason through the backend contract rather than duplicating its schema in the triage note.

## Stage Boundary

Triage ends with `closed`, `needs-info`, or `needs-pack` plus durable route evidence, or hands an active delivery to its owning downstream stage without changing it. `and-clarify` owns bounded decision interviews, `and-wayfind` owns map-shaped investigation, `and-pack` owns Package Contracts, child records, and `ready-for-agent`, and `and-finish` owns delivered completion.
