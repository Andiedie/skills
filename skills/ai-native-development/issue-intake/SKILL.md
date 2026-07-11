---
name: issue-intake
description: Record raw requests as clear workflow work records.
disable-model-invocation: true
---

# Issue Intake

Intake records a raw signal as durable workflow state. A signal may be a request, bug report, feedback item, or explicitly presented external PR. Intake preserves facts and context without deciding value, readiness, scope split, ownership, or implementation.

## Backend Contract

Before writing durable state, read `.and/config.yml`, then use `ai-native-backend-contract`.

Use the configured backend reference for all create and update operations. If setup is missing, unsupported, or the backend contract is unavailable, stop and route to `setup-ai-native-development` or ask the user to install the missing skill.

If the backend is configured but temporarily inaccessible, return a ready-to-file draft plus the exact access problem.

## Intake Defaults

- Use the configured workflow state backend as the source of truth.
- Use the user's language and repository convention for prose.
- Keep commands, package names, environment variables, file paths, API names, and code identifiers verbatim.
- Follow repository intake templates when present.
- Set only the backend's raw-entry state for new work.
- Do not add routing, readiness, relationship, priority, ownership, milestone, or implementation decisions during intake.

## External PR Signals

An external PR is source evidence and may be referenced as an implementation artifact. It is not an AND work record.

When the user explicitly presents a PR:

- locate an authoritative work record already linked to that PR or clearly tracking the exact request;
- update that one record when the requested behavior is the same;
- otherwise create exactly one configured-backend work record, even when related work exists, and link the PR and related work as context;
- preserve the PR author's stated intent as an author claim, not as verified fact;
- preserve the PR URL, description, relevant check results, and behavior directly observable from a light diff inspection;
- leave stage state, State Reasons, Package Contracts, relationships, ownership, and lifecycle entirely on the configured-backend work record.

Do not search for, scan, or batch-import PRs that the user did not present.

## Process

1. Resolve create or update.
   - Determine the repository from the user's target, current directory, remotes, repository docs, or recent context.
   - Determine the configured workflow state backend from `.and/config.yml`.
   - Create a new work record when the user presents a distinct work item that should be tracked independently.
   - Update an existing work record when the user provides an issue number, issue URL, work ID, path, or new requirement context for known work.
   - Update an existing work record when an exact duplicate is obvious.
   - Create a new work record and link related work when another record is related or similar but not the same work.
   - For an explicitly presented external PR, search its references and the configured backend for one exact authoritative work record. A related but distinct request does not count as that record.
   - Ask only when the wrong target would create durable workflow-state noise.
   - Completion criterion: the agent knows the repository, backend, and whether it is creating new work or updating one existing work record.

2. Ground the signal lightly.
   - Inspect only facts that materially affect the work record text: repository templates, obvious duplicate work, mentioned files, mentioned commands, mentioned errors, URLs, and docs needed to avoid recording false context.
   - For an explicitly presented external PR, read its author, description, URL, relevant check status, and enough of the diff to describe observed behavior. Keep author claims separate from agent-observed evidence.
   - Do not perform full correctness, security, standards, or specification verification of the PR during intake.
   - Do not diagnose, triage, design, split, solve, or implement the work.
   - Completion criterion: the work record can state verified facts without starting triage from a false premise.

3. Shape the work record.
   - Use a concise title that names the desired system change or observed problem, not just the user's raw wording.
   - Preserve the raw signal's important facts in the body: user wording, errors, logs, screenshots, environment details, URLs, commands, and observed behavior.
   - Separate user-stated facts, agent-confirmed facts, agent inferences, and unknowns.
   - Mark unknowns as unknown instead of filling them in.
   - Include scope clues and triage questions only as clues, not decisions.
   - Use the repository template when it fits.
   - Use the generic raw work template below when no template fits.
   - If new information changes the work's nature, record it and recommend `issue-triage`; do not change stage state during intake unless the backend raw-entry convention requires it.
   - Completion criterion: the work record preserves the signal, evidence, current or desired behavior clues, unknowns, and triage questions without pretending unresolved decisions are settled.

4. Write through the configured backend.
   - Create or update through the configured backend reference.
   - When updating, merge new durable information into existing work instead of replacing it with only the latest user message.
   - For a new external-PR signal, create one work record in the configured backend and set only its raw-entry state. For an exact existing record, update that record without creating another.
   - Reference the PR from the work record as source evidence or an implementation artifact according to the configured backend. Do not mutate the PR to carry AND state.
   - Follow the backend reference for body, comment, or receipt placement.
   - If no writable backend is available, return a ready-to-file draft and the exact missing access or target.
   - Completion criterion: the backend returns an issue URL, work ID, or update success, or the user receives a complete ready-to-file draft with a concrete blocker.

5. Report the result.
   - Return a short receipt: created or updated, issue link or work ID when available, final title, raw-entry stage set by the backend, what kind of information was recorded, and `issue-triage` as the next skill.
   - Do not repeat the work record body, triage questions, logs, implementation guesses, or package summaries in chat when they were written to the backend.
   - Show unresolved questions only when no backend write happened, or when a question must be answered before the work target can be created or updated safely.
   - Completion criterion: the user can open the work record, see where the signal landed, and know that `issue-triage` is next.

## Generic Raw Work Template

```markdown
## Request

<raw request summary or user wording>

## Observed Behavior

<what is known now, or unknown>

## Desired Behavior / Expectation

<what the user wants, if stated>

## Evidence

- <links, logs, screenshots, commands, or errors>

## Context

- <environment, related files, or related work>

## Agent Notes

- Confirmed facts:
- Inferences:
- Unknowns:

## Triage Questions

- <questions for `issue-triage`>
```

## Boundaries

- Do not triage, pack, mark ready, claim, implement, close, or assign priority.
- Do not split large ideas into many work records; record one raw work item and route to `issue-triage`.
- Do not create containment, dependency, ownership, milestone, or implementation-plan metadata during intake. An explicitly presented PR link is evidence, not workflow state.
- Do not apply AND stage state, State Reasons, Package Contracts, relationships, ownership, or lifecycle state to an external PR.
- Do not automatically discover, scan, or batch-import external PRs.
- Do not close duplicates; update exact duplicates and let `issue-triage` decide closure.
- Do not turn guesses into requirements; mark unknowns as unknown.
