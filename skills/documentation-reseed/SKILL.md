---
name: documentation-reseed
description: One-off documentation reseed for clearing old doc structure into a dated backup, rebuilding agent-first sources of truth from verified repo facts and old-doc evidence, and pruning stale docs. Use for full repository docs resets, not routine documentation maintenance.
---

# Documentation Reseed

Use this when a repository needs a full documentation reset. For routine updates, use `documentation-maintenance`.

## Principle

Reseed the documentation system, not just the files. Old prose and old locations are evidence, not truth. Current code, local rules, generated sources, and verified runtime behavior are the source of truth.

Clear ordinary docs out of the way so the old structure stops shaping the new one. Preserve only durable context that future agents cannot safely recover from code alone.

## Instruction Authority

Use the effective instructions for the current host and task before applying this Skill's defaults or deciding whether to ask a question. Consume the host's resolved instruction set; do not recreate a universal system, developer, user, repository, or Skill precedence table here.

Resolve each relevant rule interaction once:

- Follow an effective rule that constrains a Skill default without asking the user to choose again.
- Compose compatible effective requirements with the reseed workflow.
- Ask one focused question only when an applicable peer-rule conflict, human-owned product or scope decision, or execution premise remains unresolved.
- When an effective constraint conflicts with a required reseed invariant, stop before the conflicting mutation. Report the exact constraint, invariant, and last safe state, and name only options that would require separate authorization, such as changing scope or invoking `documentation-maintenance`.

An explicit user direction changes behavior only when the host treats it as part of the effective instructions. A question cannot create authority to bypass an instruction that remains binding. Required reseed invariants include an owned backup, protected discovery, complete ledger accounting, the clean-deck pause, explicit continuation, safe resume, semantic parity, and final validation.

Apply this same authority rule during initial preflight and whenever continuation re-reads local rules. Keep the normative rule here rather than duplicating a second conflict algorithm in either path.

## Related Skills

- Use `documentation-maintenance` for write/delete/keep rules, source-of-truth choices, docs-as-code handling, semantic rewrite guards, and final-response shape.

If `documentation-maintenance` is unavailable, continue with the same principles and note the gap in the final report.

## Reseed Workspace

For a new run, default to `.scratch/documentation-reseed/YYYY-MM-DD/`, using the current date. Before creating it, inspect existing reseed workspaces. An incomplete workspace has status `active` or `awaiting-continuation`. Use the workspace the user identifies; when the request is to continue an existing reseed and exactly one incomplete workspace exists, use it. Ask when multiple incomplete workspaces exist or when starting new versus resuming is unclear. Append `-N` only for a genuinely new run.

- `moved-docs/` holds moved ordinary docs, preserving original relative paths.
- `ledger.md` records the reseed status, the next numbered step to execute, and every documentation-like candidate's original path, category, backup path or exclusion reason, retention status, final destination, verification source, and checkpoint fingerprint when applicable. Set the next step to `1` when creating a workspace and advance it only after the current step's completion criterion is met.

The status has three values:

- `active`: set when a workspace is created or a paused run has a verified resume baseline. Resume at the recorded next step and use candidate dispositions instead of repeating completed moves.
- `awaiting-continuation`: set only at the clean-deck checkpoint. Resume through Step 3 after explicit user continuation.
- `complete`: set after validation and the Step 7 report summary are recorded, immediately before delivering that report. Completed workspaces are evidence, not resume targets.

Exclude the active reseed workspace from inventory and validation searches. Read `ledger.md` to resolve and resume the run, and read `moved-docs/` during harvest.

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

Apply **Instruction Authority** to the discovered rules before using a default or changing the repository. This Skill controls the reseed mechanics that the effective instructions leave open. If a required reseed invariant is blocked, leave the repository untouched by reseed and report the blocker; do not silently switch to a narrower task.

If the task is only a local documentation edit, stop using this skill and use `documentation-maintenance`.

Completion criterion: dirty worktree state is known, local documentation rules have been resolved through **Instruction Authority**, the task really needs a full reseed, the reseed workspace is selected, and every required invariant can proceed under the effective instructions. A blocker ends preflight before reseed mutation with the exact constraint, invariant, last safe state, and separately authorized options reported.

### 2. Inventory And Clear Deck

