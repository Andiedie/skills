---
name: install-skills
description: Install and update Agent Skills with npx skills. Use when the user asks to install, add, update, upgrade, refresh, or check skills from a GitHub repo, well-known skill URL, skills package, global scope, project scope, or all npx-managed skill scopes.
---

# Install And Update Skills

Use this for installing and updating Agent Skills through `npx skills`.

## Operation Routing

- For an install or add request, read [Install Operation](install.md) before acting.
- For an update, upgrade, refresh, or check-only request, read [Update Operation](update.md) before acting.
- When the user explicitly requests both operations, read both operation references and apply each selected workflow.
- After a selected install or update command fails, read [Cache-Corruption Retry](cache-corruption-retry.md) only when its output confirms local npm cache corruption. Do not load or apply that reference for normal runs or unrelated failures.

## Common Contract

- Resolve `global` or `project` scope for every selected operation before mutation. If any selected operation's scope remains ambiguous, ask one direct question.
- Preserve unrelated local skill files and lock mismatches. Report them instead of rewriting around them.
