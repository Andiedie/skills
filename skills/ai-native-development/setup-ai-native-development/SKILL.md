---
name: setup-ai-native-development
description: Configure a repository for the AI-native development loop.
disable-model-invocation: true
---

# Setup AI-Native Development

Set up a repository to run the AND delivery loop with exactly one configured workflow state backend.

This is a repository bootstrap skill, not a workflow handbook. Discover the repository, choose or verify the backend, write the minimal configuration, update the existing agent entrypoint, check external skill readiness, and report the next workflow skill.

Use the delivery-loop docs and `ai-native-backend-contract` as the source of truth for workflow and backend rules. Do not copy those rules into each target repository unless they are real repository-specific facts.

## Setup Approach

Explore first, present findings, confirm durable choices, then write.

AND setup centers on one workflow state backend and minimal repository integration.

## Setup Contract

Setup is complete when:

- `.and/config.yml` exists with only `version: 1` and `workflow_state_backend`.
- The selected backend has the minimum representation needed by `ai-native-backend-contract`.
- The existing agent entrypoint tells agents to use the AND loop and `ask-andie`.
- External skill readiness has been checked and reported.
- The final receipt names the next workflow skill.

## Process

1. Explore the repository.
   - Inspect `.and/config.yml`, git remotes, root `AGENTS.md` / `CLAUDE.md`, existing agent docs, existing workflow conventions, existing `.and/work`, and enough domain or ADR docs to preserve established repository conventions.
   - If GitHub is the likely backend and `gh` is available, inspect repository identity, issues, labels, and native relationship support.
   - Check current skill availability from the session list when visible. If needed, use the repository's documented skill-list command or `npx --yes skills list -a codex --json`.
   - Completion criterion: you can say whether the repo is already configured, which backend is likely, which entrypoint to edit, what writes are needed, and what is blocking setup.

2. Choose or verify the backend.
   - If `.and/config.yml` exists and is valid, verify it instead of re-deciding.
   - If no config exists, choose exactly one backend: `github-native` or `markdown-file-based`.
   - Recommend `github-native` when the repository already uses GitHub issues and native parent/sub-issue plus blocked-by/blocking relationships are available.
   - Recommend `markdown-file-based` when workflow state should live in repository files, when no GitHub remote is available, or when GitHub-native relationship capabilities are unavailable.
   - Ask only when there is no config, the config is invalid, repository signals conflict, or the user wants to switch backends.
   - Prepare `.and/config.yml` with only `version: 1` and `workflow_state_backend`.

3. Check backend readiness.
   - For `github-native`, confirm repository identity, issues availability, label read/write capability when labels are missing, native parent/sub-issue support, native blocked-by/blocking support, and whether external PRs enter intake or triage.
   - For `github-native`, prepare creation only for missing fixed labels: `needs-triage`, `needs-info`, `needs-pack`, `ready-for-agent`, and `parent-prd`.
   - For `markdown-file-based`, ensure `.and/work` can exist and no GitHub issue mirror is being configured.
   - Do not emulate unavailable GitHub-native relationships with markdown task lists, labels, or comments.

4. Check external skill readiness.
   - Check `grilling`, `tdd`, and `code-review`.
   - Missing external skills are environment readiness gaps, not repository setup failures.
   - Do not install external skills unless the user explicitly asks.
   - Do not block repository setup for missing external skills unless the user asked for full-ready setup or the missing skill blocks the setup itself.
   - Report missing skills with an install command such as `npx --yes skills add mattpocock/skills -g --agent codex --skill <missing-skill...> -y`, adjusted to the known agent scope when appropriate.

5. Prepare the setup plan.
   - Present a concise plan containing the backend, files to create or update, GitHub labels to create or reuse when relevant, the agent entrypoint target, the external PR setting when relevant, missing external skills, and unresolved decisions.
   - Do not output the full workflow state table, full State Reason schema, claim policy, or backend representation.

6. Confirm risky writes.
   - Confirm backend choice when new or changing.
   - Confirm creating or overwriting `.and/config.yml`.
   - Confirm GitHub label creation.
   - Confirm editing `AGENTS.md` / `CLAUDE.md`, creating `.and/work`, creating project-specific docs, treating external PRs as request surfaces, or migrating existing work.
   - Do not ask the user to re-confirm fixed AND invariants such as the small active stage set or one-backend rule after the setup plan is approved.

