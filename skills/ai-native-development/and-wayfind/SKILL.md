---
name: and-wayfind
description: Map and resolve multi-session uncertainty until work can be packaged.
disable-model-invocation: true
---

# AND Wayfind

A destination is visible, but the way there is still in fog. Wayfinding charts that uncertainty as a shared map, then resolves one investigation at a time until `and-pack` can publish the delivery unit.

Wayfinding plans; it does not deliver the destination. The pull to implement is usually evidence that the map has reached its handoff boundary.

## Runtime Contracts

Before reading or writing workflow state, read `.and/config.yml`, invoke `and-backend-contract`, and use the configured backend reference for map, investigation, relationship, ownership, resolution, and lifecycle operations.

Invoke `and-interview-contract` whenever charting or resolving a HITL investigation requires an interview. It owns evidence, recovery, backend-safe domain modeling, and artifact-ready output. Before the selected path or investigation method begins, verify only what it invokes: charting and grilling require `grilling` plus the interview contract; prototype also requires `prototype`; research requires `research`; a HITL task requires `grilling` plus the interview contract, while an AFK task requires only the skills named by that task or the map Notes. Stop with exact install guidance when a required skill is unavailable.

## Map And Investigation

The map is a shared index, not a store or claim unit. Open investigations are queried through backend relationships rather than copied into its body. Its body is:

```markdown
## Destination

<what must be clear before packaging can begin>

## Notes

<domain sources, standing constraints, and skills relevant to every session>

## Decisions so far

<!-- one named, linked gist per resolved investigation -->

## Not yet specified

<in-scope fog that cannot yet be phrased as a sharp question>

## Out of scope

<work beyond this destination>
```

Each investigation is one sharp question sized for one Agent session:

```markdown
## Question

<the decision or investigation this record resolves>
```

The detailed answer lives only in the investigation resolution. Human-readable narration and map pointers use linked titles, not bare IDs.

The frontier is derived from open, unblocked, unclaimed investigations. Fog remains on the map until it becomes sharp enough to create a record.

Use one test: create an investigation when its question can be stated precisely now, even if it is blocked or unanswered; keep it as fog when the question itself cannot yet be phrased precisely.

## Investigation Methods

- **Research** (AFK): invoke `research` for facts requiring primary sources outside the current worktree. Link its Markdown evidence from the resolution.
- **Prototype** (HITL): invoke `prototype` for a cheap concrete artifact that lets the human judge behavior or form. The human must actually react before resolution.
- **Grilling** (HITL): invoke `grilling` directly under `and-interview-contract`, one question at a time. Do not invoke `and-clarify` from this skill.
- **Task** (AFK or HITL): perform bounded prerequisite work whose result makes a later decision possible. It may act, but it does not deliver the destination.

Create research and prototype assets in a dedicated investigation branch/worktree, never the ordinary worktree. The resolution links the asset and marks it for cleanup or Package promotion. Its answer remains authoritative even when a throwaway asset is later removed.

## Process

Choose exactly one path per invocation. Any work record with pending initial investigation publication resumes `Chart A Map`; other maps use `Work Through A Map`. Never chart a map and resolve an investigation in the same invocation, and never resolve more than one investigation.

### Chart A Map

Use this path for a non-map work record whose current route is `and-wayfind`, or for any work record whose initial investigation publication is incomplete.

For incomplete initial publication, re-read the record and apply the eligibility checks in Resolve the work record, then read the recorded intent and resume at Publish the map whether or not map promotion already occurred. Do not repeat the destination interview, breadth-first exploration, or already verified writes.

1. Resolve the work record.
   - Read its stage, State Reason, source evidence, receipts, relationships, ownership, and linked artifacts.
   - If the work record carries delivery ownership or claim evidence, stop and route the drift to `and-sweep`; a map must begin unclaimed.
   - If the work record already carries a Package Contract, an executable package shape such as `single` or `prd-package`, PRD containment, or child records, do not promote or reinterpret it as a map; route the contradictory package state to `and-sweep`.
   - Route unrecorded work to `and-intake`, untriaged work to `and-triage`, a bounded decision space whose questions are currently enumerable to `and-clarify`, and already-clear work to `and-pack`.
   - Supply `and-interview-contract` with workflow skill `and-wayfind`, objective `chart-map`, the canonical repository and work identities, current evidence, and the destination question.
   - Completion criterion: one eligible existing work record and its uncertainty boundary are explicit.

