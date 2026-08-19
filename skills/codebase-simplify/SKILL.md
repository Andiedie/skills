---
name: codebase-simplify
description: Audit a codebase for evidence-backed opportunities to remove or collapse complexity.
disable-model-invocation: true
---

# Codebase Simplify

Run a read-only, whole-repository simplification audit. Return findings in the conversation; leave repository and external state unchanged.

Read [Simplification Signals](signals.md) before surveying the code.

## 1. Map The Repository

Read the effective repository instructions, architecture docs, manifests, production entry points, and current `git status`. Define the production corpus, evidence corpus such as tests and docs, and intentional exclusions such as generated or vendored code.

Partition the production corpus into review areas along existing runtime, workspace, or module seams. Record each area's paths and entry points in a coverage map.

Completion criterion: every production path belongs to one review area or an explicit exclusion, and the starting `HEAD` and worktree state are known.

## 2. Survey Broadly

Inspect every review area against the simplification signals. Start with the largest production surfaces and the code with the most states, interfaces, lifecycle machinery, or cross-module coordination; symbol-level dead-code searches are supporting evidence, not the survey boundary.

For repositories with independent areas, assign disjoint areas to parallel sub-agents when available. Require each survey to report its coverage, candidates, and areas examined without a candidate.

Trace trust, ownership, and lifecycle through complex paths. Map flags, promises, callbacks, validators, cancellation paths, and disposers to the fact or transition each represents; mirrored facts are candidates for collapse.

Completion criterion: every review area is marked surveyed, excluded, or blocked with a reason, and no area stops at its first candidate.

## 3. Prove Or Reject

For each candidate:

1. Search exact symbols, call forms, config keys, event names, and wire strings with `rg`, then read the call sites.
2. Classify consumers as production, evidence-only, or ambiguous; resolve ambiguous consumers from their runtime path.
3. Check repository docs, tests, and relevant history for the reason the surface exists. Search existing issue or decision records when they are available.
4. State the exact deletion, fold, demotion, or dependency replacement and the behavior or capability it gives up.
5. Measure net simplification: concepts, states, interface obligations, branches, dedicated tests, and documentation removed versus glue or migration added.
6. Give a verification path that would prove a later implementation complete.

Classify the result:

- **Confirmed:** current evidence supports a concrete simplification.
- **Decision:** the opportunity is real, but product intent, compatibility, or architecture ownership must decide it.
- **Rejected:** evidence explains why the current structure earns its cost.

Treat removal of a current production behavior as Decision unless repository evidence shows that behavior is accidental or already superseded.

Completion criterion: every reported candidate identifies its consumers, rationale, net reduction, tradeoff, and verification path; thin guesses have been rejected.

## 4. Consolidate And Rank

Merge candidates that remove the same underlying mechanism. Rank confirmed candidates by expected net complexity reduction, then confidence; use change size only as supporting context. Keep Decision items separate from Confirmed findings.

Completion criterion: each mechanism has one owner finding, overlaps are folded into it, and the ranking reflects value rather than finding order.

## 5. Report

Return:

1. The audited `HEAD`, worktree-state comparison, and exclusions.
2. A coverage table with one disposition for every review area.
3. Confirmed findings as self-contained blocks using this shape:

```markdown
### <action-oriented title>
Scope: <repository-relative paths and symbols>
Evidence: <production and evidence-only consumers, with relevant rationale>
Simplification: <exactly what to remove, fold, demote, or replace>
Payoff: <concepts, states, interfaces, branches, tests, or docs eliminated>
Behavior and tradeoff: <what remains true and what capability is surrendered>
Verification: <checks for a later implementation>
Confidence: <high or medium, with the main uncertainty when present>
Search key: <stable path::symbol-or-mechanism key>
```

4. Decision items, blocked areas, and representative rejected hypotheses.

Each Confirmed block is one raw signal that can stand alone in a downstream issue workflow. If the full coverage cannot be completed, label the report partial and name every remaining review area instead of claiming a whole-repository audit.

Completion criterion: every scoped area is accounted for, every Confirmed finding meets the evidence bar, each finding stands alone, uncertainties are visible, and the final worktree state matches the starting state.
