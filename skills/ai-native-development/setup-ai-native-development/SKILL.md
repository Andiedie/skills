---
name: setup-ai-native-development
description: Configure a repository for the AI-native development loop.
disable-model-invocation: true
---

# Setup AI-Native Development

Set up a repository so the AI-native issue workflow can run with shared labels, tracker rules, claim policy, and agent-facing docs.

This is a prompt-driven setup skill. Explore first, present findings, walk the user through one decision at a time, then write only after confirmation.

## Process

1. Explore the repository.
   - Inspect `git remote -v`, `.git/config`, root `AGENTS.md` / `CLAUDE.md`, `docs/agents/`, current issue-tracker docs, label docs, claim docs, and existing issue workflow conventions.
   - If GitHub is the likely tracker and `gh` is available, inspect existing labels and issue relationship support.
   - Note whether external PRs are treated as request surfaces.
   - Completion criterion: you can state the current tracker, labels, relationship conventions, claim signals, agent-doc layout, and gaps.

2. Present setup decisions one at a time.
   - Start each section with a short explainer: what the decision controls, why the workflow needs it, and what changes if the user picks differently.
   - Recommend a default from repository facts, then ask for confirmation.
   - Do not ask the next setup question until the current one is answered or safely inferred.
   - Completion criterion: every setup decision is confirmed or explicitly inferred from existing repository convention.

3. Decide the issue tracker.
   - Recommend GitHub when a remote points to GitHub.
   - If the tracker is not GitHub, ask the user to describe the tracker workflow in one paragraph.
   - For GitHub, ask whether external PRs are a request surface.
   - Completion criterion: the workflow knows where to read and write issues, and whether PRs enter triage.

4. Decide labels and lifecycle rules.
   - Active state labels: `needs-triage`, `needs-info`, `needs-pack`, `ready-for-agent`.
   - Structural label: `parent-prd`.
   - Closure convention: tracker closed state plus closing comment; close-reason labels only when the repository already uses them.
   - Category labels: map only existing category labels the repository actually uses.
   - Completion criterion: every label the skills may apply is mapped to an existing label or an approved label to create.

5. Decide relationships and claims.
   - Parent/sub-issue links express PRD package structure.
   - Blocked-by/blocking links express execution order.
   - Parent PRDs are not blockers for their children merely because they are parents.
   - A `parent-prd` with `ready-for-agent` is picked and claimed as the whole PRD package.
   - Claim policy chooses assignee, claim comment, branch or PR link, and stale-claim threshold.
   - Completion criterion: the repository has one rule for structure, one rule for execution dependencies, and one rule for ownership.

6. Draft the changes for review.
   - Prepare an agent entrypoint block for the existing `AGENTS.md` or `CLAUDE.md`.
   - Prepare project docs such as `docs/agents/ai-native-development.md`, `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, and optional `docs/agents/claim-rules.md`.
   - Prepare label creations only when labels do not already exist and the user approved them.
   - Completion criterion: the user can review exact file edits and tracker changes before anything durable is written.

7. Write after confirmation.
   - Update the existing agent entrypoint instead of creating a duplicate.
   - Preserve project-specific rules when replacing old docs.
   - Create labels only when the user confirmed and tracker permissions are available.
   - Completion criterion: docs, labels, and tracker assumptions match the confirmed setup.

8. Report.
   - List files changed, labels created or mapped, tracker assumptions, PR-as-request setting, relationship rules, claim rules, and skills now ready to use.
   - Completion criterion: a future agent can run `issue-intake`, `issue-triage`, or `ask-andie` without rediscovering setup decisions.

## Boundaries

- Do not change product requirements or implementation code.
- Do not migrate existing issues unless the user explicitly asks.
- Do not invent tracker automation beyond the confirmed setup.
- Do not create both `AGENTS.md` and `CLAUDE.md`; update the existing entrypoint or ask which one to create.
