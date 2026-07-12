# Repository Instructions

## AI-native development

This repository uses the AND delivery loop.

- Read `.and/config.yml` before workflow-state work.
- Use the configured backend as the source of truth.
- Use `ask-andie` when the next workflow skill is unclear.
- Do not maintain parallel GitHub and markdown workflow state.
- For workflow rules, use the installed `ai-native-development` skills and backend contract.

## AND finish policy

- `and-finish` uses `main` as the authorized target branch and squash as the authorized merge method.
- An explicit user instruction may override either value for one finish operation.
