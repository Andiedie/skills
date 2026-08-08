# Andie's Agent Skills

Reusable skills for coding agents.

Read this repository when you want to install the skills, understand what each package is for, or maintain the skill source files.

## Install

List the skills exposed by this repository:

```bash
npx --yes skills add Andiedie/skills --list
```

Example: install the AI-native development loop globally for Codex and Claude Code:

```bash
npx --yes skills add Andiedie/skills -g --agent codex claude-code --skill and-workflow-contract and-interview-contract ask-andie and-intake and-triage and-clarify and-wayfind and-pack and-pick and-claim and-implement and-finish and-sweep code-review setup-and -y
```

Install the repository interactively:

```bash
npx --yes skills add Andiedie/skills
```

Install one skill explicitly:

```bash
npx --yes skills add Andiedie/skills --skill <skill-name>
```

AND workflow skills depend on `and-workflow-contract`. When installing one explicitly, include the reference skill in the same command:

```bash
npx --yes skills add Andiedie/skills --skill and-workflow-contract and-pack
```

`and-clarify` and `and-wayfind` also invoke `and-interview-contract`. Install either one with both reference skills:

```bash
npx --yes skills add Andiedie/skills --skill and-workflow-contract and-interview-contract and-clarify
npx --yes skills add Andiedie/skills --skill and-workflow-contract and-interview-contract and-wayfind
```

## Skill Packages

### AI-native development

[AI-native development](skills/ai-native-development/README.md) defines the delivery loop for turning ambiguous signals into verified and completed software changes.

It includes:

- `and-workflow-contract`
- `and-interview-contract`
- `ask-andie`
- `and-intake`
- `and-triage`
- `and-clarify`
- `and-wayfind`
- `and-pack`
- `and-pick`
- `and-claim`
- `and-implement`
- `and-finish`
- `and-sweep`
- `code-review`
- `setup-and`

### Documentation

- `documentation-maintenance`: maintain agent-facing project docs without turning them into stale notes.
- `documentation-reseed`: rebuild a repository's docs from verified current facts when the existing structure is too stale to maintain incrementally.
- `normalize-agent-instructions`: make `AGENTS.md` canonical and keep related agent instruction files consistent.

### Skill Tooling

- `install-skills`: install, update, inspect, and troubleshoot `npx skills` managed skills.

### Personal Utilities

- `codex-executor`: delegate bounded execution work to a user-selected Codex CLI profile while the parent Agent keeps planning and review.
- `luna-executor`: delegate bounded execution work to the configured Luna worker while the parent Agent keeps judgment and review.
- `progress-title`: keep the current Codex task title aligned with the active stage and evidence-based progress throughout AND work.

## AND Runtime Dependencies

