# Andie's Agent Skills

Personal agent skills for coding agents.

These skills are written to be installable with the open `skills` CLI:

```bash
npx skills add Andiedie/skills --list
npx skills add Andiedie/skills
```

## Repository Skills

### `documentation-maintenance`

Agent-first documentation maintenance workflow for deciding when to create, update, merge, or delete project documentation.

### `documentation-reseed`

One-off repository documentation reseed workflow for backing up existing docs, rebuilding durable agent-facing docs from current facts, and pruning stale material.

### `install-skills`

Predictable `npx skills` installation and update workflow for global or project-local skills, explicit skill selection, lock-aware update classification, and the `.agents/skills` plus `.claude/skills` layout.

### `codex-pr-review-loop`

Loop a GitHub PR through `@codex review`, fix agent-solvable feedback, push, and re-review until clean or blocked on user judgement.

### `normalize-agent-instructions`

Normalize `AGENTS.md` and `CLAUDE.md` project instruction files so `AGENTS.md` is canonical and `CLAUDE.md` imports it.

## Appendix: Current Personal Skills

Reference list of global skills currently in use, grouped by source.

### Maintenance

- Repository skill source files live under `skills/*/SKILL.md`.
- The `Managed by npx skills` table should match `~/.agents/.skill-lock.json`.
- Verify global state with:

```bash
npx --yes skills list -g --json
jq -r '.skills | to_entries[] | [.key, .value.source] | @tsv' ~/.agents/.skill-lock.json
```

- After adding a repository skill, commit and push first, then install it globally:

```bash
npx --yes skills add Andiedie/skills -g --agent codex claude-code --skill <skill> -y
```

### Managed by `npx skills`

| Source | Skills |
| --- | --- |
| [Andiedie/cd2-skills](https://github.com/Andiedie/cd2-skills) | `cd2` |
| [Andiedie/loopmark](https://github.com/Andiedie/loopmark) | `loopmark` |
| [Andiedie/openlist-skills](https://github.com/Andiedie/openlist-skills) | `openlist` |
| [Andiedie/skills](https://github.com/Andiedie/skills) | `documentation-maintenance`, `documentation-reseed`, `install-skills`, `normalize-agent-instructions` |
| [anthropics/skills](https://github.com/anthropics/skills) | `docx`, `pdf`, `pptx`, `xlsx` |
| [mattpocock/skills](https://github.com/mattpocock/skills) | `ask-matt`, `codebase-design`, `diagnosing-bugs`, `domain-modeling`, `grill-with-docs`, `grilling`, `handoff`, `implement`, `improve-codebase-architecture`, `prototype`, `scaffold-exercises`, `setup-matt-pocock-skills`, `tdd`, `teach`, `to-issues`, `to-prd`, `writing-great-skills` |
| [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | `web-design-guidelines`, `writing-guidelines` |
| [vercel-labs/skills](https://github.com/vercel-labs/skills) | `find-skills` |

### Bundled or External Skills

| Source | Skills |
| --- | --- |
| [Surge.app bundle](https://manual.nssurge.com/others/cli.html) | `Surge` |
| Codex bundled skills | `playwright`, `playwright-interactive` |
