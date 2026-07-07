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

1. **`issue-intake`** records a raw signal as a durable work record.
2. **`issue-triage`** decides whether recorded work should close, wait for information, or move to pack.
3. **`issue-grill`** resolves blocking human decisions and records backend-safe packaging input.
4. **`issue-pack`** creates one executable delivery unit: a single issue package or a PRD package.
5. **`issue-pick`** chooses one unblocked, unclaimed delivery unit from ready work. It is read-only.
6. **`issue-claim`** records ownership for the complete delivery unit without changing its scope.
7. **`issue-implement`** implements the claimed work in an isolated worktree.
8. **Close or learn** when the work is merged, rejected, duplicated, already done, or needs follow-up documentation.

## Context Hygiene

Keep clarification and packaging in one context until the package is published. After a PRD package is claimed, the owner may use child records as fresh subagent work units, each grounded in the parent PRD plus its child record.

## On-Ramps

Pick the route from the current surface:

- **Raw request, idea, bug report, screenshot, or note not yet tracked** -> `issue-intake`.
- **Existing work with unclear state** -> `issue-triage`.
- **Existing work marked `needs-info` with new reporter or maintainer activity** -> `issue-triage`.
- **Existing work marked `needs-info` with `Resume with: issue-grill` or `Cause: decision-needed` in the latest State Reason** -> `issue-grill`.
- **Existing work marked `needs-info` with missing reporter facts, access, external state, or acceptance input** -> route the State Reason question to the owner; run the `Resume with` skill after new information arrives.
- **Existing work marked `needs-pack`** -> `issue-pack`.
- **Ready single issue package or PRD package slate and no specific delivery unit chosen** -> `issue-pick`.
- **Specific ready single issue package or PRD package already chosen** -> `issue-claim`.
- **Claimed single issue package or PRD package** -> `issue-implement`.
- **Backend state drift, stale claim, blocked ready work, PRD child picked independently, or parent PRD cleanup** -> `issue-sweep`.
- **New repository with no workflow setup** -> `setup-ai-native-development`.

## Precondition

Run `setup-ai-native-development` before relying on the workflow in a new repository. The setup should create `.and/config.yml`, choose one workflow state backend, and define stage state, relationship rules, claim policy, implementation isolation, and agent-facing docs.

## When Invoked

1. Identify the current surface: request, work record, PR, branch, local diff, or backend audit.
2. Read `.and/config.yml`, then use `ai-native-backend-contract` for the backend contract and configured backend reference. If `ai-native-backend-contract` is unavailable, stop and ask the user to install it; do not infer backend rules. If setup is missing or the backend value is unsupported, route to `setup-ai-native-development`.
3. Read only the evidence needed to route: lifecycle state, stage state, latest State Reason, comments or receipts, blockers, ownership, linked implementation artifacts, containment, dependency relationships, and current branch or diff when relevant.
4. Name the current loop position, the next skill, and the general rule the user can remember next time.
5. If a `needs-info` work record lacks a current State Reason, route to `issue-triage` to restore the reason before choosing another skill.
6. If the route is uncertain, choose the smallest clarifying route: `issue-triage` for unclear backend state, `issue-grill` for missing product or business decisions, `setup-ai-native-development` for missing repository rules, or one direct question when the user must decide.
7. Report the route compactly using the user's language. Keep skill names, labels, issue numbers, work IDs, commands, and code identifiers literal. Omit optional lines when they would only say `none`.

```markdown
Current position: <stage or surface>
Evidence: <facts used to route>
Next skill: <skill>
Why: <one or two sentences>
Rule to learn: <general routing rule>
Skip ask next time when: <recognizable condition>
Human input needed: <none / exact State Reason question>
Watch-outs: <blocker, claim, parent PRD, stale state, or none>
```

Completion criterion: the user can run one named skill next, or can answer one concrete question that will make the next skill clear.

## Boundaries

- Do not edit workflow backend state.
- Do not synthesize full requirements, rank ready work, or repair backend drift.
- Do not claim work.
- Do not implement work.
- Do not decide product priority unless the user supplied the priority rule.
