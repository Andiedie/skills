# Andie's Agent Skills

Personal agent skills for coding agents.

These skills are written to be installable with the open `skills` CLI:

```bash
npx skills add Andiedie/skills --list
npx skills add Andiedie/skills
```

## Skills

### `documentation-reseed`

A one-off repository documentation reset flow:

1. Back up existing docs while preserving structure.
2. Keep product/code-layer docs in place.
3. Set up agent discoverability.
4. Harvest durable facts from old docs and current code.
5. Rebuild Agent-first docs.
6. Delete stale material.
7. Validate links and stale references.

Use it when a repo needs a broad documentation cleanup, not for routine doc edits.

### `documentation-maintenance`

The day-to-day Agent-first documentation rule set. Use it when creating, updating, deleting, reviewing, or reorganizing project docs.

## Matt Pocock skills

Before using these skills, it is best to install [mattpocock/skills](https://github.com/mattpocock/skills) too:

```bash
npx skills add mattpocock/skills --list
npx skills add mattpocock/skills
```

Required:

- `setup-matt-pocock-skills`: run once in each target repo before using Matt's engineering skills. It configures issue tracker, triage labels, and domain docs.

Recommended:

- `writing-great-skills`: use when creating or editing skills.
