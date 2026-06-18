---
name: install-skills
description: Install Agent Skills with npx skills. Use when the user asks to install, add, update, or manage skills from a GitHub repo, well-known skill URL, or skills package, especially when scope, skill selection, symlink layout, or npx skills flags matter.
---

# Install Skills

Use this for installing Agent Skills through `npx skills`.

## Install Contract

- Ask for scope when the user did not specify `global` or `project`.
- Default agent targets are `codex` and `claude-code` only.
- Do not use `--agent '*'`, `--all`, or all-agent installation unless the user explicitly names the extra agent targets.
- Do not use `--copy`.
- Use symlink mode: `.agents/skills` is the canonical store, and `.claude/skills` is a symlink target for Claude Code.
- If a source exposes multiple skills and the user did not name the exact skill or skills, list the available skills with their purpose and ask the user to choose.

## Workflow

### 1. Resolve Scope

Decide whether the install is global or project-local.

- Global means user-level skills.
- Project means skills in the current repository.

If the user did not specify the scope, ask one direct question before installing.

Completion criterion: the target scope is explicitly known.

### 2. Discover Skills

Run a non-installing listing before installing from a source that may contain multiple skills:

```bash
npx --yes skills add <source> --list
```

If the source contains more than one skill and the user did not already name the exact skill or skills, summarize each skill's purpose from the listing or its `SKILL.md`, then ask the user which to install.

Install every skill only when the user explicitly asks for every skill in that source.

Completion criterion: the install set is explicit and contains only the selected skills.

### 3. Install

Use `codex` and `claude-code` as the default agent targets. This keeps the canonical copy in `.agents/skills` and creates Claude Code symlinks in `.claude/skills`.

Global install:

```bash
npx --yes skills add <source> -g --agent codex claude-code --skill <skill...> -y
```

Project install:

```bash
npx --yes skills add <source> --agent codex claude-code --skill <skill...> -y
```

If the local npm cache is broken, rerun the same command with a temporary cache:

```bash
NPM_CONFIG_CACHE=/private/tmp/skills-npx-cache npx --yes skills add <source> ...
```

Clean that temporary cache after the install succeeds.

Completion criterion: the command output shows `.agents/skills/<skill>` as `universal` and Claude Code as `symlinked`.

### 4. Verify

Verify the installed state.

For global installs:

```bash
npx --yes skills list -g --json
```

For project installs:

```bash
npx --yes skills list --json
```

Check that:

- The canonical skill directory exists under `.agents/skills/<skill>`.
- The Claude Code path `.claude/skills/<skill>` is a symlink.
- The symlink resolves to the matching `.agents/skills/<skill>` directory.
- The relevant lock file contains matching entries for the selected skills.
- If unrelated existing lock entries or pre-existing mismatches are present, do not remove or rewrite them for this install; describe the situation and recommend the smallest follow-up action.

Completion criterion: the selected skills agree across real directories, Claude Code symlinks, `npx skills list`, and lock entries; any unrelated or pre-existing lock mismatches are reported with a recommended next action.
