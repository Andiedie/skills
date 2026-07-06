---
name: issue-triage
description: Decide whether recorded work should close, wait for information, or be packed.
disable-model-invocation: true
---

# Issue Triage

Triage runs the Decide stage for recorded work. It determines whether an issue should close, wait for information, or move to `needs-pack`.

Triage produces an evidence-backed routing decision. It does not make work executable.

## Outcomes

Triage may produce only one outcome:

- `closed`: the work is complete, duplicate, rejected, not actionable, or no longer relevant
- `needs-info`: human, reporter, maintainer, permission, external access, acceptance input, or a decision interview is missing
- `needs-pack`: the work is worth doing and should be packed into an executable delivery unit

Every open triaged delivery unit should have at most one active queue label.

Every `needs-info` route must include a current Blocker block. The latest Blocker block is the source of truth for why the issue is waiting, who owns the answer, what question must be answered, which skill should resume after the answer arrives, and what condition clears the blocker.

Blockers are append-only. Do not edit or delete earlier Blocker comments during normal workflow; append a new Blocker when the blocker materially changes. The latest Blocker supersedes earlier Blockers.

## Invocation

Use this skill in two ways:

- **Attention list**: no issue is named. Show unlabeled issues, `needs-triage`, and `needs-info` with new reporter or maintainer activity.
- **Specific issue or PR**: an issue number, URL, or PR is named. Treat an external PR as a request with attached code when the repository uses PRs as a request surface.

## Process

1. Build the attention list when no target is named.
   - Query the tracker with explicit limits or pagination.
   - Show counts and a one-line summary for each item.
   - Include external PRs only when the repository setup says they are triage work.
   - Completion criterion: one issue or PR is selected, or the report says there is no triage work in scope.

2. Collect target context.
   - Read title, body, labels, comments, assignees, milestone, linked PRs, attachments, parent/sub-issues, blockers, and prior triage notes.
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
   - For `needs-info`, classify the blocker cause as `missing-facts`, `decision-needed`, `access-needed`, `external-state`, or `acceptance-needed`.
   - Set the blocker owner to the smallest accountable owner: `reporter`, `maintainer`, `human`, `agent`, or `external-system`.
   - Recommend `issue-grill` when the missing input is a product, domain, architecture, naming, or testing decision that needs a structured interview.
   - Choose `needs-pack` when the work is worth doing and ready to be packaged as a single issue package or PRD package.
   - Ask before editing only when the target is ambiguous, the route is uncertain, the route depends on a human judgment not already recorded, closure is needed without explicit closure authorization, the duplicate target is unclear, the edit would overwrite a maintainer conclusion, or existing ownership, linked PRs, parent/sub-issues, or blockers make the routing side effect unsafe.
   - Completion criterion: the route is safe to apply, or one exact confirmation question is asked with the evidence and risk named.

4. Apply the route when safe or confirmed.
   - Unless the user explicitly asks for batch work, update one issue or PR at a time.
   - Remove conflicting active queue labels.
   - For `needs-info`, post the needs-info template below with a Blocker block.
   - For `needs-pack`, comment with category, established facts, package inputs, likely package shape, verification clues, evidence links, and non-blocking unknowns.
   - For `closed`, comment with the reason and close the issue only after explicit closure authorization or confirmation. Use close-reason labels only when the repository already has that convention.
   - Completion criterion: tracker state, comments, and labels express one route without contradictory active queue state.

5. Report.
   - Keep the user-facing report short; tracker comments may use the structured templates.
   - Include the issue link, outcome, labels changed, material facts verified, unresolved questions, and next skill.
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

## Blocker

Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
Owner: <reporter, maintainer, human, agent, or external-system>
Question: <one specific question, decision, permission, external event, or acceptance gate>
Resume with: <issue-triage, issue-grill, or issue-pack>
Exit criteria: <what must be true before this issue can leave needs-info>

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

- Do not write a PRD or create child issues; use `issue-pack`.
- Do not mark work `ready-for-agent`.
- Do not claim or implement work.
- Do not ask broad questions when a specific missing fact can be named.
- Do not run a full product interview; route structured decisions to `issue-grill`.
- Do not deep-dive code unless the route depends on that evidence.
- Do not mark PRD children with active queue labels.
