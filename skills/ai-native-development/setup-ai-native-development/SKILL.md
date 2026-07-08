---
name: setup-ai-native-development
description: Configure a repository for the AI-native development loop.
disable-model-invocation: true
---

# Setup AI-Native Development

Set up a repository so the AI-native workflow can run with one configured workflow state backend, shared state rules, relationship conventions, claim policy, implementation isolation, domain references, and agent-facing docs.

This is a prompt-driven setup skill. Explore first, present findings, walk the user through one decision at a time, then write only after confirmation.

## Process

1. Explore the repository.
   - Inspect `.and/config.yml`, `git remote -v`, `.git/config`, root `AGENTS.md` / `CLAUDE.md`, `docs/agents/`, current issue-tracker docs, label docs, claim docs, branch or worktree docs, domain docs, ADRs, glossary, out-of-scope records, and existing workflow conventions.
   - If GitHub is the likely tracker and `gh` is available, inspect existing labels and issue relationship support.
   - Note whether external PRs are treated as request surfaces.
   - Completion criterion: you can state the current workflow state backend, tracker when any, labels or stage representation, relationship conventions, claim signals, implementation branch or worktree conventions, domain and ADR layout, agent-doc layout, out-of-scope convention, and gaps.

2. Verify external skill dependencies.
   - Required Matt skills: `grilling`, `domain-modeling`, `tdd`, and `code-review`.
   - Inspect the current session's available skills when visible. If needed, run `npx --yes skills list -a codex --json` and `npx --yes skills list -g -a codex --json`, or the repository's documented skill-list command for each configured agent scope.
   - If any required skill is missing, stop setup with a blocker naming the missing skills and this command: `npx --yes skills add mattpocock/skills -g --agent codex claude-code --skill <missing-skill...> -y`.
   - Do not report the AI-native workflow ready while required Matt skills are missing.
   - Completion criterion: required external skills are present, or setup has stopped with exact missing skill names.

3. Present setup decisions one at a time.
   - Start each section with a short explainer: what the decision controls, why the workflow needs it, and what changes if the user picks differently.
   - Recommend a default from repository facts, then ask for confirmation.
   - Do not ask the next setup question until the current one is answered or safely inferred.
   - Completion criterion: every setup decision is confirmed or explicitly inferred from existing repository convention.

4. Decide the workflow state backend.
   - Choose exactly one backend: `github-native` or `markdown-file-based`.
   - Recommend `github-native` when the repository already uses GitHub issues as workflow state and native relationships are available.
   - Recommend `markdown-file-based` when repository markdown files should be the authoritative workflow state and GitHub issues should not be used as a discussion, notification, mirror, or synchronization surface.
   - Prepare `.and/config.yml` with only:

     ```yaml
     version: 1
     workflow_state_backend: <github-native or markdown-file-based>
     ```

   - Do not add label mappings, work-root overrides, stale-claim thresholds, branch prefixes, or other fields in the first schema version.
   - Completion criterion: the repository has one confirmed authoritative workflow state backend and the minimal config content is known.

5. Decide the GitHub issue surface when the backend is `github-native`.
   - Recommend GitHub when a remote points to GitHub.
   - For GitHub, ask whether external PRs are a request surface.
   - Record repository location, read/write command or API, PR-as-request setting, how to resolve bare issue references such as `#123`, and how to read parent/sub-issues and blockers when available.
   - Completion criterion: the workflow knows where to read and write issues, how to resolve issue identities, and whether PRs enter triage.

