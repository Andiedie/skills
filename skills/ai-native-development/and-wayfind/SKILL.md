---
name: and-wayfind
description: Map and resolve multi-session uncertainty until work can be packaged.
disable-model-invocation: true
---

# AND Wayfind

A destination is visible, but the way there is still in fog. Wayfinding charts a shared map, then resolves one investigation per session until the route is clear enough for `and-pack`.

Wayfinding plans. The pull to implement is evidence that the map has reached its package handoff.

## Runtime Contracts

Use `and-workflow-contract` for workflow state and read [wayfinding.md](../and-workflow-contract/wayfinding.md) for map, investigation, ownership, resolution, and handoff operations. Read [relationship-api.md](../and-workflow-contract/relationship-api.md) before native relationship mutation.

Use `and-interview-contract` for charting and every human-in-the-loop (HITL) investigation. It owns evidence, recovery, workflow-safe domain modeling, and compact interview output while `grilling` owns interview cadence. Verify only the dependencies reached by this invocation: charting and grilling need both skills; prototype also needs `prototype`; research needs `research`; a HITL task needs the interview pair; an unattended (AFK) task needs only the skills named by the task or map Notes. Route an unavailable dependency to installation with its exact name.

## Investigation Methods

- **Research** (AFK): invoke `research` for facts requiring primary sources outside the current worktree, then link its Markdown evidence from the resolution.
- **Prototype** (HITL): invoke `prototype` for a cheap concrete artifact that lets the human judge behavior or form. Resolution requires the human's actual reaction.
- **Grilling** (HITL): invoke `grilling` under `and-interview-contract` for a live decision and keep the exchange on its Wayfinding investigation.
- **Task** (AFK or HITL): perform a bounded prerequisite whose result makes a later decision possible. Agent scope is routine, authorized, verifiable, idempotent action after re-checking current state; the accountable human owns non-idempotent action and action involving permissions, cost, secrets, terms, or broader shared state. Record the resulting non-secret facts. A task advances the route without delivering the destination.

Research and prototype assets live in a dedicated investigation branch/worktree. The resolution links each asset with `cleanup` or `promote-to-package` disposition; its answer remains durable after a throwaway asset is removed.

## Process

Choose exactly one path per invocation. `Chart A Map` handles a routed non-map record and its incomplete initial outcome. `Work Through A Map` handles an existing map. Charting stops after publication, and map work stops after one investigation or one recovered mutation.

### Chart A Map

Use this path for a non-map work record routed to `and-wayfind`, or to resume its incomplete no-map exit or initial investigation publication.

Resolve the chart key from durable-workflow identity with namespace `and-wayfind-map-chart:v1`, then apply the workflow contract's unique initial-outcome and exact-key rules. One valid incomplete `Wayfinding Exit` resumes only its recorded stage, State Reason, verification, and recovery cleanup. One valid incomplete initial publication resumes `Publish the map` from its recorded intent. Conflicting outcome histories route to `and-sweep`. Recovery reuses the durable result instead of replaying the interview.

1. Orient to the work record.
   - Read its stage, State Reason, source evidence, receipts, relationships, ownership, and linked artifacts.
   - An eligible source is one existing, unclaimed, unpackaged top-level record whose current route is `and-wayfind`. Route missing intake to `and-intake`, incorrect triage to `and-triage`, and already-clear work to `and-pack`; route package or claim contradictions to `and-sweep`.
   - Supply `and-interview-contract` with workflow skill `and-wayfind`, objective `chart-map`, the canonical repository and work identities, current evidence, and the destination question.
   - Completion criterion: one eligible source record, its known evidence, and its uncertainty boundary are explicit.

2. Name the destination.
   - Invoke `grilling` to establish what must be clear before packaging can begin. The destination fixes the in-scope and out-of-scope boundary.
   - Preserve the confirmed destination and scope through `and-interview-contract` before exploring the route.
   - Completion criterion: the human confirms a concise destination and its out-of-scope boundary, and that result is recoverable.

3. Explore breadth-first.
   - Continue `grilling` breadth-first across the whole space: surface sharp questions, likely methods, known ordering, and fog while leaving each investigation unanswered.
   - Return the destination, scope, first visible frontier, and remaining fog through `and-interview-contract`.
   - If no multi-session fog exists, record one `Wayfinding Exit` through the chart operation. Route one bounded decision space to `needs-info` with a complete `and-clarify` State Reason; route fully clear work to `needs-pack` with a cleared State Reason. Apply and verify only that sole recorded outcome, clean synchronized recovery, report, and stop.
   - Completion criterion: the work either exits without a map, or has confirmed multi-session fog plus a complete first visible frontier.

4. Publish the map.
   - Apply the workflow contract's Chart Wayfinding Map operation with the Investigation Publication receipt below. Derive initial investigation keys from the chart key plus stable confirmed-order ordinals such as `<chart-key>:I01`.
   - Supply the confirmed five-section map, material source evidence, interview checkpoint, sharp investigations, methods, ordering, and remaining fog. Promote the source record as the map and set the destination-level `and-wayfind` State Reason.
   - Verify the complete publication outcome, then clean synchronized interview recovery.
   - Completion criterion: one resumable map exists with a queryable frontier and no investigation has been resolved.

