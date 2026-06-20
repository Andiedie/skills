---
name: audit-installed-skills
description: Audit installed Agent Skills with a script-driven quick check. Use when the user asks to check installed skills, deleted skills, new available skills, known audit events, or README drift.
---

# Audit Installed Skills

Use this to audit installed Agent Skills. Default to global scope unless the user explicitly asks for project/local skills.

## Steps

### 1. Run The Script

Resolve the script beside this `SKILL.md`; do not reimplement the audit in shell. When this skill is installed globally, run the absolute script path under that installed skill directory while keeping the user's target workspace as the current working directory.

From this repository, global audit looks like:

```bash
node skills/audit-installed-skills/bin/audit-installed-skills.mjs --scope global --json
```

From this repository, project audit looks like:

```bash
node skills/audit-installed-skills/bin/audit-installed-skills.mjs --scope project --json
```

Use `--strict` only when the user asks for content-update proof or upstream file diffs. Quick mode skips installed-vs-upstream content hashes and directory diffs, but may still fetch listings, retry failed listings, or run a shallow path scan when classification needs it.

Completion criterion: the script returned JSON, or the report clearly says which command failed and why.

### 2. Explain Results

Treat the script JSON as the source of truth. Do not rerun `npx skills`, inspect upstream repositories, or rewrite the classification unless the JSON reports a limitation that needs manual follow-up.

Report:

- installed count and audit mode
- deleted or deprecated installed skills
- new available skills whose `reportable` flag is true, with a short explanation from their descriptions
- updated skills only when strict mode reports them
- unknown checks and limitations
- README drift, for global audits
- known-event ledger status

Omit suppressed known `new` and `updated` events from the main details. Keep already-known deletions visible because the installed skill is still affected.

Completion criterion: the user can tell what is new, what is already known, what was skipped by quick mode, and what needs action.

### 3. Handle Optional Actions

Do not install, update, commit, or push during an audit unless the user explicitly asks.

If the user asks to sync README, edit only the stale snapshot rows reported by the script and preserve unrelated sections. Before any commit/push, state the exact file list, commit message, current branch, push target, and commands you will run. Proceed only after approval.

Completion criterion: optional actions are either not requested, completed, or left clearly pending with the required user decision.
