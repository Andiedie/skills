---
name: and-clarify
description: Clarify decision-blocked work before packaging, recording backend-safe decisions instead of local docs.
disable-model-invocation: true
---

# AND Clarify

Clarify one bounded human decision space whose package-blocking questions can all be enumerated now. `grilling` owns the interview cadence; `and-interview-contract` makes confirmed results recoverable and ready for durable synchronization.

## Backend Contract

Before reading or writing workflow state, read `.and/config.yml`, then use `and-backend-contract` for the target, receipts, State Reason, and stage mutation. If setup is incomplete or `and-backend-contract`, `and-interview-contract`, or `grilling` is unavailable, route to `setup-and` or installation with the exact missing dependency.

## When To Use

Use `and-clarify` when work is `needs-info`, `Resume with` points here, and the current State Reason names one bounded product, domain, architecture, naming, testing, or acceptance decision space whose branches are visible now.

Uncertainty whose next sharp questions depend on research, a prototype, a task, or an earlier investigation is fog and belongs in `and-wayfind`. Facts, access waits, external state, direct acceptance input, and already-packable work continue through their accountable route.

## Process

1. Focus the decision.
   - Read the work record, current State Reason, relevant receipts, relationships, and newer activity.
   - Verify that one bounded, currently enumerable decision space is the actual package blocker and that `and-clarify` is the recorded route.
   - Supply `and-interview-contract` with workflow skill `and-clarify`, objective `clarify-decision`, canonical repository and work identities, the decision boundary, and authoritative backend evidence; reconcile valid recovery after backend state.
   - Completion criterion: target, blocker, decision owner, recovered confirmations, and the complete decision boundary are explicit, or the work is routed without an interview.

2. Grill within the boundary.
   - Invoke `grilling` with the package blocker, decision boundary, and confirmed inputs. Let it own question order, recommendations, fact-finding, and final shared understanding.
   - Apply `and-interview-contract` throughout the exchange so each material confirmation is recoverable.
   - When an answer reveals that the next question cannot be made sharp without an investigation, stop expanding the interview and return that remaining uncertainty as an `and-wayfind` route.
   - Completion criterion: every package blocker in the bounded decision space is resolved with allowed evidence, or the result contains one precise resumable blocker or destination-level Wayfinding uncertainty.

3. Synchronize the result.
   - Receive one complete result from `and-interview-contract`. At completion, pause, task switch, or handoff, append only the missing Clarification Notes receipt for its valid checkpoint.
   - With no material confirmation and no recovery buffer, skip the empty receipt. When a blocker or fog remains, keep `needs-info` and write its precise current State Reason; move to `needs-pack` only after the resolved receipt is authoritative.
   - Verify every mutation. On failure, retain the recovery buffer and pre-advance stage; after success, clean only the matching synchronized buffer.
   - Completion criterion: `and-pack` can consume an authoritative result without replaying the interview, or one authoritative blocker and exit condition can resume through `and-clarify` or `and-wayfind`.

4. Report a receipt.
   - Name the work record, decisions recorded, stage change, remaining blocker when any, and next skill.
   - Keep the report shorter than the durable note and leave interview detail in its authority.
   - Completion criterion: the user can invoke the named next skill or satisfy the named blocker without replaying the interview.

## Clarification Note

```markdown
## Clarification Notes

Checkpoint: <recovery-buffer digest>

Resolved decisions:
- <decision and rationale>

Next step:
- <and-pack or the current State Reason route>
```

Add `Required repository updates`, `Acceptance implications`, or `Remaining blocker` only when the confirmed result contains that package input. Omit absent sections instead of filling them with placeholders.

## Boundaries

- Keep one bounded, currently enumerable decision space inside this stage; route later-dependent fog to `and-wayfind`.
- Keep repository and implementation artifacts unchanged, with required future changes represented only as package inputs.
- Stop with synchronized clarification state; `and-pack` owns the next delivery-unit transition.
