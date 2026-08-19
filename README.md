# Andie's Agent Skills

Reusable skills for coding agents.

## Install

List the skills this repository exports:

```bash
npx --yes skills add Andiedie/skills --list
```

Install interactively:

```bash
npx --yes skills add Andiedie/skills
```

Install one skill:

```bash
npx --yes skills add Andiedie/skills --skill <skill-name>
```

## Skills

- `codebase-simplify`: audit a whole repository for evidence-backed opportunities to remove or collapse complexity.
- `documentation-maintenance`: maintain agent-facing project docs without turning them into stale notes.
- `documentation-reseed`: rebuild a repository's docs from verified current facts when the existing structure is too stale to maintain incrementally.
- `finish`: ship the current reviewed branch, merge it, close the Spec or ticket, tear down, and clean safe Git artifacts.
- `install-skills`: install, update, inspect, and troubleshoot `npx skills` managed skills.
- `intake`: create one unlabeled GitHub Issue from a raw signal and return its URL.
- `luna-executor`: proactively delegate suitable bounded execution work to the configured Luna worker through model invocation while the parent Agent keeps judgment and review.
- `normalize-agent-instructions`: make `AGENTS.md` canonical and keep related agent instruction files consistent.
- `setup-worktree-friendly`: make one repository's local resources worktree-safe and record a setup/teardown interface.
- `use-worktree`: create `.worktrees/<name>` from the current `HEAD` and run repository setup.

## Maintenance

- Skill source files live under `skills/*/SKILL.md`.
- When adding, renaming, or removing a skill, keep `skills.sh.json` groupings accurate. Ungrouped skills are discovered from those `SKILL.md` files.
