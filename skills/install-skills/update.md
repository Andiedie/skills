# Update Operation

## Update Contract

- Treat `npx skills update` as mutating. For check-only requests, explain that the CLI has no dry-run update check, inventory the update candidates, and ask before running an update.
- Use `npx --yes skills --help` for command help. Do not probe `npx skills update --help`; current CLI behavior can run the update flow.
- Visible means `npx skills list` reports the skill.
- Lock-tracked means the skill has an entry in a `skills` lock file: global `~/.agents/.skill-lock.json`, or project-local `skills-lock.json` in the repository root.
- Updateable means lock-tracked with the metadata `npx skills update` needs to refresh it.
- For project locks, update candidates have `skillPath` and are not `sourceType: local` or `sourceType: node_modules`.
- For global locks, update candidates have both `skillPath` and `skillFolderHash`; entries missing either field are lock-tracked but not automatically checkable by the CLI.
- Do not treat visible-only skills, local-source lock entries, node_modules lock entries, or lock entries missing required update metadata as update targets.

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