7. Write minimal setup.
   - Write `.and/config.yml`.
   - Write the backend minimum: GitHub labels for `github-native` when approved, or `.and/work` for `markdown-file-based`.
   - Update the existing agent entrypoint instead of creating a duplicate.
   - Create or update project-specific docs only when they record real repository-specific facts.
   - Completion criterion: future agents can discover the AND loop from repository state alone.

8. Report the receipt.
   - Report what was configured, which backend was selected, which files or backend labels changed, which external skills are missing when any, how to install missing skills, and the next workflow skill.
   - Keep the receipt short. It is not a setup log or copied PRD.

## Backend-Specific Setup

### GitHub-Native

Use GitHub-native when GitHub issues are the workflow state source and native relationships are available.

- Create or reuse only these AND labels: `needs-triage`, `needs-info`, `needs-pack`, `ready-for-agent`, `parent-prd`.
- Close-reason labels are repository policy and outside the required AND label set; do not create or modify them during AND setup.
- If native parent/sub-issue or blocked-by/blocking support is unavailable, recommend resolving GitHub capability or using `markdown-file-based`; do not silently degrade.

### Markdown-File-Based

Use markdown-file-based when repository files are the workflow state source.

- Write `.and/config.yml` with `workflow_state_backend: markdown-file-based`.
- Create `.and/work/` and use `.and/work/.gitkeep` only when needed to keep the directory in version control.
- Do not create sample work records.
- Do not create GitHub labels or a GitHub issue mirror.
- Treat GitHub PRs, when present, as implementation artifacts only.

## Agent Entrypoint

Update the existing agent entrypoint.

- If `AGENTS.md` exists, prefer it.
- If no `AGENTS.md` exists but `CLAUDE.md` exists, update `CLAUDE.md`.
- If both exist, update `AGENTS.md` and do not delete `CLAUDE.md`.
- If neither exists, ask which one to create.

Keep the entrypoint short:

```markdown
## AI-native development

This repository uses the AND delivery loop.

- Read `.and/config.yml` before workflow-state work.
- Use the configured backend as the source of truth.
- Use `ask-andie` when the next workflow skill is unclear.
- Do not maintain parallel GitHub and markdown workflow state.
- For workflow rules, use the installed `ai-native-development` skills and backend contract.
```

## Project-Specific Docs

Do not create a heavy project documentation set by default.

Create or update a project-specific doc only when it records facts that cannot be inferred from the AND skills or backend contract, such as existing domain docs, ADR locations, external PR policy, repository-specific implementation isolation, or GitHub capability limits.

Prefer one file, such as `docs/agents/ai-native-development.md`, when project-specific notes are needed. Do not default to separate tracker, label, claim, implementation, and domain docs.

## Output Shape

Before writing, use an exploration summary with the likely backend, entrypoint target, planned file or label changes, missing external skills, and unresolved decisions.

When blocked, state the blocker, the decision needed, and your recommendation.

After writing, use a short receipt:

```markdown
AND setup is configured.

Backend: markdown-file-based
Files changed:
- .and/config.yml
- .and/work/.gitkeep
- AGENTS.md

External skills: missing `tdd`.
Install: npx --yes skills add mattpocock/skills -g --agent codex --skill tdd -y

Next: use `issue-intake` for new requests, or `ask-andie` if you are unsure where existing work belongs.
```

Avoid long `none` sections, full workflow tables, copied backend schemas, and setup-process logs.

## Boundaries

- Do not change product requirements or implementation code.
- Do not migrate existing issues or work records unless the user explicitly asks.
- Do not configure more than one workflow state backend.
- Do not create GitHub and markdown workflow state in parallel.
- Keep `.and/config.yml` within the v1 schema: `version` and `workflow_state_backend` only.
- Do not invent public stage states beyond the AND active stage set.
- Do not create duplicate agent entrypoints.
- Do not create project-specific docs unless they record real repository-specific facts.
- Do not release claims, override ownership, close work, or repair backend drift.
- Do not install external skills unless the user explicitly asks.
