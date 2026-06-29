---
name: issue-pick
description: Pick agent-ready GitHub issues and synthesize their full context into the next requirement.
disable-model-invocation: true
---

# Issue Pick

Pick the next issue or issue bundle to work on from the current repository's GitHub Issues. Picking gathers and synthesizes the requirement; it does not edit code, claim an issue, or start implementation unless the user asks for that next flow.

## Defaults

- Use GitHub Issues for the repository tied to the current working directory unless the user names another repository.
- Prefer `gh` for GitHub issue and comment reads.
- When using `gh issue list`, never rely on its default limit. Use an explicit `--limit` for the intended slate or use API pagination.
- Read issue and comment text in the language used by the tracker; report the final recommendation in the user's conversation language.
- Treat titles and labels as triage signals, not requirements. Bodies, comments, and images are the requirement evidence.
- Prefer open issues that look agent-solvable now: clear desired change, bounded scope, no obvious product decision, no blocked/waiting state, and enough evidence to verify.
- Bundle issues only when they share the same component or behavior and can be solved by one coherent change. Do not bundle unrelated small issues merely because they are easy.

## Steps

1. Resolve the issue target.
   - Determine the GitHub repository from the user's explicit target, current working directory, git remotes, repository docs, or recent context.
   - If multiple plausible repositories remain and choosing wrong would waste tracker/API work, ask one direct question.
   - Completion criterion: the agent can name one GitHub repository and the local workspace it corresponds to.

2. Build the issue slate.
   - List open issues with enough metadata for title-level triage: number, title, labels, assignees, milestone, created time, updated time, comment count, and URL. Use an explicit limit or pagination, not the `gh issue list` default.
   - Exclude pull requests, closed issues, and issues carrying clear blocked, duplicate, wontfix, or external-dependency labels unless the user explicitly asks to include them.
   - If the repository has too many open issues to inspect comprehensively, make the slate boundary explicit and narrow with repository conventions such as milestones, labels, project views, recent activity, or user-provided focus before picking.
   - Completion criterion: the slate contains the open issue set being considered, or a named bounded subset with the reason it is the right subset; the report can state the query, limit or pagination used, and issue count considered.

3. Pick candidates from the slate.
   - Rank by title and metadata first: relevance to the current repository state, apparent boundedness, likely testability, absence of blockers, and relation to nearby issues.
   - Select a small candidate set: usually one issue, or a bundle when the titles point to the same root behavior or implementation area.
   - Set aside issues whose titles suggest large redesigns, unclear product intent, permissions/account access, external services, security risk acceptance, or business-rule decisions.
   - Completion criterion: every selected candidate has a short rationale, and every obvious non-selection category has a reason.

4. Gather full evidence for each candidate.
   - Read the issue title, body, labels, assignees, milestone, linked references, and every comment in chronological order.
   - Inspect comment updates for corrections, scope changes, reproduction details, acceptance criteria, maintainer preferences, and signs the issue is stale or already handled.
   - Inspect images, screenshots, recordings, or other attachments when they carry product, UI, error, or reproduction evidence. If an attachment cannot be accessed, record the URL and whether it blocks a confident recommendation.
   - Check linked issues or PRs only when they are referenced as requirement context, duplicate context, prior attempts, or evidence that the issue is already solved.
   - Completion criterion: for every selected candidate, the synthesized notes account for its body, all comments, material attachments, and material linked references, or name the exact inaccessible evidence.

5. Synthesize the next requirement.
   - Merge the selected evidence into one requirement when bundled; otherwise keep the single issue as the requirement.
   - State the desired behavior, known current behavior, important constraints, acceptance checks, and unresolved questions.
   - If deep evidence contradicts the title-level pick, return to the slate and choose another candidate instead of forcing the original pick.
   - Completion criterion: the requirement can guide an implementation pass without rereading the whole issue thread, and any remaining user decision is explicit.

6. Report the pick and stop.
   - Tell the user which issue or bundle should be done now, with links, issue numbers, and the reason for the pick.
   - Summarize exactly what should be built or fixed, what evidence drove that conclusion, and what is out of scope.
   - If no issue is agent-ready, say so and list the smallest blocker for the best candidate.
   - Completion criterion: the user knows the recommended next requirement and can decide whether to start implementation.

## Boundaries

- Do not implement, edit files, open a PR, assign issues, change labels, or change milestones during picking.
- Do not choose an issue only because it is first, recent, or short. A pick needs evidence that it is ready and coherent.
- Do not ignore comments or attachments after reading a promising title; late comments often supersede the issue body.
- Do not ask the user to choose among issues until the tracker evidence leaves a genuine product, priority, permission, or scope decision.
