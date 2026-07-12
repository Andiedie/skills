---
name: setup-and
description: Configure a repository for the AND delivery loop.
disable-model-invocation: true
---

# AND Setup

Audit and configure a repository to run the AND delivery loop with exactly one authoritative workflow state backend.

This is a setup and convergence skill, not a workflow handbook. Every run audits the current repository before proposing a write. Derive the target state from this Setup Contract, relevant installed AND workflow skills, and `and-backend-contract`; do not create a second target-state checklist in the repository.

Use the delivery-loop docs only to explain the conceptual model. Do not copy shared workflow rules into each target repository unless they are real repository-specific facts.

## Setup Approach

Explore, classify, assess, present, confirm, converge, then re-audit.

Reading, classification, and reporting are non-mutating. An explicit audit-only request stops after the report without introducing a separate mode or flag. An ordinary setup run reaches the same report first and writes only after the user approves the plan and its existing confirmation gates.

## Setup Contract

Setup is complete when:

- `.and/config.yml` exists with only `version: 1` and `workflow_state_backend`.
- The selected backend has the minimum representation needed by `and-backend-contract`.
- Exactly one effective Agent entrypoint section tells agents to use the AND loop and `ask-andie`.
- No other setup remains an active workflow authority or relationship fallback.
- Real repository-specific facts are preserved; retained legacy data is discoverably non-authoritative and no longer receives workflow writes.
- External skill readiness has been checked and reported.
- A successful final receipt names the next workflow skill. An incomplete setup reports the unmet contract condition, owner, and exit condition instead of success.

## Process

