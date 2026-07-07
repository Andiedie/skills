# AI-native development

This package defines the AI-native delivery loop and the workflow skills that turn ambiguous signals into packed, claimed, and implemented software changes.

Read this when you need to choose the next issue workflow step, understand the stage-state and relationship rules, or maintain one of the workflow skills.

## Start here

| Need | Read |
| --- | --- |
| Understand the loop, stage state, backend relationships, and claim rules | [Delivery loop](docs/delivery-loop.md) |
| Understand configured workflow state backends | [AI-native backend contract](ai-native-backend-contract/SKILL.md) |
| Check GitHub-native or markdown-file-based representation rules | [Backend references](ai-native-backend-contract/backends/) |
| Dry-run the loop under either backend | [Workflow examples](ai-native-backend-contract/workflow-examples.md) |
| Choose the right skill for the current work | [Skills](docs/skills.md) |
| Edit a specific workflow skill | The relevant `skills/ai-native-development/<skill>/SKILL.md` |

## Skills

This package contains the AI-native workflow and reference skills:

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

Install `ai-native-backend-contract` with any individually installed AI-native workflow skill; it supplies the configured backend rules.

## Acknowledgements

This workflow builds on [Matt Pocock's skills repository](https://github.com/mattpocock/skills), especially `grill-with-docs`, `implement`, `to-prd`, and `to-issues`. The AI-native loop adapts `grill-with-docs` into `issue-grill` so clarification records backend-safe packaging input instead of local doc edits, adapts `implement` into `issue-implement` for claimed worktree-isolated execution, and adapts the PRD and tracer-bullet issue ideas to this repository's backend model, PRD package model, and claim/relationship rules.
