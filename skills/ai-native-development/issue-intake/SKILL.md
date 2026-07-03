---
name: issue-intake
description: Record raw requests as clear tracker issues.
disable-model-invocation: true
---

# Issue Intake

Intake records a raw signal as durable tracker work. It observes and preserves facts; it does not decide value, mark readiness, split work, claim, or implement.

## Defaults

- Use GitHub Issues unless the user or repository specifies another tracker.
- Write issue titles and bodies in Simplified Chinese unless the user asks for another language.
- Follow repository issue templates, labels, and status conventions when present.
- Keep commands, package names, environment variables, file paths, API names, and code identifiers verbatim.
- Use existing labels only. Add `needs-triage` when the repository uses the AI-native label set and the work is a new raw signal.
- Do not add `needs-info`, `needs-pack`, `ready-for-agent`, `parent-prd`, blocked-by/blocking relationships, assignees, milestones, priority labels, or implementation labels during intake.

## Process

1. Resolve the intake target.
   - Determine the repository from the user's target, current directory, remotes, repository docs, or recent context.
   - Create a new issue when the user presents a distinct work item that should be tracked independently.
   - Update an existing issue when the user provides an issue number, issue URL, or new requirement context for a known issue.
   - Ask only when the wrong target would create durable tracker noise.
   - Completion criterion: the agent knows whether it is creating or updating, which tracker applies, and which issue identity is being updated.

2. Ground the signal lightly.
   - Inspect only facts that materially affect the issue text: issue templates, existing labels, obvious duplicate issues, mentioned files, mentioned commands, mentioned errors, and docs needed to avoid recording false context.
   - If a duplicate is exact and obvious, update or comment on the existing issue instead of creating a new one.
   - If another issue is only related or similar, create the intake issue and link the related issue in the body.
   - Do not solve the issue during intake.
   - Completion criterion: the issue text can describe current facts without starting triage from a false premise.

3. Shape the issue.
   - Use a concise title that names the desired system change, not the user's raw wording.
   - Preserve the raw signal's important facts in the body: user wording, errors, logs, screenshots, environment details, URLs, commands, and observed behavior.
   - Separate user-stated expectations from agent inferences.
   - Mark unknowns as unknown instead of filling them in.
   - Use the repository template when it fits.
   - Use the generic template below when no template fits.
   - For existing issues, edit the body when durable facts or requirements change; comment when the new information is discussion history, screenshots, logs, or execution context.
   - If new information changes the issue's nature, record it and recommend `issue-triage`; do not change queue state during intake unless the repository convention makes `needs-triage` unambiguous.
   - Completion criterion: the issue states background, signal, current behavior, desired behavior, evidence, scope clues, acceptance clues, and triage questions without pretending unresolved decisions are settled.

4. Write to the tracker.
   - For GitHub, create with `gh issue create --repo <owner/repo> --title <title> --body-file <body_file>`.
   - Before editing an existing GitHub issue body, read it with `gh issue view <number-or-url> --json title,body,labels,comments`.
   - Merge new durable information into the existing body. Never replace the body with only the latest user message.
   - If no writable tracker is available, return a ready-to-file issue draft and the exact missing access or target.
   - Completion criterion: the tracker returns an issue URL or update success, or the user receives a complete ready-to-file draft with a concrete blocker.

5. Report the result.
   - Return the issue link when available, final title, labels or state set, captured facts, unresolved questions, and `issue-triage` as the next skill.
   - Completion criterion: the user can open the issue, see where the signal landed, and know that triage is the next workflow step.

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
- Do not split large ideas into many issues. Create one intake issue, then recommend `issue-triage`.
- Do not create parent/sub-issue or blocked-by/blocking relationships.
- Do not close duplicates; exact duplicate handling should update or comment on the existing issue and let `issue-triage` decide closure.
- Do not implement the requested change.
