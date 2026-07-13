---
name: setup-and
description: Configure a repository for the AND delivery loop.
disable-model-invocation: true
---

# AND Setup

Audit and configure one repository to run the AND delivery loop through one authoritative workflow-state backend.

## Setup Contract

Repository setup is conformant when:

- `.and/config.yml` satisfies the backend-neutral [Config Contract](../and-backend-contract/backend-contract.md#config-contract) and selects exactly one supported backend.
- The selected backend satisfies its setup-readiness contract:
  - [`github-native`](../and-backend-contract/backends/github-native.md#setup-readiness)
  - [`markdown-file-based`](../and-backend-contract/backends/markdown-file-based.md#setup-readiness)
- Every directory containing Agent instructions follows the Agent Instruction Policy below.
- The root `AGENTS.md` contains one effective, concise AND section that directs agents to `.and/config.yml`, the configured backend, `ask-andie`, and the installed AND skills and backend contract.
- No effective repository instruction contradicts the configured backend, directs agents to parallel workflow state, or requires a relationship fallback forbidden by the backend contract.

External skill readiness and the next-skill receipt are mandatory report results, not repository conformance conditions. When the user explicitly requests a full-ready result, missing external skills make full readiness incomplete while repository conformance is still reported separately.

## Process

### 1. Explore Current State

Read `.and/config.yml` first, then work outward from evidence:

- Validate config against the [Config Contract](../and-backend-contract/backend-contract.md#config-contract).
- Inspect repository identity and git remotes as setup and delivery-readiness evidence; they never override valid config.
- For valid config, load only the selected backend's Setup Readiness. Repository instructions that disagree with it are repair gaps, not backend-selection evidence.
- For missing, malformed, unsupported, or extended config, load both Setup Readiness sections and inspect git remotes, existing workflow state, and effective instructions to identify viable targets and a recommended source of truth.
- Inspect backend state using its readiness section and representation links. During a GitHub relationship probe, also follow the shared [Relationship API Recipes](../and-backend-contract/backends/github-native.md#relationship-api-recipes).
- Scan every `AGENTS.md` and `CLAUDE.md` outside dependency, generated, and VCS directories. Classify each containing directory, resolve symlinks, and follow references only far enough to determine effective workflow rules.
- Check `and-interview-contract`, `grilling`, `research`, `prototype`, `tdd`, and `code-review` separately as [Environment Readiness](#environment-readiness).

The audit is read-only. A capability that cannot be established without mutation remains unverified until an approved envelope authorizes a reversible probe.

Completion criterion: every Setup Contract condition has evidence, a gap, or one named unresolved decision; viable backend targets and environment readiness are known.

### 2. Resolve Genuine Decisions

Investigate facts before asking. A valid config settles backend selection unless the user explicitly requests a backend change. When config is invalid or absent, recommend from current evidence: a GitHub remote and usable native capabilities favor `github-native`; a repository intended to keep workflow state in versioned files favors `markdown-file-based`.

When a user decision remains:

- ask one decision at a time, in dependency order;
- give the valid options, recommendation, rationale, and impact;
- use the answer to finish dependent evidence gathering before asking the next decision.

Genuine decisions include choosing between two viable sources of truth, merging non-identical paired Agent instructions, and normalizing a mixed instruction layout without an existing policy. Routine missing labels, directories, adapters, or root-section repair are gaps for the write envelope.

Completion criterion: no unresolved choice can materially change the proposed writes.

### 3. Report and Prepare One Write Envelope

Report the completed assessment at the requested depth:

- By default, give a compact satisfied summary and detail every real gap.
- For a conformant repository, give a concise no-op result.
- When the user explicitly asks for a full audit, show every contract condition and its evidence.
- When the user asks for audit only, stop after the report without writes.

For a setup or repair request with gaps, present one write envelope that includes:

- every file, section, and directory to create, replace, move, or delete;
- every backend action;
- exact structured values, copying config from the neutral Config Contract and, when applicable, labels from the selected backend reference;
- the reason and user-visible impact of each action;
- the complete proposed replacement section for any user-readable Agent instruction section, without unrelated surrounding content.

Show a full patch only when requested. One approval authorizes every listed write. If execution requires any action outside, beyond, or contrary to the approved envelope, stop and request renewed approval for the changed envelope.

Completion criterion: the user can approve all necessary writes once, with no hidden or per-surface follow-up confirmation.

### 4. Apply the Approved Minimum

- Perform only the approved writes.
- Preserve unrelated instructions, documentation, issues, work records, and implementation artifacts.
- Leave valid config and satisfied backend state unchanged.
- Create project-specific documentation only for real repository facts that cannot be inferred from the AND skills or backend contract.
- Do not install external skills unless the user explicitly requested installation and it was included in the envelope.

Completion criterion: every approved gap is addressed and nothing outside the envelope changed.

### 5. Re-audit and Return a Receipt

Run the same assessment against the same target after writes.

- Verify every Setup Contract condition from current evidence.
- Verify that a second apply would be a no-op.
- Report repository conformance separately from external skill readiness and, when requested, full readiness.
- Name files and backend state changed, any remaining blocker, missing skill install commands, and exactly one next workflow skill.
- If a condition remains unsatisfied, report the evidence and required next action instead of declaring success.
- Name a downstream workflow skill only when repository setup is conformant. Otherwise route back to `setup-and` after the stated blocker or decision is resolved.

Completion criterion: the receipt proves the resulting state and routes the user without making the receipt itself a setup requirement.

## Setup Outcomes

| Starting state | Required result |
| --- | --- |
| Fresh repository | Gather evidence, recommend a viable backend, resolve a genuine source-of-truth choice when needed, then propose config, minimum backend state, and Agent instruction integration in one envelope. |
| Existing conformant setup | Make no writes and return the compact conformant receipt. |
| Incomplete setup | Keep valid config and satisfied state; include only proven gaps in the envelope. |
| Unsupported config | Treat setup as nonconformant and resolve one supported target. Propose exact config replacement only when it will not strand conflicting workflow state; any required backend migration is a separate blocker, decision, and operation. |
| Capability failed or unverified | Name the failed evidence and readiness impact. Offer a capability remedy, an approved reversible probe, or a backend-choice decision; readiness remains incomplete. |
| Audit only | Return evidence and gaps, then stop without an approval request or mutation. |

## Agent Instruction Integration

Apply this policy directly; do not load or require another skill:

- `AGENTS.md` holds shared cross-Agent instructions.
- A sibling `CLAUDE.md` imports `@AGENTS.md` first, then may append Claude Code-specific rules. Do not duplicate shared instructions between the two files.
- If only `AGENTS.md` exists in a directory, preserve it and add the sibling `CLAUDE.md` adapter.
- If only `CLAUDE.md` exists, move its shared content to sibling `AGENTS.md`, then replace it with the adapter. Use `git mv` for tracked files when possible.
- If paired files already follow the import rule and contain no distinct shared instructions, leave them unchanged.
- If paired files contain non-identical or ambiguously shared content, stop for one explicit merge-policy decision; do not merge or discard content autonomously.
- If the project mixes Agent-only, Claude-only, and paired directories without an explicit project policy, report each directory class and stop for one normalization-policy decision.
- If no Agent instruction files exist, propose a root `AGENTS.md` plus a root `CLAUDE.md` adapter without asking the user to choose a filename.

The adapter content is:

```markdown
@AGENTS.md
```

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

Check `and-interview-contract`, `grilling`, `research`, `prototype`, `tdd`, and `code-review` from the session skill list or the repository's documented skill-list command. Report `unverified` when neither establishes availability.

Missing skills do not authorize installation. When installation is requested, use the skill's owning repository and known Agent targets where available:

```bash
npx --yes skills add Andiedie/skills -g --skill and-interview-contract --agent <known-target...>
npx --yes skills add mattpocock/skills -g --skill <missing-matt-skill...> --agent <known-target...>
```

When targets are unknown, omit `--agent` for interactive selection. Keep skills from different repositories in separate install commands.

## Reporting Shape

Keep default reports compact. Group satisfied conditions into one summary. Each gap needs the required result, current evidence, proposed action, reason, and impact.

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

- Setup writes only approved config, minimum backend state, Agent instruction integration, repository-specific setup facts, and explicitly authorized skill installation.
- Existing issues, work records, implementation artifacts, product requirements, and product code remain unchanged. Backend migration is a separate operation.
- Delivery-loop stage work begins only after repository setup is conformant; setup returns one next-skill route without claiming, implementing, closing, merging, or releasing delivery work.
