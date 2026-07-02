---
name: issue-intake
description: Record raw requests as clear tracker issues.
disable-model-invocation: true
---

# Issue Intake

Intake records a raw signal as durable tracker work. It does not decide value, mark readiness, split work, claim, or implement.

## Defaults

- Use GitHub Issues unless the user or repository specifies another tracker.
- Write issue titles and bodies in Simplified Chinese unless the user asks for another language.
- Follow repository issue templates, labels, and status conventions when present.
- Keep commands, package names, environment variables, file paths, API names, and code identifiers verbatim.
- Use existing labels only. Add `needs-triage` when the repository uses the AI-native label set and the work is a new raw signal.
- Do not add `ready-for-agent`, `needs-pack`, `parent-prd`, blocked-by/blocking relationships, assignees, or implementation labels during intake.

## Process

1. Resolve the intake target.
   - Determine the repository from the user's target, current directory, remotes, repository docs, or recent context.
   - Create a new issue when the user presents a distinct work item that should be tracked independently.
   - Update an existing issue when the user provides an issue number, issue URL, or new requirement context for a known issue.
   - Ask only when the wrong target would create durable tracker noise.
   - Completion criterion: the agent knows whether it is creating or updating, which tracker applies, and which issue identity is being updated.

2. Ground the signal lightly.
   - Inspect only facts that materially affect the issue text: templates, agent docs, product docs, scripts, similar code, existing labels, and obvious duplicate issues.
   - If a duplicate is clear, update or comment on the existing issue instead of creating a new one.
   - Do not solve the issue during intake.
   - Completion criterion: the issue text can describe current facts without starting triage from a false premise.

3. Shape the issue.
   - Use a concise title that names the desired system change, not the user's raw wording.
   - Use the repository template when it fits.
   - Use the generic template below when no template fits.
   - For existing issues, edit the body when the requirement changes; comment when the new information is discussion history or execution context.
   - Completion criterion: the issue states context, desired behavior, draft acceptance criteria, and open triage questions without pretending unresolved decisions are settled.

4. Write to the tracker.
   - For GitHub, create with `gh issue create --repo <owner/repo> --title <title> --body-file <body_file>`.
   - Before editing an existing GitHub issue body, read it with `gh issue view <number-or-url> --json title,body,labels,comments`.
   - Merge new durable information into the existing body. Never replace the body with only the latest user message.
   - If no writable tracker is available, return a ready-to-file issue draft and the exact missing access or target.
   - Completion criterion: the tracker returns an issue URL or update success, or the user receives a complete ready-to-file draft with a concrete blocker.

5. Report the result.
   - Return the issue link when available, final title, labels or state set, and unresolved decisions captured in the issue.
   - Completion criterion: the user can open the issue and see where the signal landed.

## Generic issue template

```markdown
## Background

## Current behavior

## Expected behavior

## Initial scope / recommended approach

## Draft acceptance criteria

- [ ] <criterion>

## Questions for triage

## Out of scope
```

## Boundaries

- Do not assign readiness, priority, component, owner, milestone, or implementation status unless repository convention makes it unambiguous.
- Do not split large ideas into many issues. Create one intake issue, then recommend `issue-triage` and `issue-pack` when appropriate.
- Do not create parent/sub-issue or blocked-by/blocking relationships.
- Do not implement the requested change.
