# Andie's Agent Skills

Reusable skills for coding agents.

Read this repository when you want to install the skills, understand what each package is for, or maintain the skill source files.

## Install

List the skills exposed by this repository:

```bash
npx --yes skills add Andiedie/skills --list
```

Install them:

```bash
npx --yes skills add Andiedie/skills
```

Install one skill explicitly:

```bash
npx --yes skills add Andiedie/skills --skill <skill-name>
```

## Skill Packages

### AI-native development

[AI-native development](skills/ai-native-development/README.md) defines the delivery loop for turning ambiguous signals into packed, claimed, and implemented software changes.

It includes:

- `ask-andie`
- `issue-intake`
- `issue-triage`
- `issue-pack`
- `issue-pick`
- `issue-claim`
- `issue-sweeper`
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

Several workflows in this repository intentionally compose with skills from [Matt Pocock's skills repository](https://github.com/mattpocock/skills), especially `grill-with-docs` for decision clarification and `implement` for execution after claim.

The `issue-pack` skill adapts the PRD and tracer-bullet issue ideas from Matt's `to-prd` and `to-issues` to this repository's `needs-pack`, PRD package, relationship, and claim rules.

## Maintenance

- Skill source files live under `skills/*/SKILL.md` or package directories such as `skills/ai-native-development/*/SKILL.md`.
- When adding, renaming, or removing a skill, update `skills.sh.json`.
- When changing the AI-native issue workflow, update [Delivery loop](skills/ai-native-development/docs/delivery-loop.md), [Skills](skills/ai-native-development/docs/skills.md), and the affected workflow `SKILL.md` files together.
