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

3. Recommend a route before editing.
   - If a maintainer explicitly requests one of the triage outcomes above, confirm label, comment, and closure side effects, then use that outcome without reopening the judgment.
   - Choose `closed` for duplicate, already implemented, rejected, not actionable, or no-longer-relevant work.
   - Choose `needs-info` when a specific missing fact, human decision, permission, external dependency, or acceptance gate blocks safe packing.
   - Recommend `grill-with-docs` when the missing input is a product, domain, architecture, naming, or testing decision that needs a structured interview.
   - Choose `needs-pack` when the work is worth doing and ready to be packaged as a single issue package or PRD package.
   - Completion criterion: the recommendation names the outcome, evidence, risk, and next skill.

4. Apply the confirmed outcome.
   - Unless the user explicitly asks for batch work, update one issue or PR at a time.
   - Remove conflicting active queue labels.
   - For `needs-info`, post the needs-info template below.
   - For `needs-pack`, comment with category, established facts, package inputs, likely package shape, verification clues, evidence links, and non-blocking unknowns.
   - For `closed`, comment with the reason and close the issue. Use close-reason labels only when the repository already has that convention.
   - Completion criterion: tracker state, comments, and labels express one route without contradictory active queue state.

5. Report.
   - Include the issue link, outcome, labels changed, facts verified, unresolved questions, and next skill.
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

Recommended next skill: <grill-with-docs or none>

Resume point: <where triage or pack should continue>
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
- Do not run a full product interview; route structured decisions to `grill-with-docs`.
- Do not deep-dive code unless the route depends on that evidence.
- Do not mark PRD children with active queue labels.
