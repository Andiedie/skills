---
name: issue-intake
description: Record raw requests as clear workflow work records.
disable-model-invocation: true
---

# Issue Intake

Intake records a raw signal as durable workflow state. It observes and preserves facts; it does not decide value, mark readiness, split work, claim, or implement.

## Backend Rule

Before writing durable state, read `.and/config.yml`, then use `ai-native-backend-contract` for the backend contract and configured backend reference. Use the configured backend reference for raw work-record creation, updates, receipts, stage state, and lifecycle representation.

If `ai-native-backend-contract` is unavailable, stop and ask the user to install it; do not infer backend rules.

If `.and/config.yml` is missing or names an unsupported backend, stop and route to `setup-ai-native-development`. If the backend is configured but temporarily inaccessible, return a ready-to-file draft plus the exact access problem.

## Defaults

- Use the configured workflow state backend as the source of truth.
- Write work titles and bodies in Simplified Chinese unless the user asks for another language.
- Follow repository templates, stage-state conventions, and backend schema when present.
- Keep commands, package names, environment variables, file paths, API names, and code identifiers verbatim.
- Use existing labels only for `github-native`. Add `needs-triage` when the repository uses the AI-native label set and the work is a new raw signal.
- For `markdown-file-based`, create the work record with `stage: needs-triage` and `lifecycle: open`.
- Do not add `needs-info`, `needs-pack`, `ready-for-agent`, `parent-prd`, blocked-by/blocking relationships, assignees, milestones, priority labels, implementation labels, or ownership metadata during intake.

## Process

1. Resolve the intake target.
   - Determine the repository from the user's target, current directory, remotes, repository docs, or recent context.
   - Determine the configured workflow state backend from `.and/config.yml`.
   - Create a new work record when the user presents a distinct work item that should be tracked independently.
   - Update an existing work record when the user provides an issue number, issue URL, work ID, path, or new requirement context for known work.
   - Ask only when the wrong target would create durable workflow-state noise.
   - Completion criterion: the agent knows whether it is creating or updating, which backend applies, and which work identity is being updated.

2. Ground the signal lightly.
   - Inspect only facts that materially affect the work record text: templates, existing stage-state representation, obvious duplicate work, mentioned files, mentioned commands, mentioned errors, and docs needed to avoid recording false context.
   - If a duplicate is exact and obvious, update the existing work record instead of creating a new one.
   - If another work record is only related or similar, create the intake work record and link the related work in the body.
   - Do not solve the work during intake.
   - Completion criterion: the work record text can describe current facts without starting triage from a false premise.

3. Shape the work record.
   - Use a concise title that names the desired system change, not the user's raw wording.
   - Preserve the raw signal's important facts in the body: user wording, errors, logs, screenshots, environment details, URLs, commands, and observed behavior.
   - Separate user-stated expectations from agent inferences.
   - Mark unknowns as unknown instead of filling them in.
   - Use the repository template when it fits.
   - Use the generic template below when no template fits.
   - For existing GitHub issues, edit the body when durable facts or requirements change; comment when the new information is discussion history, screenshots, logs, or execution context.
   - For markdown-file work records, update the package body for durable facts and add a receipt only when the new information is discussion history, screenshots, logs, or execution context.
   - If new information changes the work's nature, record it and recommend `issue-triage`; do not change stage state during intake unless the backend convention makes `needs-triage` unambiguous.
   - Completion criterion: the work record states background, signal, current behavior, desired behavior, evidence, scope clues, acceptance clues, and triage questions without pretending unresolved decisions are settled.

4. Write to the configured backend.
   - For `github-native`, create with `gh issue create --repo <owner/repo> --title <title> --body-file <body_file>`.
   - Before editing an existing GitHub issue body, read it with `gh issue view <number-or-url> --json title,body,labels,comments`.
   - Merge new durable information into the existing body. Never replace the body with only the latest user message.
   - For `markdown-file-based`, allocate the next `AND-####` ID, create `.and/work/AND-####/package.md` plus `receipts/`, and use the raw work-record schema from the backend reference.
   - If no writable backend is available, return a ready-to-file draft and the exact missing access or target.
   - Completion criterion: the backend returns an issue URL, work ID, or update success, or the user receives a complete ready-to-file draft with a concrete blocker.

5. Report the result.
   - Return a short receipt: issue link or work ID when available, final title, stage state set, what kind of information was recorded, and `issue-triage` as the next skill.
   - Do not repeat the work record body, draft acceptance clues, or triage questions in chat when they were written to the backend.
   - Show unresolved questions only when no backend write happened, or when a question must be answered before the work target can be created or updated safely.
   - Completion criterion: the user can open the work record, see where the signal landed, and know that triage is the next workflow step.

## Generic issue template

```markdown
## Background

## Signal

## Current behavior

## Desired behavior

## Evidence

## Known scope clues

## Draft acceptance clues

## Questions for triage

## Out of scope notes
```

## Boundaries

- Do not triage.
- Do not pack.
- Do not mark work ready.
- Do not assign readiness, priority, component, owner, milestone, or implementation status unless repository convention makes it unambiguous.
- Do not split large ideas into many records. Create one intake record, then recommend `issue-triage`.
- Do not create containment or dependency relationships.
- Do not close duplicates; exact duplicate handling should update the existing work record and let `issue-triage` decide closure.
- Do not implement the requested change.