The AI-native development loop builds on selected workflows from [Matt Pocock's skills repository](https://github.com/mattpocock/skills). Thanks to Matt Pocock and the repository's contributors for those foundations.

`code-review` is a generic review skill owned and distributed by this repository. Its review model comes from [mattpocock/skills v1.2.3](https://github.com/mattpocock/skills/releases/tag/v1.2.3), with setup responsibility removed while caller-provided review inputs remain generic. Install this source under the existing name; do not retain the Matt copy alongside it.

AND also requires exactly these external runtime skills from Matt:

- `grilling`
- `research`
- `prototype`
- `tdd`

Example for a global Codex and Claude Code environment:

```sh
npx --yes skills add Andiedie/skills -g --agent codex claude-code --skill code-review -y
npx --yes skills add mattpocock/skills -g --agent codex claude-code --skill grilling research prototype tdd -y
```

`setup-and` reports missing dependencies with source-specific install commands without installing them unless explicitly asked.

## Current Personal Skills

Snapshot from my local skill environment on 2026-08-08. This is a factual personal inventory, not an AND requirement or installation recommendation.

### Managed by `npx skills`

| Source | Skills |
| --- | --- |
| [Andiedie/cd2-skills](https://github.com/Andiedie/cd2-skills) | `cd2` |
| [Andiedie/loopmark](https://github.com/Andiedie/loopmark) | `loopmark` |
| [Andiedie/openlist-skills](https://github.com/Andiedie/openlist-skills) | `openlist` |
| [Andiedie/skills](https://github.com/Andiedie/skills) | `and-claim`, `and-clarify`, `and-finish`, `and-implement`, `and-intake`, `and-interview-contract`, `and-pack`, `and-pick`, `and-sweep`, `and-triage`, `and-wayfind`, `and-workflow-contract`, `ask-andie`, `code-review`, `codex-executor`, `documentation-maintenance`, `install-skills`, `luna-executor`, `normalize-agent-instructions`, `progress-title`, `setup-and` |
| [mattpocock/skills](https://github.com/mattpocock/skills) | `codebase-design`, `diagnosing-bugs`, `domain-modeling`, `grilling`, `handoff`, `improve-codebase-architecture`, `prototype`, `research`, `scaffold-exercises`, `tdd`, `teach`, `writing-for-agents` |
| [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | `web-design-guidelines`, `writing-guidelines` |
| [vercel-labs/skills](https://github.com/vercel-labs/skills) | `find-skills` |

### Codex-visible skills outside the `npx skills` lock

| Source | Skills |
| --- | --- |
| [Surge.app bundle](https://manual.nssurge.com/others/cli.html) | `Surge` |
| Codex local and system skills | `imagegen`, `playwright`, `playwright-interactive` |
| Codex browser plugin | `browser:control-in-app-browser` |
| Codex Chrome plugin | `chrome:control-chrome` |
| Codex Cloudflare plugin | `cloudflare:agents-sdk`, `cloudflare:building-ai-agent-on-cloudflare`, `cloudflare:building-mcp-server-on-cloudflare`, `cloudflare:cloudflare`, `cloudflare:durable-objects`, `cloudflare:sandbox-sdk`, `cloudflare:web-perf`, `cloudflare:workers-best-practices`, `cloudflare:wrangler` |
| Codex Computer Use plugin | `computer-use:computer-use` |
| Codex GitHub plugin | `github:github`, `github:gh-address-comments`, `github:gh-fix-ci`, `github:yeet` |
| Codex primary runtime plugins | `documents:documents`, `pdf:pdf`, `presentations:Presentations`, `spreadsheets:Spreadsheets`, `spreadsheets:excel-live-control` |
| Codex Security plugin | `codex-security:attack-path-analysis`, `codex-security:deep-security-scan`, `codex-security:define-security-policy`, `codex-security:finding-discovery`, `codex-security:fix-finding`, `codex-security:propose-security-hardening`, `codex-security:security-diff-scan`, `codex-security:security-scan`, `codex-security:threat-model`, `codex-security:track-findings`, `codex-security:triage-finding`, `codex-security:validation`, `codex-security:vulnerability-writeup` |
| Codex Sites plugin | `sites:sites-building`, `sites:sites-hosting` |
| Codex Visualize plugin | `visualize:visualize` |

## Maintenance

- Skill source files live under `skills/*/SKILL.md` or package directories such as `skills/ai-native-development/*/SKILL.md`.
- When adding, renaming, or removing a skill, update `skills.sh.json`.
- When changing the AND workflow, update [Delivery loop](skills/ai-native-development/docs/delivery-loop.md), [Skills](skills/ai-native-development/docs/skills.md), and the affected workflow `SKILL.md` files together.
- When changing shared workflow state concepts, GitHub representation, operations, or invariants, update [AND workflow contract](skills/ai-native-development/and-workflow-contract/SKILL.md) and the affected workflow `SKILL.md` files together.
- When updating the personal skill snapshot, check `~/.agents/.skill-lock.json`, `npx --yes skills list -g -a codex --json`, enabled Codex plugins, and enabled Codex system skills.
