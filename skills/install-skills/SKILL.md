---
name: install-skills
description: Install and update Agent Skills with npx skills. Use when the user asks to install, add, update, upgrade, refresh, or check skills from a GitHub repo, well-known skill URL, skills package, global scope, project scope, or all npx-managed skill scopes.
---

# Install And Update Skills

Use this for installing and updating Agent Skills through `npx skills`.

## Common Contract

- Ask for scope when the user did not specify `global` or `project`.
- Preserve unrelated local skill files and lock mismatches. Report them instead of rewriting around them.

## Install Contract

- Use the exact install commands in this workflow for default installs.
- Do not infer filesystem paths from `--agent` flag names.
- Do not use `--agent '*'`, `--all`, or all-agent installation unless the user explicitly names the extra agent targets.
- Do not use `--copy`.
- Global installs use `~/.agents/skills` as the canonical store and `~/.claude/skills` as the Claude Code symlink target.
- Project installs create project-local agent paths under `.agents/skills` and `.claude/skills`; treat project `.claude/skills` entries as copied directories unless the filesystem proves they are symlinks.
- If a source exposes multiple skills and the user did not name the exact skill or skills, list the available skills with their purpose and ask the user to choose.

## Update Contract

- Treat `npx skills update` as mutating. For check-only requests, explain that the CLI has no dry-run update check, inventory the update candidates, and ask before running an update.
- Use `npx --yes skills --help` for command help. Do not probe `npx skills update --help`; current CLI behavior can run the update flow.
- Visible means `npx skills list` reports the skill.
- Lock-tracked means the skill has an entry in a `skills` lock file: global `~/.agents/.skill-lock.json`, or project-local `skills-lock.json` in the repository root.
- Updateable means lock-tracked with the metadata `npx skills update` needs to refresh it.
- For project locks, update candidates have `skillPath` and are not `sourceType: local` or `sourceType: node_modules`.
- For global locks, update candidates have both `skillPath` and `skillFolderHash`; entries missing either field are lock-tracked but not automatically checkable by the CLI.
- Do not treat visible-only skills, local-source lock entries, node_modules lock entries, or lock entries missing required update metadata as update targets.

## Install Workflow

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

Run the default install commands below. Global installs use one command; project installs use one command per project agent path.

Global install:

```bash
npx --yes skills add <source> -g --agent codex claude-code --skill <skill...> -y
```

Project install:

```bash
npx --yes skills add <source> --agent codex --skill <skill...> -y
npx --yes skills add <source> --agent claude-code --skill <skill...> -y
```

If the local npm cache is broken, rerun the same command with a temporary cache:

```bash
NPM_CONFIG_CACHE=/private/tmp/skills-npx-cache npx --yes skills add <source> ...
```

Clean that temporary cache after the install succeeds.

Completion criterion: the command output shows the requested global or project agent paths installed.

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

- For global installs, `~/.agents/skills/<skill>` exists and `~/.claude/skills/<skill>` is a symlink that resolves to it.
- For project installs, `./.agents/skills/<skill>` and `./.claude/skills/<skill>` both exist; do not require the project Claude Code path to be a symlink.
- If the CLI wrote a lock entry, it matches the selected skill and source.
- If the CLI did not write a lock entry, report the installed skill as visible-only and not updateable by `npx skills update`; do not fail the install solely because the lock entry is absent.
- If unrelated existing lock entries or pre-existing mismatches are present, do not remove or rewrite them for this install; describe the situation and recommend the smallest follow-up action.

Completion criterion: the selected skills agree across expected real directories, `npx skills list`, and any lock entries the CLI wrote; absent lock entries are classified for update purposes, and unrelated or pre-existing lock mismatches are reported with a recommended next action.

## Update Workflow

### 1. Inventory

Find the lock-tracked skills, their source types, update metadata, and the currently visible skills.

Global:

```bash
if test -f ~/.agents/.skill-lock.json; then jq -r '.skills | to_entries[] | [.key, (.value.sourceType // "unknown"), (.value.source // ""), (.value.skillPath // ""), (.value.skillFolderHash // "")] | @tsv' ~/.agents/.skill-lock.json; fi
npx --yes skills list -g --json
```

Project:

```bash
if test -f skills-lock.json; then jq -r '.skills | to_entries[] | [.key, (.value.sourceType // "unknown"), (.value.source // ""), (.value.skillPath // ""), (.value.computedHash // "")] | @tsv' skills-lock.json; fi
npx --yes skills list --json
```

If `jq` is unavailable, parse the JSON with another structured parser.

Completion criterion: each requested scope is classified into updateable, lock-tracked but not updateable, visible-only, or absent.

### 2. Resolve Target

Choose the smallest target that matches the request.

- Global or user-level means global.
- Project, repo, or this repository means project-local.
- All, every, or all npx-managed skills means every updateable skill in both global and project-local lock scopes.
- Named skills mean only those skills within the requested scope; if a named skill is visible-only or lock-tracked but not updateable, report it instead of updating it.

If the scope is still ambiguous, ask one direct question before updating.

Completion criterion: target scopes and updateable skill names are explicit, and no visible-only or non-updateable skill is silently treated as updated.

### 3. Update

Run one explicit command per target scope. If a target scope has no updateable skills, do not run an update command for that scope; report the inventory classification instead.

Global all:

```bash
npx --yes skills update -g
```

Project all:

```bash
npx --yes skills update -p
```

Global selected:

```bash
npx --yes skills update <skill...> -g
```

Project selected:

```bash
npx --yes skills update <skill...> -p
```

If the local npm cache is broken, rerun the same command with a temporary cache:

```bash
NPM_CONFIG_CACHE=/private/tmp/skills-npx-cache npx --yes skills update ...
```

Clean that temporary cache after the update succeeds.

Completion criterion: every target scope either completed or failed with captured output, including the updated count or the no-update result.

### 4. Verify

Verify the post-update state.

For global updates:

```bash
npx --yes skills list -g --json
```

For project updates:

```bash
npx --yes skills list --json
```

Check that:

- The relevant lock file still parses.
- Every updateable target skill still has a lock entry.
- Every updateable target skill appears in the relevant `npx skills list` output, unless the pre-update inventory already showed it as lock-tracked but not visible.
- Every CLI-reported updated skill is accounted for in the final response.
- Visible skills without lock entries are reported as outside this update workflow.
- Local-source, node_modules, and metadata-incomplete lock entries are reported as skipped, not updated.

Completion criterion: the update output, lock entries, and list output agree for every updateable target skill, and any non-updateable, visible-only, or failed items are named with the smallest recommended follow-up.
