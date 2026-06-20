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

Predictable `npx skills` installation workflow for global or project-local skills, explicit skill selection, and the `.agents/skills` plus `.claude/skills` symlink layout.

### `normalize-agent-instructions`

Normalize `AGENTS.md` and `CLAUDE.md` project instruction files so `AGENTS.md` is canonical and `CLAUDE.md` imports it.

## Appendix: Current Personal Skills

Snapshot from my local skill environment on 2026-06-19. This is a reference list of skills currently in use, grouped by source.

| Source | Skills |
| --- | --- |
| [Andiedie/skills](https://github.com/Andiedie/skills) | `documentation-maintenance`, `documentation-reseed`, `install-skills` |
| [Andiedie/loopmark](https://github.com/Andiedie/loopmark) | `loopmark` |
| [anthropics/skills](https://github.com/anthropics/skills) | `docx`, `pdf`, `pptx`, `xlsx` |
| [mattpocock/skills](https://github.com/mattpocock/skills) | `ask-matt`, `codebase-design`, `diagnosing-bugs`, `domain-modeling`, `grill-with-docs`, `grilling`, `handoff`, `improve-codebase-architecture`, `prototype`, `scaffold-exercises`, `setup-matt-pocock-skills`, `tdd`, `teach`, `to-issues`, `to-prd`, `writing-great-skills` |
| [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) | `agent-browser` |
| [vercel-labs/skills](https://github.com/vercel-labs/skills) | `find-skills` |
| Codex built-in system skills ([openai/skills](https://github.com/openai/skills/tree/main/skills/.system/imagegen)) | `imagegen` |
| Codex plugin [`browser@openai-bundled`](https://developers.openai.com/codex/app/browser) | `browser:control-in-app-browser` |
| Codex plugin [`chrome@openai-bundled`](https://developers.openai.com/codex/app/chrome-extension) | `chrome:control-chrome` |
| Codex plugin [`computer-use@openai-bundled`](https://developers.openai.com/codex/app/computer-use) | `computer-use:computer-use` |
| Codex plugin [`github@openai-curated`](https://github.com/openai/plugins) | `github:github`, `github:gh-address-comments`, `github:gh-fix-ci`, `github:yeet` |
