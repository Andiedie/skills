# External PR Signals

Read this reference only when the user explicitly presents one pull request to intake.

## Resolve The Work Record

- Search GitHub Issues and the PR's references for one authoritative work record that tracks the exact requested behavior.
- Update that record when it exists.
- Otherwise create exactly one raw work record, even when related but distinct work exists, and link the related context.

## Capture Evidence

- Preserve the PR URL, author, description, relevant check results, and behavior observable from a light diff inspection.
- Record the author's stated intent as an author claim and keep it distinct from Agent-observed evidence.
- Inspect only enough of the diff and checks to describe the signal accurately; correctness and specification verification belong to later stages.
- Return the PR URL and captured evidence to the main intake process; the workflow contract determines their representation.
- Leave the PR unchanged during intake.
