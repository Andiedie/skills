---
name: and-backend-contract
description: Use when an AND workflow skill needs to read or write workflow state through the configured `.and/config.yml` backend, or needs the `github-native` / `markdown-file-based` representation rules.
---

# AND Backend Contract

Reference skill for loading the configured workflow state backend contract.

Use it before an AND workflow skill reads, writes, validates, or reasons about workflow state. This skill loads the contract; it does not perform the workflow operation.

## Process

1. Read and validate the repository's `.and/config.yml`.
   - It must be a YAML mapping with `version: 1`.
   - It must contain only `version` and `workflow_state_backend`.
   - `workflow_state_backend` must be `github-native` or `markdown-file-based`.
   - If missing, malformed, unsupported, extended, or ambiguous, route to `setup-and`.
   - Completion criterion: one supported backend is known.

2. Read [backend-contract.md](backend-contract.md).
   - Use it for backend-neutral concepts, operations, relationship vocabulary, State Reason, receipt, lifecycle, and invariant rules.
   - Completion criterion: the calling skill's operation is expressed in backend-neutral terms.

3. Read exactly one backend reference.
   - For `github-native`, read [backends/github-native.md](backends/github-native.md).
   - For `markdown-file-based`, read [backends/markdown-file-based.md](backends/markdown-file-based.md).
   - Do not read the other backend unless doing setup, backend change design, sweep validation, or an explicit comparison.
   - Completion criterion: the calling skill knows the configured representation for the operation it is about to perform.

4. Return to the calling workflow skill.
   - Do not perform the operation here.
   - Do not produce a separate user-facing receipt unless the user directly asked about backend rules.
   - Completion criterion: the caller can continue with one backend-specific read, write, or validation plan.

## Boundaries

- Do not choose or switch the repository backend; `setup-and` owns that.
- Do not mutate issues, files, labels, relationships, ownership, claims, branches, PRs, or lifecycle state.
- Do not run the calling workflow stage.
- Do not invent fields outside `.and/config.yml` v1 or the configured backend reference.
- Do not maintain GitHub and markdown workflow state in parallel.
- Do not treat implementation artifacts as workflow state.
