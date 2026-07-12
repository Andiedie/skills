---
name: setup-and
description: Configure a repository for the AND delivery loop.
disable-model-invocation: true
---

# AND Setup

Audit and configure a repository to run the AND delivery loop with exactly one authoritative workflow-state backend.

Judge only the repository's current evidence and the required results below. Repositories with the same current evidence must receive the same assessment and actions. Use the installed AND skills and `and-backend-contract` as shared authorities instead of copying workflow rules into the target repository.

## Setup Contract

Repository setup is conformant when:

- `.and/config.yml` is a valid v1 config under `and-backend-contract` and selects exactly one supported backend.
- The configured backend satisfies its minimum storage, capability, and single-source-of-truth requirements in `and-backend-contract`.
- Every Agent instruction file conforms to the `normalize-agent-instructions` policy.
- The root `AGENTS.md` contains one effective, concise AND section that directs agents to `.and/config.yml`, the configured backend, `ask-andie`, and the installed AND skills and backend contract.
- No effective repository instruction contradicts the configured backend, directs agents to parallel workflow state, or requires a relationship fallback forbidden by the backend contract.

External skill readiness and the next-skill receipt are mandatory report results, not repository conformance conditions. When the user explicitly requests a full-ready result, missing external skills make full readiness incomplete while repository conformance is still reported separately.

## Process

### 1. Establish the Target

Read and validate `.and/config.yml` before selecting a backend reference.

- If the config is valid, read the backend-neutral contract and exactly the configured backend reference. Do not infer or switch the backend from repository instructions.
- If the config is missing or invalid, read the backend-neutral contract and inspect the two supported backend references only as needed to choose or recommend a valid target.
- Treat instructions that disagree with a valid config as gaps to repair, never as evidence for backend selection.
- Derive the target from this Setup Contract, the installed AND skills, and `and-backend-contract`. Do not create a repository-local target checklist.

The backend contract owns the supported identifiers and exact v1 schema. When proposing a config write, copy the exact config from the selected backend reference into the write envelope.

Completion criterion: one current or proposed backend target is known, or one genuine user decision is identified.

### 2. Audit Current Evidence

Complete the assessment before proposing any write.

- Inspect the config, git remotes, configured backend state, root and nested `AGENTS.md` / `CLAUDE.md` files, and effective instructions that govern workflow behavior.
- Read the installed `normalize-agent-instructions` skill completely and use its workflow as the sole policy authority for scanning, classifying, changing, and verifying Agent instruction files. Identify symlinks before editing; do not treat a working AND section in the wrong file as normalized.
- Follow instruction references only far enough to determine the effective rules.
- For `github-native`, inspect repository identity, issues availability, fixed labels, authenticated permissions, and native containment and dependency relationship capability.
- For `markdown-file-based`, inspect whether `.and/work` can be the only workflow-state store in the worktree.
- Check `grilling`, `tdd`, and `code-review` availability separately as environment readiness.
- Treat mere file or directory existence as irrelevant unless its current content or behavior affects a required result.
- Do not mutate files, labels, issues, relationships, or work records during the audit.

Completion criterion: every Setup Contract condition has current evidence, every real gap is known, and environment readiness is available, missing, or unverified.

### 3. Resolve Genuine Decisions

Investigate facts before asking the user. Do not ask when evidence determines the action.

When a user decision remains:

- ask one decision at a time, in dependency order;
- give the valid options, recommendation, rationale, and impact;
- use the answer to investigate and resolve the next dependent decision;
- do not present a fixed questionnaire.

Examples that require a decision include choosing between two genuinely viable backends with different desired sources of truth, merging non-identical paired Agent instructions, and normalizing a project whose instruction-file layout has mixed cases without an existing policy.

Completion criterion: no unresolved choice can materially change the proposed writes.

### 4. Report and Prepare One Write Envelope

Always complete the underlying assessment. Adapt only the reporting detail:

- By default, give a compact satisfied summary and detail every real gap.
- For a conformant repository, give a concise no-op result.
- When the user explicitly asks for a full audit, show every contract condition and its evidence.
- When the user asks for audit only, stop after the report without writes.

For a setup or repair request with gaps, present one write envelope that includes:

- every file, section, and directory to create, replace, move, or delete;
- every backend action;
- exact structured values, including config content and GitHub label names;
- the reason and user-visible impact of each action;
- the complete proposed replacement section for any user-readable Agent instruction section, without unrelated surrounding content.

