---
name: and-backend-contract
description: Use when an AND workflow skill needs to read or write workflow state through the configured `.and/config.yml` backend, or needs the `github-native` / `markdown-file-based` representation rules.
---

# AND Backend Contract

Load the one backend contract a calling AND skill needs before it reads, writes, validates, or reasons about workflow state.

## Process

1. Read `.and/config.yml` and validate it against the [Config Contract](backend-contract.md#config-contract). Route a missing, malformed, unsupported, or extended config to `setup-and`.
   - Completion criterion: exactly one supported configured backend is known.

2. In the [Backend-Neutral Operations](backend-contract.md#backend-neutral-operations), map every workflow-state action requested by the caller to its named operation, then load the concepts and [Cross-Backend Invariants](backend-contract.md#cross-backend-invariants) those operations use.
   - Completion criterion: every workflow-state action in the caller has a backend-neutral operation plan.

3. Load the same operations from the configured reference's Operation Index:
   - [`github-native`](backends/github-native.md#operation-index)
   - [`markdown-file-based`](backends/markdown-file-based.md#operation-index)

   Read both representations only for setup, backend-change design, sweep comparison, or an explicit cross-backend audit.
   - Completion criterion: the caller can continue with one representation-specific plan covering every requested workflow-state action.

## Boundaries

- `setup-and` owns backend selection and change; this skill accepts only a valid configured backend.
- This skill returns control without performing the operation or emitting a stage receipt.
- The configured reference is the sole representation used by the caller; the neutral contract remains the sole semantic authority.
