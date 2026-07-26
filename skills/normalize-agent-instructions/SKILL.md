---
name: normalize-agent-instructions
description: Normalize AGENTS.md/CLAUDE.md project instruction files. Use when the user asks to standardize AGENTS.md and CLAUDE.md or migrate Claude guidance to AGENTS.md.
---

# Normalize Agent Instructions

Use this to make `AGENTS.md` the only instruction source and `CLAUDE.md` its adapter.

## Policy

- `AGENTS.md` holds all instructions.
- A regular `CLAUDE.md` is a pure adapter whose canonical bytes are `@AGENTS.md\n`. It holds no additional instructions.
- A `CLAUDE.md` symlink is normalized only when it directly and relatively targets a regular sibling `AGENTS.md`.
- Never infer ownership of extra content or automatically merge, delete, overwrite, or deduplicate instructions.
- Obey effective higher-priority local rules. An incompatible rule is an authority blocker, not a preference the user can bypass here.

## Workflow

### 1. Scan The Complete Project

Find every `AGENTS.md` and `CLAUDE.md` in the current project, excluding dependency, generated, and VCS directories.

Use filename search as a discovery seed:

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

Supplement that seed with a non-following directory-entry scan for the two exact names so symlinks and special objects omitted by `rg` are still discovered. Do not infer that a path is absent merely because `rg` omitted it. For every discovered directory and exact instruction path, inspect the path object without following symlinks:

- record whether `AGENTS.md` and `CLAUDE.md` are absent, regular files, directories, symlinks, or other objects;
- record each symlink's literal target and whether the immediate sibling target is a regular file;
- record whether regular files are readable, writable when an in-place rewrite is possible, and tracked;
- record the action-specific write premises without mutating the project: each containing directory that may receive a create, rewrite, or rename is searchable and writable; each rename source is readable and movable; each destination is absent and creatable; and, for a tracked source, the repository worktree and index allow the planned `git mv`; and
- read effective local instructions that constrain either file.

Classify regular-file layouts by directory:

- `agents-only`: regular `AGENTS.md`, absent sibling `CLAUDE.md`;
- `claude-only`: regular `CLAUDE.md`, truly absent sibling `AGENTS.md`;
- `paired`: regular sibling `AGENTS.md` and `CLAUDE.md`, or regular `AGENTS.md` plus a candidate `CLAUDE.md` symlink;
- `none`: no instruction path object anywhere in scope.

A regular sibling `AGENTS.md` always makes the directory `paired`; never treat its `CLAUDE.md` as a rename source. Any `AGENTS.md` symlink or special object is a hard blocker. A `CLAUDE.md` directory or other non-regular, non-symlink object is a hard blocker. A `CLAUDE.md` symlink is valid only when its literal relative target is `AGENTS.md` or `./AGENTS.md` and that sibling is a regular file. Cross-directory and absolute symlinks, and chained, cyclic, and dangling symlinks, are hard blockers. Any unreadable instruction object is also a hard blocker.

Completion criterion: every instruction path has an observed object type, every directory has one layout classification or exact hard blocker, and no write has occurred.

### 2. Plan Every Directory Before Writing

Resolve each instruction directory independently:

- `agents-only`: plan to preserve `AGENTS.md` and add a sibling `CLAUDE.md` adapter.
- `claude-only`: when the sibling target is proven absent, plan to preserve the content by moving `CLAUDE.md` to `AGENTS.md`, then add the pure adapter. Prefer `git mv` when the source is tracked.
- `claude-only` whose `CLAUDE.md` already imports missing `@AGENTS.md`: record a hard blocker instead of moving an adapter into its own source.
- `paired` with regular files: a `CLAUDE.md` containing only `@AGENTS.md` plus harmless surrounding whitespace is deterministic; plan a canonical rewrite only when its bytes differ. Any additional non-whitespace content is a real conflict.
- `paired` with a direct relative `CLAUDE.md` symlink to the regular sibling `AGENTS.md`: treat the directory as normalized and plan a no-op.

Mixed layout is not a conflict. A project may contain any combination of directory states when each directory has a deterministic result.

Build one complete plan that lists the deterministic action, real conflict, authority blocker, or hard blocker for every directory. Do not edit any instruction file during scanning or planning. Never overwrite or deduplicate an occupied target, even when its text appears identical.

Use action-appropriate, non-mutating checks to prove each write premise. For a tracked migration, require the exact `git mv --dry-run -- <source> <destination>` to be applicable and establish that the Git index can be updated; do not silently fall back to an untracked filesystem move. If any required write premise cannot be established—including parent-directory searchability or writability, source readability or movability, destination absence or creatability, regular-file writability, or tracked `git mv` and index applicability—record an insufficient write premise as a hard blocker for that directory.

Completion criterion: every directory has exactly one planned outcome, every planned action has proven write premises, and every unresolved outcome names its concrete evidence.

### 3. Stop or Apply Once

If any directory has a real conflict, authority blocker, or hard blocker:

- write nothing anywhere in the project;
- for real content conflicts, report only the conflicting directories, their concrete differences, valid preservation options, and a recommendation;
- for authority or hard blockers, report the exact blocking rule or path state and the condition that would make a fresh run safe; do not offer an overwrite, forced replacement, or authority bypass;
- retain the deterministic plan for every unaffected directory; and
- ask only about the blocked directories instead of requesting a mixed-project policy.

After every conflict is resolved, run a fresh complete scan and rebuild the plan. When no blocker exists, proceed without asking merely because directory layouts differ.

Completion criterion: either the project remains unchanged with precise conflict questions, or one complete conflict-free plan is ready to apply.

### 4. Handle Projects With No Files

If the scan finds no `AGENTS.md` or `CLAUDE.md`, report that there is nothing to normalize. Recommend creating a root `AGENTS.md` plus a root `CLAUDE.md` adapter, but ask before creating either file. Stop until the user confirms; after confirmation, add the root pair to a fresh complete plan before writing.

Completion criterion: the user knows no instruction files exist and has a clear recommended starting point.

### 5. Apply The Plan

Revalidate every planned path type, file fingerprint, symlink target, local rule, destination, and action-specific write premise immediately before the first write. This includes containing-directory searchability and writability, rewrite-target writability, rename-source readability and movability, destination absence and creatability, and tracked `git mv` and index applicability. If any state drifted or a write premise is no longer provable, write nothing and report the changed premise as a hard blocker.

For each planned change:

- preserve every existing `AGENTS.md`;
- move `claude-only` content to sibling `AGENTS.md`, using `git mv` for tracked files when possible; and
- create or normalize the sibling regular `CLAUDE.md` as the pure adapter:

```md
@AGENTS.md
```

If an unexpected write fails after mutation begins, stop immediately. Report the exact changed and unresolved paths; do not attempt a broad rollback that could overwrite concurrent user changes, and do not claim transactional success.

Completion criterion: every planned directory change is applied without merging, discarding, duplicating, or silently overwriting instructions.

### 6. Verify

After edits, rerun the complete path-object scan. Confirm that every instruction directory has a regular `AGENTS.md` plus either:

- a regular `CLAUDE.md` with canonical bytes `@AGENTS.md\n`; or
- an accepted direct relative `CLAUDE.md` symlink to the regular sibling `AGENTS.md`.

Run:

```bash
git diff --check
```

Report changed files, unresolved directories, and any verification commands that could not run.

Completion criterion: every directory is normalized, a second run is a zero-write no-op, whitespace checks pass, and no success is reported while a directory or verification step remains unresolved.
