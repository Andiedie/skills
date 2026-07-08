---
name: documentation-reseed
description: One-off documentation reseed for clearing old doc structure into a dated backup, rebuilding agent-first sources of truth from verified repo facts and old-doc evidence, and pruning stale docs. Use for full repository docs resets, not routine documentation maintenance.
---

# Documentation Reseed

Use this when a repository needs a full documentation reset. For routine updates, use `documentation-maintenance`.

## Principle

Reseed the documentation system, not just the files. Old prose and old locations are evidence, not truth. Current code, local rules, generated sources, and verified runtime behavior are the source of truth.

Clear ordinary docs out of the way so the old structure stops shaping the new one. Preserve only durable context that future agents cannot safely recover from code alone.

## Related Skills

- Use `documentation-maintenance` for write/delete/keep rules, source-of-truth choices, docs-as-code handling, semantic rewrite guards, and final-response shape.
- `setup-matt-pocock-skills` is user-invoked. Do not invoke it from this workflow. If setup is needed, stop after the backup and tell the user to run it manually.

If either skill is unavailable, continue with the same principles and note the gap in the final report.

## Reseed Workspace

Default to `.scratch/documentation-reseed/YYYY-MM-DD/`, using the current date. If it already exists, append `-N`.

- `moved-docs/` holds moved ordinary docs, preserving original relative paths.
- `ledger.md` records every documentation-like candidate, original path, category, backup path or exclusion reason, retention status, final destination, and verification source.

Exclude the active reseed workspace from inventory and validation searches. The exceptions are reading `ledger.md` and `moved-docs/` for setup evidence preparation, and reading `moved-docs/` during harvest.

Use a different workspace only when local rules designate one or the user asks for it.

## Steps

### 1. Preflight

Read local documentation conventions before applying this workflow's defaults:

- agent entrypoints such as `AGENTS.md` or `CLAUDE.md`
- README files
- context maps or domain glossaries
- docs indexes and docs-agent rules
- docs-as-code sources, generators, and config

Run `git status --short`.

Treat this skill as the controlling reseed workflow. Treat local documentation rules as repo-specific constraints and evidence. If a local rule conflicts with this workflow, pause and ask the user to choose; do not silently override either one.

If the task is only a local documentation edit, stop using this skill and use `documentation-maintenance`.

Completion criterion: dirty worktree state is known, local documentation rules are known, the task really needs a full reseed, the reseed workspace is selected, and conflicts between local rules and this workflow are resolved by the user.

### 2. Inventory And Clear Deck

Inventory documentation-like files before moving anything. Include Markdown, reStructuredText, AsciiDoc, docs directories, root documentation files, and any files local rules treat as docs.

Classify each candidate in `ledger.md`:

- **ordinary docs:** eligible to move into `moved-docs/`
- **agent discovery:** entrypoints or skill-discovery files that must remain discoverable or be replaced by a minimal router in the same edit
- **docs-as-code source:** schemas, specs, comments, generators, config, or source files that produce docs
- **generated docs:** generated outputs to regenerate from source rather than hand-edit
- **product/runtime docs:** public API specs, package docs, Storybook stories, fixtures, tests, or files whose path or format affects product behavior
- **scratch/plans:** temporary work notes, PRDs, issue breakdowns, and exploration notes

Move eligible ordinary docs to `moved-docs/`, preserving original relative paths. This move is intentional: old locations are evidence, but they should not keep shaping the rebuilt structure.

Do not move product/runtime docs, docs-as-code sources, generated outputs, tests, fixtures, package metadata, or active agent/skill discovery files unless the user explicitly approves. If an agent entrypoint should be reset, write the replacement router in the same change that moves the old file.

Completion criterion: `ledger.md` lists every documentation-like candidate outside the active reseed workspace with category, moved path or exclusion reason, and initial disposition; eligible ordinary docs have been moved with paths preserved; protected exclusions are intentional; and no documentation-like file was silently ignored.

### 3. Manual Matt Pocock Setup Stop

After backup, check whether the cleared repo already has the Matt Pocock setup outputs:

- an `## Agent skills` block in `AGENTS.md` or `CLAUDE.md`
- `docs/agents/issue-tracker.md`
- `docs/agents/triage-labels.md`
- `docs/agents/domain.md`

If any are missing and the user wants Matt Pocock engineering skills, prepare a setup evidence summary before stopping. Read only setup-relevant evidence from the cleared repo, `ledger.md`, and `moved-docs/`: prior or current Agent skills blocks, context layout files, ADR locations, `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md`, and `.scratch/` issue-tracker clues.

Treat the cleared repo as the target baseline. Treat backed-up setup files as evidence for the setup evidence summary, not authority to restore old structure. Do not inspect live issue tracker labels, choose label vocabulary, restore old setup docs, or reproduce that skill's product-governance questions here.

Stop and tell the user to manually run `setup-matt-pocock-skills`, passing the setup evidence summary, then resume this reseed.

Completion criterion: setup outputs exist, the user confirms setup was manually completed with cleared-repo baseline and backup evidence considered, or the final report records why setup was skipped.

### 4. Rebuild Discoverability

Make the rebuilt documentation system discoverable from the repo entry point. Follow local conventions first; use these defaults only when no stronger convention exists.

- Keep the agent entrypoint short; use it as a router.
- Point documentation work to the repo's documentation rules.
- Point domain language to the repo's context map or domain glossary.
- Point high-risk operations to their source-of-truth topic docs rather than duplicating runbooks.
- Do not recreate old directories by default; each rebuilt destination must earn its place through a stable reader and update trigger.

Completion criterion: a future agent can discover where documentation rules, domain language, and high-risk source-of-truth docs live without relying on the moved old structure.

### 5. Harvest And Rebuild

Read old docs from `moved-docs/` and inspect current code for each topic. Keep `ledger.md` current as the retention ledger. Classify each meaningful fact:

- current
- stale
- duplicate
- historical
- uncertain

Do not copy old prose because it sounds useful. Verify facts against code, scripts, config, tests, generated sources, runtime behavior, or current local rules.

Apply `documentation-maintenance` for source-of-truth choices, document structure, docs-as-code handling, and semantic rewrite guards. Do not restate its full rule set here.

For high-context rewrites such as legacy design docs, ADRs, runbooks, README overhauls, and domain context, run a semantic parity check against `moved-docs/`. Do not compress away constraints that future agents cannot recover from code, tests, schemas, design tokens, generated artifacts, or config.

Completion criterion: every moved doc with potential unique value has been checked; every meaningful fact has a final disposition; durable facts have one source of truth; stale facts are not reintroduced; and uncertain facts are surfaced rather than hidden.

### 6. Prune And Validate

Run checks appropriate to the repo:

- Search for references to moved or deleted old paths, excluding the active reseed workspace.
- Check Markdown links.
- Run `git diff --check`.
- Regenerate docs-as-code outputs when applicable.
- Run any docs/skill validators available in the repo.

Remove empty old directories and stale entry points after replacements are discoverable.

Completion criterion: no known broken links, stale entry points, obsolete old-path references, unregenerated docs-as-code outputs, or whitespace errors remain.

### 7. Report

Summarize:

- reseed workspace path
- what was moved to backup
- what was kept in place or excluded, and why
- what was rebuilt
- what was intentionally not documented
- what remains uncertain
- Matt Pocock setup status
- which validation commands ran

If docs changed, use the final-response shape required by `documentation-maintenance`.