Show a full patch only when requested. One approval authorizes every listed write. If execution requires any action outside, beyond, or contrary to the approved envelope, stop and request renewed approval for the changed envelope.

Completion criterion: the user can approve all necessary writes once, with no hidden or per-surface follow-up confirmation.

### 5. Apply the Approved Minimum

- Perform only the approved writes.
- Preserve unrelated instructions, documentation, issues, work records, and implementation artifacts.
- Leave valid config and satisfied backend state unchanged.
- Create project-specific documentation only for real repository facts that cannot be inferred from the AND skills or backend contract.
- Do not install external skills unless the user explicitly requested installation and it was included in the envelope.

Completion criterion: every approved gap is addressed and nothing outside the envelope changed.

### 6. Re-audit and Return a Receipt

Run the same assessment against the same target after writes.

- Verify every Setup Contract condition from current evidence.
- Verify that a second apply would be a no-op.
- Report repository conformance separately from external skill readiness and, when requested, full readiness.
- Name files and backend state changed, any remaining blocker, missing skill install commands, and exactly one next workflow skill.
- If a condition remains unsatisfied, report the evidence and required next action instead of declaring success.
- Name a downstream workflow skill only when repository setup is conformant. Otherwise route back to `setup-and` after the stated blocker or decision is resolved.

Completion criterion: the receipt proves the resulting state and routes the user without making the receipt itself a setup requirement.

## Backend Application

Use the configured or proposed backend reference as the sole authority for its schema, fixed labels, storage, representation, operations, capability interpretation, and verification. Setup owns only the current-state audit and the approved minimum application.

- For `github-native`, use the shared [Relationship API Recipes](../and-backend-contract/backends/github-native.md#relationship-api-recipes) for relationship reads, mutations, ID semantics, permissions, pagination, response interpretation, write verification, and probe cleanup.
- For either backend, identify missing minimum state from its reference, include each exact action in the write envelope, and leave satisfied state unchanged.

## Agent Instruction Integration

Run `normalize-agent-instructions` as the policy authority. Do not redefine its classifications or merge rules here. Resolve any decision it reports before preparing the write envelope.

Setup has one fixed integration rule beyond that shared policy: when the project has no Agent instruction files, propose a root `AGENTS.md` plus a root `CLAUDE.md` adapter without asking the user to choose a filename. The adapter imports `@AGENTS.md` as defined by `normalize-agent-instructions`.

Add or replace one root `AGENTS.md` section while preserving unrelated content:

```markdown
## AI-native development

This repository uses the AND delivery loop.

- Read `.and/config.yml` before workflow-state work.
- Use the configured backend as the source of truth.
- Use `ask-andie` when the next workflow skill is unclear.
- Do not maintain parallel GitHub and markdown workflow state.
- For workflow rules, use the installed `ai-native-development` skills and backend contract.
```

## Environment Readiness

Check `grilling`, `tdd`, and `code-review` from the session skill list or the repository's documented skill-list command. Report unverified when neither establishes availability.

Missing skills do not authorize installation. When installation is requested, use the accepted distribution and known Agent targets where available:

```bash
npx --yes skills add mattpocock/skills -g --skill <missing-skill...> --agent <known-target...>
```

When targets are unknown, omit `--agent` for interactive selection.

## Reporting Shape

Keep default reports compact. A gap item needs the required result, current evidence, concrete problem, proposed action, reason, and impact. Group satisfied conditions into a short summary unless a full audit was requested.

Before writes, list the backend target, exact file/section actions, exact labels or other backend actions, environment readiness, and any unresolved blocker. End an audit-only request there.

After a successful apply, report:

```markdown
Repository setup: conformant
Backend: <github-native | markdown-file-based>
Changed: <files and backend actions, or none>
Environment readiness: <ready | missing or unverified skills>
Full readiness: <ready | incomplete, only when requested>
Next: <one AND workflow skill>
```

## Boundaries

- Do not change product requirements or implementation code.
- Do not change the configured backend outside the approved write envelope.
- Do not migrate or alter existing issues and work records during setup.
- Do not create project-specific docs without repository-specific facts.
- Do not install external skills without explicit authorization.
- Do not claim work, implement product changes, close work, merge delivery branches, or release ownership.
