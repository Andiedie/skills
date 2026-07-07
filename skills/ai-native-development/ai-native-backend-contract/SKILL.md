---
name: ai-native-backend-contract
description: Use when an AI-native workflow skill needs the workflow backend contract or the configured `github-native` / `markdown-file-based` backend reference.
---

# AI-Native Backend Contract

This is a reference skill for AI-native workflow state backends. It does not intake, triage, grill, pack, pick, claim, implement, sweep, or mutate workflow state.

Use it whenever an AI-native workflow skill needs to know where authoritative delivery-loop state lives and how to read or write that state.

## Process

1. Read the repository's `.and/config.yml`.
   - If it is missing, route to `setup-ai-native-development`.
   - If `workflow_state_backend` is not `github-native` or `markdown-file-based`, route to `setup-ai-native-development`.
   - Completion criterion: the configured backend value is known and supported.

2. Read [backend-contract.md](backend-contract.md).
   - Use it for backend-neutral concepts: work record, delivery unit, stage state, State Reason, Package Contract, containment, dependency, external blocker, ownership, receipt, lifecycle outcome, completion evidence, and implementation artifact.
   - Completion criterion: the workflow operation is framed in backend-neutral terms before any backend-specific mutation.

3. Read exactly one backend reference:
   - For `github-native`, read [backends/github-native.md](backends/github-native.md).
   - For `markdown-file-based`, read [backends/markdown-file-based.md](backends/markdown-file-based.md).
   - Completion criterion: the skill knows the configured representation for stage state, State Reason, Package Contract, containment, dependency, external blockers, ownership, receipts, implementation artifacts, and lifecycle outcomes.

4. Read [workflow-examples.md](workflow-examples.md) only when doing setup, sweep, validation, review, or an end-to-end dry run.

## Boundaries

- Do not choose a backend for the repository; `setup-ai-native-development` owns setup.
- Do not mutate issues, files, labels, relationships, ownership, claims, branches, or PRs.
- Do not duplicate backend reference rules into the calling workflow skill.
- Do not invent fields outside the configured backend reference.
