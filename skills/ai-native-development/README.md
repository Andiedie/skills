# AI-native development

This package defines the AI-native delivery loop and the workflow skills that turn ambiguous signals into packed, claimed, and implemented software changes.

Read this when you need to choose the next issue workflow step, understand the label and relationship rules, or maintain one of the workflow skills.

## Start here

| Need | Read |
| --- | --- |
| Understand the loop, state labels, tracker relationships, and claim rules | [Delivery loop](docs/delivery-loop.md) |
| Choose the right skill for the current work | [Skills](docs/skills.md) |
| Edit a specific workflow skill | The relevant `skills/ai-native-development/<skill>/SKILL.md` |

## Workflow skills

This package contains the issue workflow skills:

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

## Acknowledgements

This workflow builds on [Matt Pocock's skills repository](https://github.com/mattpocock/skills), especially `grill-with-docs`, `implement`, `to-prd`, and `to-issues`. The AI-native loop adapts `grill-with-docs` into `issue-grill` so clarification records tracker-safe packaging input instead of local doc edits, adapts `implement` into `issue-implement` for claimed worktree-isolated execution, and adapts the PRD and tracer-bullet issue ideas to this repository's tracker vocabulary, PRD package model, and claim/relationship rules.
