---
name: documentation-reseed
description: One-off repository documentation reseed for backing up existing docs, configuring agent discoverability, rebuilding Agent-first docs from old docs and current code, and pruning stale documentation.
---

# Documentation Reseed

Use this when a repository needs a full documentation reset, not routine documentation maintenance.

## Principle

Treat old documentation as evidence, not truth. Current code, local rules, and verified runtime behavior are the source of truth. Preserve only durable context that future agents cannot safely recover from code alone.

## Required Skills

- Use `documentation-maintenance` for the write/delete/keep rules.
- Use `setup-matt-pocock-skills` only when the repo has not yet configured issue tracker, triage labels, and domain docs.

If either skill is unavailable, continue with the same principles and note the gap in the final report.

## Steps

### 1. Preflight

Read local entry points before touching files:

- `AGENTS.md` or `CLAUDE.md`
- `README.md`
- `CONTEXT.md` or `CONTEXT-MAP.md`
- `docs/agents/documentation.md`
- Existing `docs/` indexes

Run `git status --short`.

Completion criterion: current doc entry points, local documentation rules, and dirty worktree state are known.

### 2. Backup

Inventory documentation-like files before moving anything. Separate ordinary docs from product/code-layer content.

Move ordinary docs to the chosen backup directory while preserving paths. Do not move files whose documentation format is part of product behavior, source code, tests, fixtures, or agent/skill discovery unless the user explicitly asks.

Completion criterion: backup exists, moved paths are preserved, exclusions are intentional, and no unreviewed documentation-like file was silently ignored.

### 3. Agent Discoverability

Make the documentation system discoverable from the repo entry point.

- Keep `AGENTS.md` / `CLAUDE.md` short; use it as a router.
- Point documentation work to `docs/agents/documentation.md` when present.
- Point domain language to `CONTEXT.md` or `CONTEXT-MAP.md`.
- Point high-risk operations to their topic docs rather than duplicating runbooks.

If issue tracker, triage labels, or domain doc layout are missing and the user wants Matt Pocock engineering skills, run `setup-matt-pocock-skills` before rebuilding docs.

Completion criterion: a future agent can discover where documentation rules, domain language, and high-risk source-of-truth docs live.

### 4. Harvest

Read old docs from backup and inspect current code for each topic. Classify each meaningful fact:

- current
- stale
- duplicate
- historical
- uncertain

Do not copy old prose because it sounds useful. Verify it against code, scripts, config, tests, or current local rules.

Completion criterion: every old doc with potential unique value has been checked or explicitly rejected.

### 5. Rebuild

Update the nearest source of truth instead of creating duplicates.

Prefer these sections when useful:

- `Purpose`
- `Read when`
- `Source of truth`
- `Invariants`
- `Procedure`
- `Verification`
- `Update when`

Write docs for context, constraints, risks, and operation paths. Do not restate code, obvious file lists, or temporary plans. Delete stale docs rather than preserving misleading material.

Completion criterion: the new docs explain what code cannot easily express, and each durable fact has one home.

### 6. Validate

Run checks appropriate to the repo:

- Search for references to deleted docs.
- Check Markdown links.
- Run `git diff --check`.
- Run any docs/skill validators available in the repo.

Completion criterion: no known broken links, stale entry points, or whitespace errors remain.

### 7. Report

Summarize:

- what was backed up
- what was deleted
- what was rebuilt
- what was intentionally not documented
- what remains uncertain
- which validation commands ran

If docs changed, use the final-response shape required by `documentation-maintenance`.