5. Report the chart receipt.
   - Name the map, investigations created, current frontier, remaining fog, and next `and-wayfind` invocation.
   - Leave map and investigation bodies in GitHub.
   - Completion criterion: the user can resume the named map and frontier without replaying the chart interview.

### Work Through A Map

Use this path for an existing map. An investigation argument is optional.

1. Orient to the low-resolution map.
   - Read Destination, Notes, Decisions so far, Not yet specified, Out of scope, current stage and State Reason, investigation states, and dependencies.
   - Fetch full bodies or resolutions only for the selected investigation and directly relevant records.
   - Before frontier selection, recover pending later investigation publication or a durable resolution missing close or map projection through the corresponding workflow operation. Finish only missing effects, verify and report the recovered map state, then stop.
   - Completion criterion: current destination, frontier, fog, and relevant prior decisions are known without loading every investigation in full.

2. Choose and claim one investigation.
   - A named investigation must belong to the map, be open and unblocked, and be unclaimed or already owned by the current actor. Otherwise resume the first eligible investigation owned by the actor, then the first unclaimed frontier investigation in native child order.
   - Re-read blockers before resuming owned work. A newly blocked investigation stops this invocation with the changed frontier.
   - Claim only unclaimed work, then re-read membership, lifecycle, blockers, method, and ownership. An ownership race returns to the current frontier. Ordinary eligibility changes stop with the changed state and frontier; malformed relationships or method state route to `and-sweep`.
   - Completion criterion: exactly one eligible investigation is selected and owned by the current actor for this invocation; the map and delivery ownership remain unchanged.

3. Resolve it.
   - A durable resolution skips method execution and proceeds to the missing close or map advance. Otherwise invoke the recorded method and zoom into linked evidence as needed.
   - For HITL, supply objective `resolve-investigation` and the investigation's canonical identity to `and-interview-contract`. The investigation stays open until the human supplies the required response.
   - The current owner keeps unfinished ownership with its blocker or recovery evidence. An explicit abandonment may release only that investigation after preserving the reason.
   - Without a durable answer, report one precise recoverable blocker and stop before map advance.
   - Completion criterion: one durable answer exists with required evidence and asset disposition, or the invocation has stopped with one recoverable blocker.

4. Advance the map.
   - Apply the workflow contract's Resolve Investigation operation with the complete answer, re-reading the map immediately before mutation. The durable resolution and HITL checkpoint precede close and map projection.
   - Project one linked, named gist into `Decisions so far`, or one linked reason into `Out of scope` when the answer lies beyond the Destination.
   - Publish newly sharp investigations through Chart Wayfinding Map with batch key `<source-investigation-key>:batch` and stable confirmed-order keys such as `<source-investigation-key>:N01`. Resume only that batch's publication history; route competing intent or mismatched content to `and-sweep`.
   - Remove graduated fog, update invalidated investigations, and move beyond-destination findings to `Out of scope`.
   - When no open investigation or in-scope fog remains, move the map to `needs-pack` and clear the current State Reason; otherwise preserve `needs-info` and an accurate `Resume with: and-wayfind` State Reason.
   - Re-read after mutation. Preserve newer concurrent changes and require the durable resolution's named pointer or out-of-scope reason. Report an incomplete projection and stop with the resolution authoritative; the next invocation recovers it before frontier selection.
   - Clean synchronized interview recovery after the complete map advance verifies.
   - Completion criterion: the authoritative map reflects the answer, current frontier, remaining fog, and clear-or-resume state without resolving a second investigation.

5. Report the work receipt.
   - Name the map, resolved investigation or blocker, new frontier or clear state, relevant asset disposition, and next `and-wayfind` or `and-pack`.
   - Leave full answers and record bodies in their durable authority.
   - Completion criterion: the user can resume the named frontier or package the clear map without reconstructing the investigation.

## Wayfinding Exit Receipt

Use this append-only receipt when the opening grill proves that map state is unnecessary:

```markdown
## Wayfinding Exit

Chart key: <deterministic chart key>
Checkpoint: <interview checkpoint>
Confirmed result:
<destination, scope, decisions and rationale, plus only required repository updates or acceptance implications>
Target stage: <needs-info or needs-pack>
Target State Reason:
<the complete State Reason when target stage is needs-info, or `State: cleared`>
Next step: <and-clarify or and-pack>
```

## Investigation Publication Receipt

Use this append-only receipt before creating an initial or newly visible batch:

```markdown
## Investigation Publication

Publication key: <initial chart key, or deterministic later batch key>
Checkpoint: <interview checkpoint for the initial chart; omit for later publication>
Investigations:
- <investigation key> | <method> | <title> | <one sharp question>
Publication: <pending, or completed with linked identities>
```

This receipt is the publication intent and completion evidence required by Chart Wayfinding Map.

## Investigation Resolution Receipt

Use this receipt when the selected method produces a durable answer:

```markdown
## Investigation Resolution

Checkpoint: <interview checkpoint when HITL; omit for AFK>

Answer:
<durable answer>

Assets:
- <link and cleanup or Package-promotion disposition, or none>
```

## Boundaries

- Keep investigation work epistemic; delivery begins with the separate Package Contract published by `and-pack`.
- Keep the map shared and unclaimed; investigation ownership covers one investigation and grants no delivery ownership.
- Keep PRD children and investigations distinct in identity, relationship meaning, queue visibility, and lifecycle.
- Leave a clear map open for `and-pack`, which owns replacement-package handoff and map closure.
