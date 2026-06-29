---
name: issue-intake
description: A tracker intake flow for recording raw requests as clear issues.
disable-model-invocation: true
---

# Issue Intake

Turn a raw user request into a clear issue tracker entry. Intake records the work; it does not triage, implement, write a PRD, or split the work unless the user asks for that next flow.

## Defaults

- Use GitHub Issues by default unless the user or repository explicitly specifies another tracker.
- Write issue titles and bodies in Simplified Chinese unless the user explicitly asks for another language.
- Follow the repository's issue templates, labels, and status conventions when present.
- Keep commands, package names, environment variables, file paths, API names, and code identifiers verbatim.
- Use existing labels only. Apply category or status labels when the repository taxonomy makes the right labels clear; otherwise leave labels unset and mention the gap.
- Use tracker APIs or CLIs documented by the repository. For GitHub Issues, prefer `gh`.

## Steps

1. Resolve the intake target.
   - Determine the repository from the user's explicit target, current working directory, remotes, repository docs, or recent context. Use GitHub Issues unless another tracker is explicit.
   - Create a new issue when the user presents a distinct work item that should be tracked independently and is not explicitly tied to an existing issue.
   - Update an existing issue when the user provides an issue number, issue URL, or new requirements, corrections, or context for an identified issue.
   - If the target is ambiguous and the safe assumption is obvious from recent context, proceed and mention the assumption. Ask only when the wrong target would create durable tracker noise.
   - Completion criterion: the agent knows whether it is creating a new issue or updating an existing issue, which repository and tracker it applies to, and the existing issue identity when updating.

2. Ground the request lightly.
   - Inspect nearby repository facts that materially affect the issue text: issue templates, contributor or agent docs, relevant product docs, scripts, package configuration, similar code, existing labels, and open issues.
   - Check for obvious duplicates before creating a new issue. If a duplicate is clear, update or comment on the existing issue instead of creating a new one.
   - Do not over-research. Intake should gather enough context to avoid a misleading issue, not solve the issue.
   - Completion criterion: the issue text can name the current state accurately enough that a later triage run will not start from a false premise.

3. Shape the issue.
   - Use a concise Simplified Chinese title that names the desired system change, not the user's raw wording, unless another issue language was explicitly requested.
   - If the repository has an issue template, use it unless it clearly does not fit the request.
   - For a generic issue body, prefer these sections in the issue language and omit sections that do not fit:

```markdown
## Background

## Current behavior

## Expected behavior

## Initial scope / Recommended approach

## Draft acceptance criteria

## Questions for triage

## Out of scope
```

   - For bug reports, include current behavior and reproduction clues when available.
   - For follow-up details on an existing issue, edit the body when the information changes the requirement itself; add a comment when it is discussion history or an execution note.
   - Completion criterion: the issue body is useful to a later triage or implementation pass: it states context, desired behavior, draft acceptance criteria, and open questions without pretending unresolved decisions are settled.

4. Write the issue.
   - For GitHub Issues, create with `gh issue create --repo <owner/repo> --title ... --body-file ...`, adding labels only when they were resolved from existing repository conventions.
   - Before updating an existing GitHub issue body, read the current issue with `gh issue view <number-or-url> --json title,body,labels,comments`. Merge the new information into the existing durable specification; never replace the body with only the latest user message.
   - For GitHub Issues, update with `gh issue edit <number-or-url> --title ... --body-file ...` when changing the durable specification.
   - For GitHub Issues, comment with `gh issue comment <number-or-url> --body ...` when preserving conversational context is more appropriate than rewriting the issue.
   - For other supported trackers, use the documented CLI or API with the same create, edit, and comment distinction.
   - If no writable tracker is available, return a ready-to-file issue draft and state exactly what tracker access or target is missing.
   - Do not add AI disclaimers, triage results, or implementation plans unless the user asked for that downstream flow.
   - Completion criterion: the tracker returns an issue URL or update success, or a complete ready-to-file draft is returned with a concrete blocker.

5. Report the result.
   - Return the issue link when available, final title, and labels or status when set.
   - Briefly mention any assumption or unresolved decision that was captured in the issue.
   - Completion criterion: the user can open the issue and see exactly where the request landed.

## Boundaries

- Do not assign readiness, priority, component, owner, milestone, or status values unless the user requests them or the repository convention makes them clear.
- Do not silently convert a large product idea into many issues. Create one intake issue first, then recommend a planning, PRD, or issue-breakdown flow when appropriate.
- Do not implement the requested change during intake.
