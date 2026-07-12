---
name: and-clarify
description: Clarify decision-blocked work before packaging, recording backend-safe decisions instead of local docs.
disable-model-invocation: true
---

# AND Clarify

Clarify one concrete human decision that blocks `needs-info` work from being packaged. It invokes `grilling` for interview behavior and `and-interview-contract` for evidence, recovery, domain modeling, and artifact-ready output.

## Backend Contract

Before reading or writing workflow state, read `.and/config.yml`, then use `and-backend-contract`.

Use the configured backend reference for reading the target, writing Clarification Notes and State Reasons, and moving stage state. If setup or either required AND contract is unavailable, stop and route to `setup-and` or installation.

## When To Use

Use `and-clarify` when work is `needs-info`, its current State Reason names one structured product, domain, architecture, naming, testing, or acceptance decision, and `Resume with` points to `and-clarify`.

Route reporter facts, access waits, external state, direct acceptance input, and work that is already packable to the accountable owner or recorded resume skill. Route an initially unknowable, multi-session decision path to `and-wayfind`.

## Runtime Skills

`grilling` and `and-interview-contract` are required. Invoke both as their own authorities; do not restate or simulate either one.

## Process

1. Resolve the target.
   - Read the work record, current State Reason, relevant receipts, relationships, and newer activity.
   - Verify that one concrete decision is the actual package blocker and that `and-clarify` is the recorded route.
   - Supply `and-interview-contract` with host `and-clarify`, objective `clarify-decision`, canonical repository and work identities, the decision question, and authoritative backend evidence; reconcile valid recovery after backend state.
   - Completion criterion: target, blocker, owner, recovered confirmed inputs, and decision boundary are explicit, or the work is routed without an interview.

2. Run the interview.
   - Invoke `grilling` and follow its one-question-at-a-time behavior.
   - Apply `and-interview-contract` throughout the exchange and persist each materially confirmed result through its recovery rules.
   - Completion criterion: every package blocker is resolved with allowed evidence, or one precise remaining blocker is recoverable.

3. Capture the result.
   - Receive the complete artifact-ready output from `and-interview-contract`.
   - When no blocker remains, obtain final shared-understanding confirmation.
   - Completion criterion: `and-pack` can consume the result without replaying the interview, or one owner and exit condition remain.

4. Synchronize the backend.
   - At completion, pause, task switch, or handoff, append only the missing Clarification Notes receipt for the valid checkpoint.
   - When no material decision occurred and no recovery buffer exists, skip an empty receipt and cleanup.
   - When a blocker remains, write the current State Reason. When none remains, move `needs-info` to `needs-pack` after the receipt is authoritative.
   - Verify each mutation. Retain recovery and `needs-info` when synchronization fails; after success, ask `and-interview-contract` to clean its matching buffer.
   - Completion criterion: confirmed inputs and stage are authoritative, or one current blocker is authoritative and resumable.

5. Report a receipt.
   - Name the work record, decisions recorded, stage change, remaining blocker when any, and next skill.
   - Keep the report short; do not copy the interview, recovery buffer, tracker body, or package draft.
   - Completion criterion: the user can continue with `and-pack` or resolve the named blocker.

## Clarification Note

```markdown
## Clarification Notes

Checkpoint: <recovery-buffer digest>

Resolved decisions:
- <decision and rationale>

Glossary updates:
- <none or artifact-ready update>

ADR drafts:
- <none or artifact-ready draft>

Documentation updates:
- <none or artifact-ready update>

Acceptance implications:
- <criteria or edge cases>

Remaining blockers:
- <none or one specific blocker>

Next step:
- <and-pack or the current State Reason route>
```

## Boundaries

- Keep one concrete decision interview inside this stage; multi-session discovery belongs to `and-wayfind`.
- Keep repository and implementation artifacts unchanged; record required future changes as package inputs.
- Stop after clarification state is synchronized; packing, claiming, implementation, closure, and merge belong downstream.