2. Name the destination.
   - Invoke `grilling` to establish what must be clear before packaging can begin. The destination fixes scope.
   - Completion criterion: the human confirms a concise destination and its out-of-scope boundary.

3. Explore breadth-first.
   - Invoke `grilling` across the whole decision space, surfacing sharp questions, their likely methods, known ordering, and fog without resolving one thread deeply.
   - Obtain final shared-understanding confirmation for the destination, scope, first visible frontier, and remaining fog before any backend synchronization.
   - If no real fog exists, append one `Wayfinding Exit` receipt carrying the interview checkpoint without creating map state. Keep one bounded, currently enumerable decision space in `needs-info` with `Resume with: and-clarify`; otherwise move confirmed packageable work to `needs-pack`. Verify the route, clean synchronized recovery, report it, and stop without entering map publication.
   - Completion criterion: the work either exits without a map, or has confirmed multi-session fog plus a complete first visible frontier.

4. Publish the map.
   - Use the backend contract's Chart Wayfinding Map operation with the Investigation Publication receipt below. When no chart key is recorded, derive it from durable-workflow identity with namespace `and-wayfind-map-chart:v1`; derive initial investigation keys from that key plus stable map ordinals such as `<chart-key>:I01`.
   - Supply the confirmed destination, five map sections, material source evidence, interview checkpoint, currently sharp investigations, methods, ordering, and remaining fog. Promote the existing work record rather than creating a second map.
   - Record the destination-level State Reason with `Resume with: and-wayfind` and a map-chart receipt carrying the interview checkpoint.
   - Verify every created record, method, relationship, stage, and receipt, then clean synchronized interview recovery.
   - Completion criterion: one resumable map exists with a queryable frontier and no investigation has been resolved.

5. Report the chart receipt.
   - Name the map, investigations created, currently available frontier, remaining fog, and next `and-wayfind` invocation.
   - Do not copy the map or investigation bodies into chat.

### Work Through A Map

Use this path for an existing map. An investigation argument is optional.

1. Load the low-resolution map.
   - Read Destination, Notes, Decisions so far, Not yet specified, Out of scope, current stage and State Reason, investigation states, and dependencies.
   - Fetch full bodies or resolutions only for the selected investigation and directly relevant records.
   - Detect incomplete work before selecting new frontier work.
   - If non-initial investigation keys have pending publication, finish only their missing records or relationships, verify completion, report the recovered map state, and stop.
   - If a closed resolved investigation lacks its map pointer or map advance, continue directly at Advance the map with that durable resolution, report the recovered map state, and stop without selecting another investigation.
   - If an owned open investigation already has a durable resolution but lacks close, carry it directly to Resolve it; do not select or claim another investigation.
   - Completion criterion: current destination, frontier, fog, and relevant prior decisions are known without loading every investigation in full.

2. Choose and claim one investigation.
   - If the user names an investigation, verify that it belongs to the map, is open and unblocked, and is either unclaimed or already owned by the current actor. Otherwise resume the first open investigation owned by the current actor, then fall back to the first unclaimed frontier investigation in backend order.
   - Re-read blockers before resuming an investigation already owned by the current actor. If it is now blocked, report the changed investigation and current frontier, then stop without running a method or claiming another investigation.
   - Record ownership only for an unclaimed investigation, then re-read authoritative state. Revalidate map membership, open lifecycle, blockers, exactly one valid method, and current ownership. If another actor owns it, select the current frontier or report that none is available. If any other eligibility condition changed, do not invoke the method; report the changed investigation and current frontier, and route malformed relationship or method state to `and-sweep`.
   - Completion criterion: exactly one eligible investigation is selected and owned by the current actor for this invocation; the map and delivery ownership remain unchanged.