1. Audit the repository.
   - Read this Setup Contract, the relevant installed AND workflow skills needed to verify discovered setup surfaces, and the applicable backend contract before judging target state.
   - Inspect `.and/config.yml`, git remotes, both root `AGENTS.md` and `CLAUDE.md`, agent docs, workflow conventions, `.and/work`, `.scratch` or other legacy work stores, and enough domain or ADR material to recognize real repository facts.
   - Inspect Matt setup surfaces when present: `## Agent skills`, `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, and `docs/agents/domain.md`.
   - If Matt setup, another legacy setup authority, or retained legacy work data is present, read [Existing Setup Convergence](existing-setup-convergence.md) before assigning dispositions.
   - If GitHub is the likely backend and `gh` is available, inspect repository identity, issues, labels, permissions, and native relationship support without mutating them.
   - Do not create, edit, migrate, delete, label, or update backend state during the audit.
   - Completion criterion: every material setup surface and current authority is known.

2. Classify the starting state.
   - `blank`: no recognized Matt or AND setup surface exists.
   - `Matt-configured`: Matt setup is the only coherent active setup.
   - `AND-configured`: AND setup is the only coherent active setup.
   - `mixed`: more than one workflow setup still acts as current authority. A leftover path, heading, or document whose useful content is now ordinary repository fact is a `legacy` finding, not enough by itself to make the repository mixed.
   - `incomplete/outdated`: one recognized setup family exists but is invalid, partial, or stale. A mixed repository remains `mixed` and reports incompleteness as findings.
   - Completion criterion: the report names one starting-state classification and the authority evidence behind it.

3. Assess target-state differences.
   - Give every material artifact or section one current finding: `satisfied`, `missing`, `conflicting`, or `legacy`.
   - Give every proposed change one disposition: `keep`, `create`, `reuse`, `migrate`, `replace`, `remove`, or `defer`.
   - For each item, state the concrete action, reason, and user-visible impact. For `defer`, also name the owner and exit condition.
   - Preserve repository facts separately from the setup structure that happens to contain them.
   - Completion criterion: the user can evaluate the complete convergence boundary without reading a full patch.

4. Choose or verify the backend.
   - If `.and/config.yml` exists and is valid, verify it instead of re-deciding.
   - If no config exists, choose exactly one backend: `github-native` or `markdown-file-based`.
   - Recommend `github-native` when the repository already uses GitHub issues and native parent/sub-issue plus blocked-by/blocking relationships are available.
   - Recommend `markdown-file-based` when workflow state should live in repository files, when no GitHub remote is available, or when GitHub-native relationship capabilities are unavailable.
   - Ask only when there is no config, the config is invalid, repository signals conflict, or the user wants to switch backends.
   - Prepare `.and/config.yml` with only `version: 1` and `workflow_state_backend`.

5. Check backend readiness.
   - For `github-native`, confirm repository identity, issues availability, native parent/sub-issue support, and native blocked-by/blocking support.
   - For `github-native`, confirm authenticated write access for issue creation and updates, stage labels, comments or receipts, ownership recording, lifecycle changes, and native containment and dependency relationship mutations.
   - Use the shared [Relationship API Recipes](../and-backend-contract/backends/github-native.md#relationship-api-recipes) and its capability-result rules instead of duplicating them here.
   - For `github-native`, prepare creation only for missing fixed labels: `needs-triage`, `needs-info`, `needs-pack`, `ready-for-agent`, and `parent-prd`.
   - For `markdown-file-based`, ensure `.and/work` can be created and updated in the repository worktree and no GitHub issue mirror is being configured.
   - If required backend write access cannot be confirmed, report the exact access blocker and do not declare the backend ready.
   - Do not emulate unavailable GitHub-native relationships with markdown task lists, labels, or comments.

6. Check external skill readiness.
   - Check current skill availability from the session list when visible. If needed, use the repository's documented skill-list command. When neither source establishes availability, report it as unverified.
   - Check `grilling`, `tdd`, and `code-review`.
   - Missing external skills are environment readiness gaps, not repository setup failures.
   - Do not install external skills unless the user explicitly asks.
   - Do not block repository setup for missing external skills unless the user asked for full-ready setup or the missing skill blocks the setup itself.
   - Report missing skills with an install command. When the actual agent targets are known, include them explicitly with `--agent <known-target...>`. Otherwise use interactive target selection by omitting `--agent`, for example `npx --yes skills add mattpocock/skills -g --skill <missing-skill...>`.
   - Completion criterion: each required external skill is available, missing, or unverified, and every missing skill has an install command scoped to known targets or interactive target selection.

7. Prepare the setup plan.
   - Present a concise artifact- or section-level difference plan containing the starting state, backend, findings, dispositions and actions, GitHub labels to create or reuse when relevant, Agent entrypoint target, missing external skills, impact, and unresolved decisions.
   - If the user requested only an audit, stop after this report. Otherwise wait for approval before entering the write path.
   - Show a full patch only when the user requests it.
   - Do not output the full workflow state table, full State Reason schema, claim policy, or backend representation.

8. Confirm risky writes.
   - Confirm backend choice when new or changing.
   - Confirm creating or changing `.and/config.yml`.
   - Confirm GitHub label creation.
   - Confirm editing `AGENTS.md` / `CLAUDE.md`, creating `.and/work`, creating project-specific docs, or migrating existing work.
   - Do not ask the user to re-confirm fixed AND invariants such as the small active stage set or one-backend rule after the setup plan is approved.

9. Converge to minimal setup.
   - Create or change `.and/config.yml` only when needed. Leave an existing valid config unchanged.
   - Write the backend minimum: GitHub labels for `github-native` when approved, or `.and/work` for `markdown-file-based`.
   - Apply approved existing-setup dispositions from the conditional reference when loaded, update setup-owned sections in place, and preserve unrelated user content.
   - Create or update project-specific docs only when they record real repository-specific facts.
   - Completion criterion: the Setup Contract is satisfied and future agents can discover the AND loop from repository state alone.

10. Re-audit and report the receipt.
   - Re-run the target-state assessment after approved writes. Verify the Setup Contract and that no further setup write is necessary.
   - A compliant repository is a successful no-op: do not rewrite files, create untracked paths, or mutate backend state merely to normalize wording, ordering, or timestamps.
   - Report what was configured, which backend was selected, which files or backend labels changed, which external skills are missing when any, how to install missing skills, and the next workflow skill.
   - If the Setup Contract remains unsatisfied, report incomplete convergence with the owner and exit condition instead of the success receipt.
   - Keep the receipt short. It is not a setup log or copied PRD.

## Backend-Specific Setup

### GitHub-Native

Use GitHub-native when GitHub issues are the workflow state source and native relationships are available.

- Create or reuse only these AND labels: `needs-triage`, `needs-info`, `needs-pack`, `ready-for-agent`, `parent-prd`.
- Close-reason labels are repository policy and outside the required AND label set; do not create or modify them during AND setup.
- Use the GitHub backend reference for relationship reads, mutations, ID semantics, permissions, and response interpretation; do not copy those recipes into the target repository.
- If native parent/sub-issue or blocked-by/blocking support is unavailable, recommend resolving GitHub capability or using `markdown-file-based`; do not silently degrade.

### Markdown-File-Based

Use markdown-file-based when repository files are the workflow state source.

- Write `.and/config.yml` with `workflow_state_backend: markdown-file-based`.
- Create `.and/work/` and use `.and/work/.gitkeep` only when needed to keep the directory in version control.
- Do not create sample work records.
- Do not create GitHub labels or a GitHub issue mirror.

## Agent Entrypoint

Update the existing Agent entrypoint and audit both conventional files for stale setup authority.

- If `AGENTS.md` exists, prefer it.
- If no `AGENTS.md` exists but `CLAUDE.md` exists, update `CLAUDE.md`.
- If both exist, use `AGENTS.md` as the effective AND entrypoint and do not delete the `CLAUDE.md` file. Give stale setup-owned sections in either file an explicit disposition; after approval, migrate, replace, or remove only those sections while preserving unrelated content.
- If neither exists, ask which one to create.
- Edit the selected section at its existing location, avoid a second effective AND section, and preserve all surrounding user-owned sections.

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

Create or update a project-specific doc only when it records facts that cannot be inferred from the AND skills or backend contract, such as existing domain docs, ADR locations, repository-specific implementation isolation, or GitHub capability limits.

Prefer one file, such as `docs/agents/ai-native-development.md`, when project-specific notes are needed. Do not default to separate tracker, label, claim, implementation, and domain docs.

## Output Shape

Before writing, report the starting-state classification and an artifact/section table with finding, disposition and action, reason, impact, and unresolved owner/exit condition when any. Include the likely backend, Agent entrypoint target, planned file or label changes, and external skill readiness.

For audit-only use, end after that non-mutating report. When blocked, state the blocker, decision or owner action needed, exit condition, and recommendation.

After approved writes and re-audit, use a short success receipt only when the Setup Contract is satisfied:

```markdown
AND setup is converged.

Backend: markdown-file-based
Files changed:
- .and/config.yml
- .and/work/.gitkeep
- AGENTS.md

External skills: missing `tdd`.
Install: <generated install command>

Next: use `and-intake` for new requests, or `ask-andie` if you are unsure where existing work belongs.
```

For incomplete convergence, replace the success statement and next-workflow route with the unmet Setup Contract condition, owner, and exit condition. Avoid long `none` sections, full workflow tables, copied backend schemas, exact-prose requirements, and setup-process logs.

## Boundaries

- Do not change product requirements or implementation code.
- Do not migrate existing issues or work records unless the user explicitly asks.
- Do not configure more than one workflow state backend.
- Do not create GitHub and markdown workflow state in parallel.
- Keep `.and/config.yml` within the v1 schema: `version` and `workflow_state_backend` only.
- Do not invent public stage states beyond the AND active stage set.
- Do not create duplicate agent entrypoints.
- Do not create an audit-only flag, standalone target-state checklist, or default Matt document set.
- Do not create project-specific docs unless they record real repository-specific facts.
- Do not release claims, override ownership, close work, or repair backend drift.
- Do not install external skills unless the user explicitly asks.
