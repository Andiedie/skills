---
name: issue-triage
description: Decide whether recorded work should close, wait for information, or be packed.
disable-model-invocation: true
---

# Issue Triage

Triage runs the Decide stage for recorded work. It determines whether an issue should close, wait for information, or move to `needs-pack`.

Triage produces an evidence-backed routing decision. It does not make work executable.

## Backend Rule

Before reading or writing workflow state, read `.and/config.yml`, then use `ai-native-backend-contract` for the backend contract and configured backend reference. Use the configured backend reference for stage state, State Reason, lifecycle outcome, relationship, receipt, and ownership evidence representation.

If `ai-native-backend-contract` is unavailable, stop and ask the user to install it; do not infer backend rules.

If setup is missing or the backend value is unsupported, route to `setup-ai-native-development`.

## Outcomes

Triage may produce only one outcome:

- `closed`: the lifecycle outcome is complete, duplicate, rejected, not actionable, or no longer relevant
- `needs-info`: the stage state is waiting on human, reporter, maintainer, permission, external access, acceptance input, or a decision interview
- `needs-pack`: the stage state is worth doing and should be packed into an executable delivery unit

Every open triaged delivery unit should have at most one public stage state.

Every `needs-info` route must include a current State Reason. The latest State Reason is the source of truth for why the work is waiting, who owns the answer, what question must be answered, which skill should resume after the answer arrives, and what condition clears the wait.

State Reason history is append-only. Do not edit or delete earlier State Reason comments or receipts during normal workflow; append a new State Reason when the reason materially changes. A backend may also update latest-reason metadata for queries. The latest State Reason supersedes earlier State Reasons.

## Invocation

Use this skill in two ways:

- **Attention list**: no work record is named. Show untriaged work, `needs-triage`, and `needs-info` with new activity.
- **Specific target**: a work ID, issue number, path, URL, or PR is named. Treat an external PR as a request with attached code only when repository setup uses PRs as a request surface.

## Process

1. Build the attention list when no target is named.
   - Query the configured backend with explicit limits or pagination.
   - Show counts and a one-line summary for each item.
   - Include external PRs only when the repository setup says they are triage work.
   - Completion criterion: one work record or request surface is selected, or the report says there is no triage work in scope.

2. Collect target context.
   - Read title, body, stage state, lifecycle state, State Reasons, comments or receipts, ownership, linked implementation artifacts, attachments, containment, dependency relationships, and prior triage notes.
   - Inspect related code, tests, docs, domain glossary, architectural decision records, and current behavior only when they materially affect the route.
   - Classify the request as `bug`, `enhancement`, or another repository-defined category when that affects verification. This category does not need to become a label.
   - Check redundancy by concept, not wording: is the requested behavior already implemented?
   - Check prior rejection or out-of-scope records when the repository has them.
   - For bugs, make a proportionate reproduction attempt from reporter steps.
   - For PRs, inspect the diff and relevant checks.
   - Completion criterion: the recommendation can name category, established facts, verified behavior, assumptions, unknowns, blockers, reproduction or PR verification result, redundancy result, and prior rejection result.

3. Decide the route and identify confirmation gates.
   - Apply ordinary `needs-info` and `needs-pack` routing directly when the target is clear and the evidence supports one route.
   - If a maintainer explicitly requests one of the triage outcomes above, treat that as authorization for ordinary routing side effects and use that outcome without reopening the judgment.
   - Choose `closed` for duplicate, already implemented, rejected, not actionable, or no-longer-relevant work.
   - Choose `needs-info` when a specific missing fact, human decision, permission, external dependency, or acceptance gate blocks safe packing.
   - For `needs-info`, classify the State Reason cause as `missing-facts`, `decision-needed`, `access-needed`, `external-state`, or `acceptance-needed`.
   - Set the State Reason owner to the smallest accountable owner: `reporter`, `maintainer`, `human`, `agent`, or `external-system`.
   - Recommend `issue-grill` when the missing input is a product, domain, architecture, naming, or testing decision that needs a structured interview.
   - Choose `needs-pack` when the work is worth doing and ready to be packaged as a single issue package or PRD package.
   - Ask before editing only when the target is ambiguous, the route is uncertain, the route depends on a human judgment not already recorded, closure is needed without explicit closure authorization, the duplicate target is unclear, the edit would overwrite a maintainer conclusion, or existing ownership, linked PRs, containment, dependency relationships, or State Reasons make the routing side effect unsafe.
   - Completion criterion: the route is safe to apply, or one exact confirmation question is asked with the evidence and risk named.

4. Apply the route when safe or confirmed.
   - Unless the user explicitly asks for batch work, update one work record or request surface at a time.
   - Remove conflicting active queue state.
   - For `needs-info`, record the needs-info template below with a State Reason.
   - For `needs-pack`, record backend notes with category, established facts, package inputs, likely package shape, verification clues, evidence links, and non-blocking unknowns.
   - For `closed`, record the reason and close the work only after explicit closure authorization or confirmation. Use close-reason labels only when the repository already has that convention.
   - Completion criterion: backend stage state, lifecycle state, notes, and relationships express one route without contradictory public stage state.

5. Report.
   - Keep the user-facing report short; backend notes may use the structured templates.
   - Include the issue link or work ID, outcome, state changes, material facts verified, unresolved questions, and next skill.
   - Omit empty sections.
   - Completion criterion: the next actor can continue without rereading the whole triage session.

## Templates

### Needs Info

```markdown
## Triage Notes

Category: <bug, enhancement, or repository category>

Established facts:

- <fact>

Verified behavior:

- <reproduction, PR check, current behavior check, or not applicable>

Needed from <person, role, or skill>:

- <specific question or decision>

## State Reason

State: needs-info
Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
Owner: <reporter, maintainer, human, agent, or external-system>
Question: <one specific question, decision, permission, external event, or acceptance gate>
Resume with: <issue-triage, issue-grill, or issue-pack>
Exit criteria: <what must be true before this delivery unit can leave needs-info>

Recommended next skill: <issue-grill, issue-triage, issue-pack, or none>
```

### Needs Pack

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

Recommended package shape: <single issue package or PRD package>
```

## Boundaries

- Do not write a PRD or create child records; use `issue-pack`.
- Do not mark work `ready-for-agent`.
- Do not claim or implement work.
- Do not ask broad questions when a specific missing fact can be named.
- Do not run a full product interview; route structured decisions to `issue-grill`.
- Do not deep-dive code unless the route depends on that evidence.
- Do not mark PRD children with public stage state.