3. Resolve it.
   - If one durable resolution already exists, do not invoke the method or write another; resume the missing close or map advance. Otherwise invoke the investigation's method and follow `and-interview-contract` for HITL evidence and recovery.
   - For a HITL method, supply objective `resolve-investigation` and the selected investigation's canonical identity to `and-interview-contract`, not the map identity.
   - Zoom into linked evidence as needed. A HITL investigation remains open until the human supplies the required response.
   - A durable answer uses the Investigation Resolution receipt below.
   - If the current owner explicitly abandons unfinished work, preserve the blocker or recovery evidence and release only that investigation's ownership. Never release another actor's investigation.
   - When no durable resolution exists, preserve the precise blocker and recovery state, keep the investigation open and owned unless explicitly released, report the blocker, and stop. Do not enter Advance the map.
   - Completion criterion: one durable answer exists with required evidence and asset disposition, or the invocation has stopped with one recoverable blocker.

4. Advance the map.
   - Enter only when the investigation has a complete answer ready to record, or one durable resolution already exists.
   - Re-read the map immediately before mutation.
   - Write the resolution only when none exists, including the valid interview checkpoint when the method was HITL. Close the investigation only when it is still open.
   - Append one linked, named gist to `Decisions so far` when the answer advances the route. If the investigation proves to be beyond the Destination, put one linked reason in `Out of scope` instead and do not add it to Decisions.
   - Publish newly sharp investigations through the backend contract's Chart Wayfinding Map operation using the Investigation Publication receipt below. Derive each batch's keys from the source investigation key plus stable confirmed-order ordinals such as `<source-investigation-key>:N01`, so independent frontier advances cannot allocate the same key.
   - Remove graduated fog, update invalidated records, and move beyond-destination findings to `Out of scope`.
   - When no open investigation or in-scope fog remains, move the map to `needs-pack`; otherwise preserve `needs-info` and an accurate `Resume with: and-wayfind` State Reason.
   - Re-read after mutation and verify that the map preserves newer concurrent changes and includes the durable resolution's named pointer or out-of-scope reason. If projection is incomplete or conflicting, keep the investigation resolution authoritative, report an incomplete map advance, and stop; the next invocation recovers it before frontier selection.
   - After map advance verifies, clean synchronized interview recovery.
   - Completion criterion: the authoritative map reflects the answer, current frontier, remaining fog, and clear-or-resume state without resolving a second investigation.

5. Report the work receipt.
   - Name the map, investigation resolved or blocker, new frontier or clear state, asset disposition when relevant, and next `and-wayfind` or `and-pack`.
   - Do not copy full answers, map bodies, or investigation records into chat.

## Investigation Publication Receipt

Use this append-only receipt before creating an initial or newly visible batch:

```markdown
## Investigation Publication

Chart key: <deterministic map chart key>
Investigations:
- <investigation key> | <method> | <title> | <one sharp question>
Publication: <pending, or completed with linked identities>
```

Use this receipt as the publication intent and completion evidence required by the backend contract's Chart Wayfinding Map operation.

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

## Investigation Ownership Receipts

When the configured backend derives investigation ownership from receipts, use:

```markdown
## Investigation Claim

Sequence: <next positive integer>
Owner: <canonical actor identity>
```

```markdown
## Investigation Release

Sequence: <next positive integer>
Owner: <current canonical actor identity>
Reason: <why unfinished ownership is released>
```

Re-read receipts before append and allocate one greater than the highest valid sequence. The highest valid sequence determines current ownership: claim sets its owner; release clears ownership only when its owner matches the current owner. Resume by the same owner writes no new receipt. Duplicate or non-increasing sequences, release by another actor, or conflicting current ownership route to `and-sweep`.

## Boundaries

- Keep investigation work epistemic; delivery begins only after `and-pack` publishes a separate Package Contract.
- Keep the map shared and unclaimed. Investigation ownership covers one investigation and never authorizes delivery work.
- Keep PRD children and investigations distinct in identity, relationship meaning, queue visibility, and lifecycle.
- Leave a clear map open for `and-pack`; Package publication owns map handoff and closure.
