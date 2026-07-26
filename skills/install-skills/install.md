# Install Operation

## Install Contract

- Use the exact install commands in this workflow for default installs.
- Do not infer filesystem paths from `--agent` flag names.
- Do not use `--agent '*'`, `--all`, or all-agent installation unless the user explicitly names the extra agent targets.
- Do not use `--copy`.
- Global installs use `~/.agents/skills` as the canonical store and `~/.claude/skills` as the Claude Code symlink target.
- Project installs create project-local agent paths under `.agents/skills` and `.claude/skills`; treat project `.claude/skills` entries as copied directories unless the filesystem proves they are symlinks.
- If a source exposes multiple skills and the user did not name the exact skill or skills, list the available skills with their purpose and ask the user to choose.

## Install Workflow

### 1. Resolve Scope

Decide whether the install is global or project-local.

- Global means user-level skills.
- Project means skills in the current repository.

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
