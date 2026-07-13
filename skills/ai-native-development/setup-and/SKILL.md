---
name: setup-and
description: Configure a repository for the AND delivery loop.
disable-model-invocation: true
---

# AND Setup

Audit and configure one repository to run the AND delivery loop with GitHub as its workflow-state authority.

## Setup Contract

Repository setup is conformant when:

- the repository satisfies `and-workflow-contract` [Setup Readiness](../and-workflow-contract/SKILL.md#setup-readiness);
- every directory containing Agent instructions follows the Agent Instruction Policy below;
- no observed GitHub workflow-state contradiction makes stage, relationship, ownership, or lifecycle meaning ambiguous.

External skill readiness and the next-skill receipt are report results rather than repository conformance conditions. When the user explicitly requests full readiness, missing external skills make that result incomplete while repository conformance remains separate.

## Process

### 1. Explore Current State

Work outward from observable evidence:

- Resolve the target repository from an explicit target, current checkout, and Git remotes. More than one plausible repository is a decision, and no GitHub repository is a setup blocker.
- Use `and-workflow-contract` to inspect Issues availability, required labels, issue-write and self-assignment permission, and native relationship capability.
- Read [relationship-api.md](../and-workflow-contract/relationship-api.md) before interpreting native relationship responses or planning a reversible capability probe.
- Inspect existing GitHub workflow state for contradictions that a setup write must preserve and route to `and-sweep` rather than overwrite. An unresolved contradiction keeps repository conformance incomplete.
- Scan every `AGENTS.md` and `CLAUDE.md` outside dependency, generated, and VCS directories. Classify each containing directory, resolve symlinks, and follow references only far enough to determine effective workflow rules.
- Check `and-workflow-contract`, `and-interview-contract`, `grilling`, `research`, `prototype`, `tdd`, and `code-review` separately as [Environment Readiness](#environment-readiness).

The audit is read-only. A write capability that cannot be proven from authoritative permission and role evidence remains unverified until an approved envelope authorizes a reversible probe.

Completion criterion: every Setup Contract condition has evidence, a gap, or one named unresolved decision, and environment readiness is known.

### 2. Resolve Genuine Decisions

Investigate facts before asking. GitHub is the required workflow authority.

When a user decision remains:

- ask one decision at a time in dependency order;
- give valid options, recommendation, rationale, and impact;
- use the answer to finish dependent evidence gathering before asking again.

Genuine decisions include choosing among multiple plausible repositories, merging non-identical paired Agent instructions, normalizing a mixed instruction layout without an existing policy, and authorizing a reversible capability probe. Missing labels and a missing or stale root AND section are ordinary setup gaps.

Completion criterion: no unresolved choice can materially change the proposed writes.

### 3. Prepare One Write Envelope

Report the assessment at the requested depth:

- default to a compact satisfied summary plus every real gap;
- return a concise no-op for a conformant repository;
- show every condition and its evidence only for an explicit full audit;
- stop without writes for audit-only requests.

For setup or repair, present one envelope containing:

- every Agent-instruction file and section to create, replace, move, or delete;
- every GitHub label or approved reversible capability-probe action;
- exact label names and the complete proposed replacement for each user-readable instruction section;
- the reason and user-visible impact of each action.

Show a full patch only when requested. One approval authorizes the complete envelope. Any later action outside or contrary to it requires a new envelope.

Completion criterion: the user can authorize all necessary writes once, with no hidden or per-surface follow-up confirmation.

### 4. Apply The Approved Minimum

- Perform only approved writes and GitHub actions.
- Preserve unrelated instructions, documentation, issues, work records, relationships, ownership, and implementation artifacts.
- Leave satisfied GitHub state unchanged and remove every disposable probe artifact before declaring its capability verified.
- Create project-specific documentation only for real repository facts unavailable from the AND skills and workflow contract.
- Install external skills only when explicitly requested and included in the envelope.

Completion criterion: every approved gap is addressed, every probe is cleaned up, and nothing outside the envelope changed.

### 5. Re-audit And Report

Run the same assessment against the same repository after writes.

- Verify every Setup Contract condition from current evidence.
- Verify that a second apply would be a no-op.
- Report repository conformance separately from environment and full readiness.
- Name changed files and GitHub actions, remaining blockers, missing-skill install commands, and exactly one next workflow skill.
- Route back to `setup-and` rather than downstream when any conformance condition remains unsatisfied.

Completion criterion: the receipt proves current state, idempotence, and one valid next route without making the receipt itself a setup requirement.

## Setup Outcomes

| Starting state | Required result |
| --- | --- |
| Fresh GitHub repository | Verify capabilities, propose required labels and root instructions in one envelope, apply when approved, then re-audit. |
| Existing conformant setup | Make no writes and return the compact conformant receipt. |
| Incomplete setup | Preserve satisfied state and include only proven gaps in the envelope. |
| Missing or ambiguous GitHub repository | Name the exact repository boundary; resolve ambiguity or GitHub availability before proposing workflow writes. |
| Capability failed or unverified | Name the failed evidence and impact, then offer a capability remedy or approved reversible probe; readiness remains incomplete. |
| Audit only | Return evidence and gaps, then stop without mutation. |

## Agent Instruction Policy

Apply this policy directly:

- `AGENTS.md` holds shared cross-Agent instructions.
- A sibling `CLAUDE.md` imports `@AGENTS.md` first, then may append Claude Code-specific rules. Shared instructions appear only in `AGENTS.md`.
- If only `AGENTS.md` exists, preserve it and add the sibling `CLAUDE.md` adapter.
- If only `CLAUDE.md` exists, move shared content to sibling `AGENTS.md`, then replace it with the adapter. Use `git mv` for tracked files when possible.
- Leave a conformant pair unchanged.
- For a pair with non-identical or ambiguously shared content, obtain one merge-policy decision before mutation.
- For a mixed repository layout without an explicit policy, report each directory class and obtain one normalization-policy decision.
- If no Agent instruction files exist, propose root `AGENTS.md` plus the adapter without asking the user to choose a filename.

The adapter is:

```markdown
@AGENTS.md
```

The root AND section is:

```markdown
## AI-native development

This repository uses the AND delivery loop.

- Use GitHub Issues, labels, native relationships, comments, and assignees as workflow state.
- Use `ask-andie` when the next workflow skill is unclear.
- Use the installed `ai-native-development` skills and `and-workflow-contract` for workflow rules.
```

## Environment Readiness

Check `and-workflow-contract`, `and-interview-contract`, `grilling`, `research`, `prototype`, `tdd`, and `code-review` from the session skill list or documented skill-list command. Report `unverified` when neither establishes availability.

Missing skills do not authorize installation. When installation is requested, use the owning repository and known Agent targets:

```bash
npx --yes skills add Andiedie/skills -g --skill and-workflow-contract and-interview-contract --agent <known-target...>
npx --yes skills add mattpocock/skills -g --skill <missing-matt-skill...> --agent <known-target...>
```

When targets are unknown, omit `--agent` for interactive selection. Keep skills from different repositories in separate commands.

## Report Shape

After a successful apply, report:

```markdown
Repository setup: conformant
Workflow state: GitHub ready
Changed: <files and GitHub actions, or none>
Environment readiness: <ready | missing or unverified skills>
Full readiness: <ready | incomplete, only when requested>
Next: <one AND workflow skill>
```

Before writes, list the target repository, exact file actions, exact GitHub actions, environment readiness, and any blocker. Omit empty groups and passed-condition inventories from the default report.

## Boundaries

- Setup writes only approved minimum GitHub state, Agent instruction integration, repository-specific setup facts, and explicitly authorized skill installation.
- Existing work records, product requirements, implementation artifacts, and workflow meaning remain unchanged.
- Delivery-loop stage work begins only after repository setup is conformant; setup returns one next-skill route without claiming, implementing, closing, merging, or releasing delivery work.
