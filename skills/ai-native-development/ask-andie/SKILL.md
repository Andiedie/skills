---
name: ask-andie
description: Router for the AI-native development loop.
disable-model-invocation: true
---

# Ask Andie

You do not need to remember every issue skill. Ask when you need to know where the work is, what should happen next, or which skill fits the current situation.

Do more than route. Teach the rule that made the route obvious, so the user can learn the loop and need this skill less often.

## Main Loop

The usual route for issue work:

1. **`issue-intake`** records a raw signal as durable tracker work.
2. **`issue-triage`** decides whether recorded work should close, wait for information, or move to pack.
3. **`issue-grill`** resolves blocking human decisions and records tracker-safe packaging input.
4. **`issue-pack`** creates one executable delivery unit: a single issue package or a PRD package.
5. **`issue-pick`** chooses one unblocked, unclaimed delivery unit from ready work. It is read-only.
6. **`issue-claim`** records ownership for the complete delivery unit without changing its scope.
7. **`issue-implement`** implements the claimed work in an isolated worktree.
8. **Close or learn** when the work is merged, rejected, duplicated, already done, or needs follow-up documentation.

## Context Hygiene

Keep clarification and packaging in one context until the package is published. After a PRD package is claimed, the owner may use child issues as fresh subagent work units, each grounded in the parent PRD plus its child issue.

## On-Ramps

Pick the route from the current surface:

- **Raw request, idea, bug report, screenshot, or note not yet tracked** -> `issue-intake`.
- **Existing issue with unclear state** -> `issue-triage`.
- **Existing issue marked `needs-info` with new reporter or maintainer activity** -> `issue-triage`.
- **Existing issue marked `needs-info` because decisions are missing** -> `issue-grill`.
- **Existing issue marked `needs-pack`** -> `issue-pack`.
- **Ready single issue package or PRD package slate and no specific delivery unit chosen** -> `issue-pick`.
- **Specific ready single issue package or PRD package already chosen** -> `issue-claim`.
- **Claimed single issue package or PRD package** -> `issue-implement`.
- **Tracker drift, stale claim, blocked ready work, PRD child picked independently, or parent PRD cleanup** -> `issue-sweep`.
- **New repository with no workflow setup** -> `setup-ai-native-development`.

## Precondition

Run `setup-ai-native-development` before relying on the workflow in a new repository. The setup should define tracker location, state labels, relationship rules, claim policy, and agent-facing docs.

## When Invoked

1. Identify the current surface: request, issue, PR, branch, local diff, or tracker audit.
2. Read only the evidence needed to route: open or closed state, labels, comments, blockers, assignees, claim comments, linked PRs, parent/sub-issues, and current branch or diff when relevant.
3. Name the current loop position, the next skill, and the general rule the user can remember next time.
4. If the route is uncertain, choose the smallest clarifying route: `issue-triage` for unclear tracker state, `issue-grill` for missing product or business decisions, `setup-ai-native-development` for missing repository rules, or one direct question when the user must decide.
5. Report the route compactly using the user's language. Keep skill names, labels, issue numbers, commands, and code identifiers literal. Omit optional lines when they would only say `none`.

```markdown
Current position: <stage or surface>
Evidence: <facts used to route>
Next skill: <skill>
Why: <one or two sentences>
Rule to learn: <general routing rule>
Skip ask next time when: <recognizable condition>
Human input needed: <none / exact question>
Watch-outs: <blocker, claim, parent PRD, stale state, or none>
```

Completion criterion: the user can run one named skill next, or can answer one concrete question that will make the next skill clear.

## Boundaries

- Do not edit tracker state.
- Do not synthesize full requirements, rank ready work, or repair tracker drift.
- Do not claim work.
- Do not implement work.
- Do not decide product priority unless the user supplied the priority rule.
