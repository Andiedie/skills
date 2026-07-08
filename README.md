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
npx --yes skills add Andiedie/skills -g --agent codex claude-code --skill ai-native-backend-contract ask-andie issue-intake issue-triage issue-grill issue-pack issue-pick issue-claim issue-implement issue-sweep setup-ai-native-development -y
```

Install the repository interactively:

```bash
npx --yes skills add Andiedie/skills
```

Install one skill explicitly:

```bash
npx --yes skills add Andiedie/skills --skill <skill-name>
```

AI-native workflow skills depend on `ai-native-backend-contract`. When installing one explicitly, include the reference skill in the same command:

```bash
npx --yes skills add Andiedie/skills --skill ai-native-backend-contract issue-pack
```

## Skill Packages

### AI-native development

[AI-native development](skills/ai-native-development/README.md) defines the delivery loop for turning ambiguous signals into packed, claimed, and implemented software changes.

It includes:

- `ai-native-backend-contract`
- `ask-andie`
- `issue-intake`
- `issue-triage`
- `issue-grill`
- `issue-pack`
- `issue-pick`
- `issue-claim`
- `issue-implement`
- `issue-sweep`
- `setup-ai-native-development`

### Documentation

- `documentation-maintenance`: maintain agent-facing project docs without turning them into stale notes.
- `documentation-reseed`: rebuild a repository's docs from verified current facts when the existing structure is too stale to maintain incrementally.
- `normalize-agent-instructions`: make `AGENTS.md` canonical and keep related agent instruction files consistent.

### Skill Tooling

- `install-skills`: install, update, inspect, and troubleshoot `npx skills` managed skills.

### Code Review

- `codex-pr-review-loop`: run a GitHub PR through `@codex review`, fix agent-solvable feedback, and continue until clean or blocked on user judgment.

## External Skills

Several workflows in this repository intentionally compose with skills from [Matt Pocock's skills repository](https://github.com/mattpocock/skills).

The AI-native development loop expects these Matt skills to be installed:

- `grilling`
- `domain-modeling`
- `tdd`
- `code-review`

To install or repair the required Matt skills:

```sh
npx --yes skills add mattpocock/skills -g --agent codex claude-code --skill grilling domain-modeling tdd code-review -y
```

`setup-ai-native-development` should check and report those skills before declaring the skill environment ready. If any are missing, setup must report the missing skill names and the install command; it should not install them unless explicitly asked.

Other Matt skills are useful references or adjacent tools, but not required for this loop: `diagnosing-bugs`, `codebase-design`, `ask-matt`, `setup-matt-pocock-skills`, `grill-with-docs`, `implement`, `to-prd`, and `to-issues`.

The `issue-grill` skill is a backend-safe adaptation of Matt's `grill-with-docs`: it keeps the `/grilling` and `/domain-modeling` handfeel, but records decisions and documentation proposals in the configured workflow backend for `issue-pack` instead of editing local docs during clarification.

The `issue-pack` skill adapts the PRD and tracer-bullet issue ideas from Matt's `to-prd` and `to-issues` to this repository's `needs-pack`, PRD package, relationship, backend, and claim rules.

The `issue-implement` skill adapts Matt's `implement` for claimed AI-native delivery units by adding configured-backend source-of-truth and isolated worktree requirements.

## Current Personal Skills

Snapshot from my local skill environment on 2026-07-03. This records the skills I use locally; it is broader than the skills exported by this repository.

### Managed by `npx skills`

| Source | Skills |
| --- | --- |
| [Andiedie/cd2-skills](https://github.com/Andiedie/cd2-skills) | `cd2` |
| [Andiedie/loopmark](https://github.com/Andiedie/loopmark) | `loopmark` |
| [Andiedie/openlist-skills](https://github.com/Andiedie/openlist-skills) | `openlist` |
| [Andiedie/skills](https://github.com/Andiedie/skills) | `ai-native-backend-contract`, `ask-andie`, `codex-pr-review-loop`, `documentation-maintenance`, `documentation-reseed`, `install-skills`, `issue-claim`, `issue-grill`, `issue-implement`, `issue-intake`, `issue-pack`, `issue-pick`, `issue-sweep`, `issue-triage`, `normalize-agent-instructions`, `setup-ai-native-development` |
| [anthropics/skills](https://github.com/anthropics/skills) | `docx`, `pdf`, `pptx`, `xlsx` |
| [mattpocock/skills](https://github.com/mattpocock/skills) | `ask-matt`, `code-review`, `codebase-design`, `diagnosing-bugs`, `domain-modeling`, `grill-with-docs`, `grilling`, `handoff`, `implement`, `improve-codebase-architecture`, `prototype`, `scaffold-exercises`, `setup-matt-pocock-skills`, `tdd`, `teach`, `to-issues`, `to-prd`, `writing-great-skills` |
| [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | `web-design-guidelines`, `writing-guidelines` |
| [vercel-labs/skills](https://github.com/vercel-labs/skills) | `find-skills` |

### Codex-visible skills outside the `npx skills` lock

| Source | Skills |
| --- | --- |
| [Surge.app bundle](https://manual.nssurge.com/others/cli.html) | `Surge` |
| Codex local skills | `imagegen`, `playwright`, `playwright-interactive` |
| Codex browser plugin | `browser:control-in-app-browser` |
| Codex Chrome plugin | `chrome:control-chrome` |
| Codex Computer Use plugin | `computer-use:computer-use` |
| Codex GitHub plugin | `github:github`, `github:gh-address-comments`, `github:gh-fix-ci`, `github:yeet` |
| Codex primary runtime plugins | `documents:documents`, `pdf:pdf`, `presentations:Presentations`, `spreadsheets:Spreadsheets`, `template-creator:template-creator` |

## Maintenance

- Skill source files live under `skills/*/SKILL.md` or package directories such as `skills/ai-native-development/*/SKILL.md`.
- When adding, renaming, or removing a skill, update `skills.sh.json`.
- When changing the AI-native issue workflow, update [Delivery loop](skills/ai-native-development/docs/delivery-loop.md), [Skills](skills/ai-native-development/docs/skills.md), and the affected workflow `SKILL.md` files together.
- When changing workflow state storage, update [AI-native backend contract](skills/ai-native-development/ai-native-backend-contract/SKILL.md), its backend reference docs, and the affected workflow `SKILL.md` files together.
- When updating the personal skill snapshot, check `~/.agents/.skill-lock.json`, `npx --yes skills list -g -a codex --json`, enabled Codex plugins, and enabled Codex system skills.