6. Decide stage state and lifecycle rules.
   - Public stage states: `needs-triage`, `needs-info`, `needs-pack`, `ready-for-agent`.
   - For `github-native`, use labels for active stage state and GitHub closed state for lifecycle outcomes.
   - For `github-native`, define active state labels as `needs-triage`, `needs-info`, `needs-pack`, and `ready-for-agent`.
   - For `github-native`, define `parent-prd` as the structural parent PRD label.
   - For `github-native`, map optional category labels such as `bug` and `enhancement` only when the repository actually uses category labels.
   - For `markdown-file-based`, use package frontmatter for `stage` and `lifecycle`.
   - For `markdown-file-based`, do not create or map GitHub labels for workflow state.
   - Closure convention: lifecycle outcome plus completion evidence; close-reason labels only when the repository already uses them.
   - Stage invariant: each delivery unit has at most one public stage state, and PRD children do not carry public stage state.
   - `needs-info` convention: every current `needs-info` route carries a State Reason with `Cause`, `Owner`, `Question`, `Resume with`, and `Exit criteria`; `Resume with` must name a workflow skill, State Reason history is append-only, and the latest State Reason supersedes earlier State Reasons.
   - Completion criterion: stage state, lifecycle outcome, and State Reason representation are clear for the configured backend.

7. Decide relationships and claims.
   - For `github-native`, parent/sub-issue links express PRD package structure and blocked-by/blocking links express execution order.
   - For `markdown-file-based`, parent `children` and child `parent` frontmatter express containment, and `blocked_by` on the blocked work record expresses execution order.
   - Parent PRDs are not blockers for their children merely because they are parents.
   - A `parent-prd` with `ready-for-agent` is picked and claimed as the whole PRD package.
   - PRD children are independently-grabbable internal execution slices, not public pick or claim targets.
   - Claim policy chooses assignee, claim comment or receipt, stale-claim threshold, who can release or override claims, where PRD package claims are recorded, and whether child coverage comments are required.
   - Claim policy may define how a parent PRD owner records internal subagent delegation without creating separate public ownership.
   - Decide implementation isolation: branch naming, worktree root or convention, base branch, how linked branches or PRs are recorded, and what counts as an unsafe dirty worktree.
   - Completion criterion: the repository has one backend-specific rule for containment, one rule for execution dependencies, one rule for ownership, and one rule for isolated implementation work.

8. Decide domain, decision, and rejection sources.
   - Locate or create the repository's domain glossary, ADR directory, and agent-facing domain reference.
   - Decide whether the repository has one domain context or multiple contexts.
   - Decide whether prior rejections and out-of-scope requests are recorded, where they live, and how `issue-triage` should consult them.
   - Do not create a heavy docs system when the repository only needs a lightweight `docs/agents/domain.md`.
   - Completion criterion: later triage and pack runs know where to find domain language, architectural decisions, and prior rejection evidence.

9. Draft the changes for review.
   - Prepare an agent entrypoint block for the existing `AGENTS.md` or `CLAUDE.md`.
   - Prepare `.and/config.yml`.
   - Prepare project docs such as `docs/agents/ai-native-development.md`, `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/claim-rules.md`, `docs/agents/implementation-rules.md`, and `docs/agents/domain.md`.
   - For `github-native`, prepare label creations only when labels do not already exist and the user approved them.
   - Completion criterion: the user can review exact file edits and backend changes before anything durable is written.

10. Write after confirmation.
   - Create or update `.and/config.yml`.
   - Update the existing agent entrypoint instead of creating a duplicate.
   - Preserve project-specific rules when replacing old docs.
   - For `github-native`, create labels only when the user confirmed and backend permissions are available.
   - Completion criterion: docs, configured backend state, and backend assumptions match the confirmed setup.

11. Report.
   - List files changed, backend choice, `.and/config.yml`, required Matt skill status, labels created or mapped, backend assumptions, PR-as-request setting when relevant, relationship rules, claim rules, implementation isolation rules, domain and ADR locations, out-of-scope convention, and skills now ready to use.
   - Completion criterion: a future agent can run `issue-intake`, `issue-triage`, or `ask-andie` without rediscovering setup decisions.

## Boundaries

- Do not change product requirements or implementation code.
- Do not migrate existing issues unless the user explicitly asks.
- Do not invent backend automation beyond the confirmed setup.
- Do not create additional backend support beyond `github-native` and `markdown-file-based` unless the repository needs it and the user confirms it.
- Do not release claims or repair backend drift.
- Do not add public stage states beyond the confirmed small set.
- Do not create both `AGENTS.md` and `CLAUDE.md`; update the existing entrypoint or ask which one to create.
