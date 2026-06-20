---
name: normalize-agent-instructions
description: Normalize AGENTS.md/CLAUDE.md project instruction files. Use when the user asks to standardize AGENTS.md and CLAUDE.md or migrate Claude guidance to AGENTS.md.
---

# Normalize Agent Instructions

Use this to make `AGENTS.md` the shared source of truth and `CLAUDE.md` the Claude Code adapter.

## Policy

- `AGENTS.md` holds cross-agent instructions.
- `CLAUDE.md` imports the sibling `AGENTS.md` with `@AGENTS.md`, then may append Claude Code-specific rules.
- Do not duplicate shared instructions between the two files.
- Do not merge or discard two non-identical instruction files without a user decision.

## Workflow

### 1. Scan

Find every `AGENTS.md` and `CLAUDE.md` in the current project, excluding dependency, generated, and VCS directories.

Suggested command:

```bash
rg --files --hidden \
  -g 'AGENTS.md' \
  -g 'CLAUDE.md' \
  -g '!**/.git/**' \
  -g '!**/node_modules/**' \
  -g '!**/dist/**' \
  -g '!**/build/**' \
  -g '!**/.next/**' \
  -g '!**/coverage/**'
```

Classify the result by directory:

- `agents-only`: has `AGENTS.md` but no sibling `CLAUDE.md`
- `claude-only`: has `CLAUDE.md` but no sibling `AGENTS.md`
- `paired`: has both sibling files
- `none`: no matching files

Completion criterion: every discovered instruction file belongs to exactly one directory classification, and symlinks are identified before editing.

### 2. Handle AGENTS-Only Projects

If every discovered instruction file is an `AGENTS.md`, add a sibling `CLAUDE.md` beside each one:

```md
@AGENTS.md
```

Do not rewrite the existing `AGENTS.md` files.

Completion criterion: every `AGENTS.md` has a sibling `CLAUDE.md` that imports it, and no shared instructions were duplicated.

### 3. Handle Claude-Only Projects

If every discovered instruction file is a `CLAUDE.md`, rename each file to sibling `AGENTS.md`, preserving its content. Then create a new sibling `CLAUDE.md`:

```md
@AGENTS.md
```

Use `git mv` for tracked files when possible. If a `CLAUDE.md` is already a symlink to an `AGENTS.md`, record it as already normalized instead of replacing it.

Completion criterion: every former `CLAUDE.md` content now lives in `AGENTS.md`, and every `CLAUDE.md` imports the sibling `AGENTS.md`.

### 4. Handle Paired Projects

If every discovered instruction directory has both files, inspect each `CLAUDE.md`.

- If each `CLAUDE.md` imports `@AGENTS.md` and contains no shared instructions beyond optional Claude Code-specific rules, report that the project is already normalized.
- If any `CLAUDE.md` contains distinct shared instructions, stop before editing. Report those files, state the best practice, and ask the user how they want the content merged.

Completion criterion: paired projects are either confirmed normalized or blocked on an explicit merge decision.

### 5. Handle Mixed Projects

If the project has any mix of `agents-only`, `claude-only`, and `paired` directories, stop before editing unless the user already gave an explicit policy for the mixed case.

Report:

- directories with only `AGENTS.md`
- directories with only `CLAUDE.md`
- directories with both files
- paired files where `CLAUDE.md` does not import `@AGENTS.md` or appears to contain shared instructions

State the best practice plainly: make `AGENTS.md` canonical, make `CLAUDE.md` import it, and manually decide how to merge any paired files with distinct content.

Ask the user what policy they want for this repository.

Completion criterion: no mixed-project edits happen without an explicit user decision, and the user sees both the current state and the recommended normalization path.

### 6. Handle Projects With No Files

If the scan finds no `AGENTS.md` or `CLAUDE.md`, report that there is nothing to normalize. Recommend creating a root `AGENTS.md` plus a root `CLAUDE.md` adapter, but ask before creating either file.

Completion criterion: the user knows no instruction files exist and has a clear recommended starting point.

### 7. Verify

After edits, rerun the scan and inspect each changed `CLAUDE.md`.

Run:

```bash
git diff --check
```

Report changed files, unresolved mixed-case decisions, and any verification commands that could not run.

Completion criterion: the final state matches the selected policy, every adapter imports `@AGENTS.md`, and whitespace checks pass or failures are reported.
