# Andie's Agent Skills

Reusable skills for coding agents.

Read this repository when you want to install the skills, understand what each package is for, or maintain the skill source files.

## Install

List the skills exposed by this repository:

```bash
npx --yes skills add Andiedie/skills --list
```

Install the AI-native development loop globally for Codex and Claude Code:

```bash
npx --yes skills add Andiedie/skills -g --agent codex claude-code --skill and-backend-contract ask-andie and-intake and-triage and-clarify and-pack and-pick and-claim and-implement and-sweep setup-and -y
```

Install the repository interactively:

```bash
npx --yes skills add Andiedie/skills
```

Install one skill explicitly:

```bash
npx --yes skills add Andiedie/skills --skill <skill-name>
```

AND workflow skills depend on `and-backend-contract`. When installing one explicitly, include the reference skill in the same command:

```bash
npx --yes skills add Andiedie/skills --skill and-backend-contract and-pack
```

## Skill Packages

### AI-native development

[AI-native development](skills/ai-native-development/README.md) defines the delivery loop for turning ambiguous signals into packed, claimed, and implemented software changes.

It includes:

- `and-backend-contract`
- `ask-andie`
- `and-intake`
- `and-triage`
- `and-clarify`
- `and-pack`
- `and-pick`
- `and-claim`
- `and-implement`
- `and-sweep`
- `setup-and`

### Documentation

- `documentation-maintenance`: maintain agent-facing project docs without turning them into stale notes.
- `documentation-reseed`: rebuild a repository's docs from verified current facts when the existing structure is too stale to maintain incrementally.
- `normalize-agent-instructions`: make `AGENTS.md` canonical and keep related agent instruction files consistent.

### Skill Tooling

- `install-skills`: install, update, inspect, and troubleshoot `npx skills` managed skills.

### Code Review

- `codex-pr-review-loop`: run a GitHub PR through `@codex review`, fix agent-solvable feedback, and continue until clean or blocked on user judgment.

## AND Runtime Dependencies

The AI-native development loop builds on [Matt Pocock's skills repository](https://github.com/mattpocock/skills). Thanks to Matt Pocock and the repository's contributors for the engineering workflows this package composes with.

AND requires exactly these external runtime skills:

- `grilling`
- `tdd`
- `code-review`

Install or repair them with:

```sh
npx --yes skills add mattpocock/skills -g --agent codex claude-code --skill grilling tdd code-review -y
```

`setup-and` reports missing dependencies and the install command without installing them unless explicitly asked.

## Current Personal Skills

Snapshot from my local skill environment on 2026-07-11. This is a factual personal inventory, not an AND requirement or installation recommendation.

### Managed by `npx skills`

| Source | Skills |
| --- | --- |
| [Andiedie/cd2-skills](https://github.com/Andiedie/cd2-skills) | `cd2` |
| [Andiedie/loopmark](https://github.com/Andiedie/loopmark) | `loopmark` |
| [Andiedie/openlist-skills](https://github.com/Andiedie/openlist-skills) | `openlist` |
| [Andiedie/skills](https://github.com/Andiedie/skills) | `and-backend-contract`, `and-claim`, `and-clarify`, `and-implement`, `and-intake`, `and-pack`, `and-pick`, `and-sweep`, `and-triage`, `ask-andie`, `codex-pr-review-loop`, `documentation-maintenance`, `documentation-reseed`, `install-skills`, `normalize-agent-instructions`, `setup-and` |
| [mattpocock/skills](https://github.com/mattpocock/skills) | `ask-matt`, `code-review`, `codebase-design`, `diagnosing-bugs`, `domain-modeling`, `grill-me`, `grill-with-docs`, `grilling`, `handoff`, `implement`, `improve-codebase-architecture`, `prototype`, `research`, `scaffold-exercises`, `setup-matt-pocock-skills`, `tdd`, `teach`, `to-spec`, `to-tickets`, `triage`, `wayfinder`, `writing-great-skills` |
| [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | `web-design-guidelines`, `writing-guidelines` |
| [vercel-labs/skills](https://github.com/vercel-labs/skills) | `find-skills` |

### Codex-visible skills outside the `npx skills` lock

| Source | Skills |
| --- | --- |
| [Surge.app bundle](https://manual.nssurge.com/others/cli.html) | `Surge` |
| Codex local and system skills | `imagegen`, `playwright`, `playwright-interactive` |
| Codex browser plugin | `browser:control-in-app-browser` |
| Codex Chrome plugin | `chrome:control-chrome` |
| Codex Computer Use plugin | `computer-use:computer-use` |
| Codex GitHub plugin | `github:github`, `github:gh-address-comments`, `github:gh-fix-ci`, `github:yeet` |
| Codex primary runtime plugins | `documents:documents`, `pdf:pdf`, `presentations:Presentations`, `spreadsheets:Spreadsheets`, `spreadsheets:excel-live-control` |
| Codex Sites plugin | `sites:sites-building`, `sites:sites-hosting` |
| Codex Visualize plugin | `visualize:visualize` |

## Maintenance

- Skill source files live under `skills/*/SKILL.md` or package directories such as `skills/ai-native-development/*/SKILL.md`.
- When adding, renaming, or removing a skill, update `skills.sh.json`.
- When changing the AND workflow, update [Delivery loop](skills/ai-native-development/docs/delivery-loop.md), [Skills](skills/ai-native-development/docs/skills.md), and the affected workflow `SKILL.md` files together.
- When changing workflow state storage, update [AI-native backend contract](skills/ai-native-development/and-backend-contract/SKILL.md), its backend reference docs, and the affected workflow `SKILL.md` files together.
- When updating the personal skill snapshot, check `~/.agents/.skill-lock.json`, `npx --yes skills list -g -a codex --json`, enabled Codex plugins, and enabled Codex system skills.