Inventory documentation-like files before moving anything. Include Markdown, reStructuredText, AsciiDoc, docs directories, root documentation files, and any files local rules treat as docs.

Classify each candidate in `ledger.md`:

- **ordinary docs:** eligible to move into `moved-docs/`
- **agent discovery:** entrypoints or skill-discovery files that must remain discoverable or be replaced by a minimal router in the same edit
- **docs-as-code source:** schemas, specs, comments, generators, config, or source files that produce docs
- **generated docs:** generated outputs to regenerate from source rather than hand-edit
- **product/runtime docs:** public API specs, package docs, Storybook stories, fixtures, tests, or files whose path or format affects product behavior
- **scratch/plans:** temporary work notes, PRDs, issue breakdowns, and exploration notes

Classify documentation by its current function, not by which workflow or setup created it.

Move eligible ordinary docs to `moved-docs/`, preserving original relative paths. This move is intentional: old locations are evidence, but they should not keep shaping the rebuilt structure.

Do not move product/runtime docs, docs-as-code sources, generated outputs, tests, fixtures, package metadata, or active agent/skill discovery files unless the user explicitly approves. If an agent entrypoint should be reset, write the replacement router in the same change that moves the old file.

Completion criterion: `ledger.md` lists every documentation-like candidate outside the active reseed workspace with category, moved path or exclusion reason, and initial disposition; eligible ordinary docs have been moved with paths preserved; protected exclusions are intentional; and no documentation-like file was silently ignored.

### 3. Pause At The Clean Deck

After inventory and backup, verify that eligible ordinary docs have moved, protected discovery remains available or has an approved replacement, and `ledger.md` accounts for every candidate. Run `git status --short --untracked-files=all` and record the snapshot. Add a checkpoint fingerprint that records path state and a content hash when content exists for:

- every file under `moved-docs/`;
- every documentation-like or protected discovery file left in place;
- every path already present in the `git status` snapshot outside the active reseed workspace.

Keep the next step at `3`, set the reseed status to `awaiting-continuation`, and stop.

Report a short checkpoint receipt with:

- the active reseed workspace;
- a summary of moved docs;
- protected or excluded docs and why they remain;
- the current working-tree state;
- how to continue the same reseed.

The user may inspect the clean deck, run setup, make another intentional change, or continue immediately. Keep the receipt neutral unless the user already named an intervening operation. Rebuild, harvest, pruning, and final validation begin only after explicit continuation.

On continuation, reopen the same workspace and compare current paths, hashes, and `git status` with the checkpoint fingerprint. Re-read local documentation rules, agent entrypoints, and docs indexes. Reapply **Instruction Authority** before any delta disposition advances the run. A changed local-rule file still receives one of the existing delta dispositions based on its role in the repository; that disposition does not change the rule's authority.

Give every post-checkpoint delta one disposition in `ledger.md`:

- **baseline:** the user named the intervening operation or confirms the output belongs in the rebuilt documentation system;
- **unrelated:** preserve it without treating it as reseed input;
- **ambiguous:** keep status `awaiting-continuation`, report the exact delta, and ask one focused question before continuing.

New or changed baseline files remain in place instead of moving into `moved-docs/`. Set the reseed status back to `active` and the next step to `4` only after every delta has a non-ambiguous disposition and the effective instructions permit every remaining reseed invariant, then continue without another confirmation.

If an effective constraint blocks a remaining invariant, preserve the same workspace and checkpoint fingerprint, keep the status `awaiting-continuation` and the next step at `3`, and report the exact blocker and separately authorized options. Do not repeat or reverse completed move or backup work, set the run to `active`, advance Step 4, or silently switch to a narrower task.

Completion criterion: the run is durably paused with a complete checkpoint receipt; the user has explicitly continued and the same workspace records a disposition for every post-checkpoint delta with no ambiguity or authority blocker remaining; or a resumed run remains safely at the checkpoint with its blocker and last safe state reported.

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
- what changed during the clean-deck pause and how it was treated, when applicable
- what was rebuilt
- what was intentionally not documented
- what remains uncertain
- which validation commands ran

If docs changed, use the final-response shape required by `documentation-maintenance`.

Record the prepared report summary in `ledger.md`, set the reseed status `complete`, then deliver the same report.

Completion criterion: `ledger.md` contains the final report summary and status `complete`, and the user receives the same report.
