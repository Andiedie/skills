---
name: setup-ai-native-development
description: Configure a repository for the AI-native development loop.
disable-model-invocation: true
---

# Setup AI-Native Development

Set up a repository so the AI-native issue workflow can run with shared tracker rules, labels, relationship conventions, claim policy, domain references, and agent-facing docs.

This is a prompt-driven setup skill. Explore first, present findings, walk the user through one decision at a time, then write only after confirmation.

## Process

1. Explore the repository.
   - Inspect `git remote -v`, `.git/config`, root `AGENTS.md` / `CLAUDE.md`, `docs/agents/`, current issue-tracker docs, label docs, claim docs, domain docs, ADRs, glossary, out-of-scope records, and existing issue workflow conventions.
   - If GitHub is the likely tracker and `gh` is available, inspect existing labels and issue relationship support.
   - Note whether external PRs are treated as request surfaces.
   - Completion criterion: you can state the current tracker, labels, relationship conventions, claim signals, domain and ADR layout, agent-doc layout, out-of-scope convention, and gaps.

2. Present setup decisions one at a time.
   - Start each section with a short explainer: what the decision controls, why the workflow needs it, and what changes if the user picks differently.
   - Recommend a default from repository facts, then ask for confirmation.
   - Do not ask the next setup question until the current one is answered or safely inferred.
   - Completion criterion: every setup decision is confirmed or explicitly inferred from existing repository convention.

3. Decide the issue tracker.
   - Recommend GitHub when a remote points to GitHub.
   - If the tracker is not GitHub, ask the user to describe the tracker workflow in one paragraph.
   - For GitHub, ask whether external PRs are a request surface.
   - Record tracker location, read/write command or API, PR-as-request setting, how to resolve bare issue references such as `#123`, and how to read parent/sub-issues and blockers when available.
   - Completion criterion: the workflow knows where to read and write issues, how to resolve issue identities, and whether PRs enter triage.

4. Decide labels and lifecycle rules.
   - Active state labels: `needs-triage`, `needs-info`, `needs-pack`, `ready-for-agent`.
   - Structural label: `parent-prd`.
   - Optional category labels: map `bug` and `enhancement` only when the repository actually uses category labels.
   - Closure convention: tracker closed state plus closing comment; close-reason labels only when the repository already uses them.
   - Queue invariant: each delivery unit has at most one active state label, and PRD children do not carry active state labels.
   - Completion criterion: every label the skills may apply is mapped to an existing label or an approved label to create.

5. Decide relationships and claims.
   - Parent/sub-issue links express PRD package structure.
   - Blocked-by/blocking links express execution order.
   - Parent PRDs are not blockers for their children merely because they are parents.
   - A `parent-prd` with `ready-for-agent` is picked and claimed as the whole PRD package.
   - PRD children are independently-grabbable internal execution slices, not public pick or claim targets.
   - Claim policy chooses assignee, claim comment, branch or PR link, stale-claim threshold, who can release or override claims, where PRD package claims are recorded, and whether child coverage comments are required.
   - Claim policy may define how a parent PRD owner records internal subagent delegation without creating separate public ownership.
   - Completion criterion: the repository has one rule for structure, one rule for execution dependencies, and one rule for ownership.

6. Decide domain, decision, and rejection sources.
   - Locate or create the repository's domain glossary, ADR directory, and agent-facing domain reference.
   - Decide whether the repository has one domain context or multiple contexts.
   - Decide whether prior rejections and out-of-scope requests are recorded, where they live, and how `issue-triage` should consult them.
   - Do not create a heavy docs system when the repository only needs a lightweight `docs/agents/domain.md`.
   - Completion criterion: later triage and pack runs know where to find domain language, architectural decisions, and prior rejection evidence.

7. Draft the changes for review.
   - Prepare an agent entrypoint block for the existing `AGENTS.md` or `CLAUDE.md`.
   - Prepare project docs such as `docs/agents/ai-native-development.md`, `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/claim-rules.md`, and `docs/agents/domain.md`.
   - Prepare label creations only when labels do not already exist and the user approved them.
   - Completion criterion: the user can review exact file edits and tracker changes before anything durable is written.

8. Write after confirmation.
   - Update the existing agent entrypoint instead of creating a duplicate.
   - Preserve project-specific rules when replacing old docs.
   - Create labels only when the user confirmed and tracker permissions are available.
   - Completion criterion: docs, labels, and tracker assumptions match the confirmed setup.

9. Report.
   - List files changed, labels created or mapped, tracker assumptions, PR-as-request setting, relationship rules, claim rules, domain and ADR locations, out-of-scope convention, and skills now ready to use.
   - Completion criterion: a future agent can run `issue-intake`, `issue-triage`, or `ask-andie` without rediscovering setup decisions.

## Boundaries

- Do not change product requirements or implementation code.
- Do not migrate existing issues unless the user explicitly asks.
- Do not invent tracker automation beyond the confirmed setup.
- Do not create GitLab, local markdown, or other tracker support unless the repository needs it.
- Do not release claims or repair tracker drift.
- Do not add active queue labels beyond the confirmed small set.
- Do not create both `AGENTS.md` and `CLAUDE.md`; update the existing entrypoint or ask which one to create.
